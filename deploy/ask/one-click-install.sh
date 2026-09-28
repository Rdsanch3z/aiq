#!/usr/bin/env bash
# ASK — provisionamento de host, do zero, para uma VM Linux quase vazia.
#
# Este script NÃO faz parte do blueprint AI-Q original da NVIDIA — é uma adição
# específica do projeto ASK (ver deploy/ask/README.md). Ele só prepara o
# SISTEMA OPERACIONAL (Docker + firewall + ajustes de kernel). Todo o resto —
# backend, frontend, banco, busca — roda dentro de containers, então não há
# Python, Node.js ou `uv` para instalar aqui.
#
# Uso:
#   sudo bash deploy/ask/one-click-install.sh
#
# Variáveis opcionais:
#   ASK_REPO_URL   URL do git remote, se este script for baixado avulso e o
#                  repositório ainda não estiver clonado (ex.: para provisionar
#                  uma VM nova do zero, sem clonar manualmente antes).
#   ASK_REPO_DIR   Onde clonar/onde o repositório já está. Default: /opt/ask
#
# Idempotente: pode ser executado de novo com segurança (pula o que já está feito).

set -euo pipefail

log() { printf '\n==> %s\n' "$*"; }
warn() { printf '\n!! %s\n' "$*" >&2; }

# --- 0. Precisa ser root -----------------------------------------------------
if [[ ${EUID} -ne 0 ]]; then
  warn "Rode como root: sudo bash $0"
  exit 1
fi

# --- 1. Checar a distribuição (só Ubuntu/Debian, via apt) -------------------
if [[ ! -r /etc/os-release ]]; then
  warn "Não encontrei /etc/os-release — não dá para identificar a distribuição."
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
case "${ID}" in
  ubuntu|debian) : ;;
  *)
    warn "Distribuição não suportada por este script: ${ID} (${PRETTY_NAME:-desconhecida})."
    warn "Este script cobre Ubuntu/Debian (apt). Para outra distro, instale Docker Engine manualmente e pule para a etapa de firewall/sysctl."
    exit 1
    ;;
esac
log "Distribuição: ${PRETTY_NAME:-$ID}"

# --- 2. Pacotes base ----------------------------------------------------------
log "Atualizando índice de pacotes"
apt-get update -y

log "Instalando pacotes base (git, curl, ufw, utilitários)"
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates curl gnupg git ufw unzip jq

# --- 3. Docker Engine, do repositório oficial (versão mais atual) -----------
if command -v docker >/dev/null 2>&1; then
  log "Docker já instalado ($(docker --version)) — pulando instalação"
else
  log "Instalando Docker Engine a partir do repositório oficial do Docker"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/${ID}/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  arch="$(dpkg --print-architecture)"
  codename="${VERSION_CODENAME:-$(lsb_release -cs 2>/dev/null || true)}"
  if [[ -z "${codename}" ]]; then
    warn "Não consegui detectar o codename da distribuição (ex.: 'jammy', 'noble'). Defina VERSION_CODENAME em /etc/os-release e rode de novo."
    exit 1
  fi

  cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${ID} ${codename} stable
EOF

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

systemctl enable --now docker
log "Docker ativo: $(docker --version) / $(docker compose version)"

# --- 4. Permitir rodar `docker` sem sudo para quem chamou este script -------
target_user="${SUDO_USER:-}"
if [[ -n "${target_user}" && "${target_user}" != "root" ]]; then
  if ! id -nG "${target_user}" 2>/dev/null | grep -qw docker; then
    log "Adicionando '${target_user}' ao grupo docker"
    warn "Isso equivale a acesso root nesta máquina (padrão para quem opera o deploy) — revogue com 'gpasswd -d ${target_user} docker' se não for necessário."
    usermod -aG docker "${target_user}"
    warn "Faça logout/login (ou 'newgrp docker') para o grupo valer nesta sessão."
  fi
fi

# --- 5. Ajuste de kernel exigido pelo OpenSearch -----------------------------
log "Ajustando vm.max_map_count (exigido pelo OpenSearch para iniciar)"
sysctl_file=/etc/sysctl.d/99-ask-opensearch.conf
if [[ ! -f "${sysctl_file}" ]]; then
  echo 'vm.max_map_count=262144' > "${sysctl_file}"
fi
sysctl -w vm.max_map_count=262144 >/dev/null

# --- 6. Firewall: só SSH, HTTP e HTTPS chegam nesta VM -----------------------
log "Configurando ufw (22, 80, 443)"
if ufw app info OpenSSH >/dev/null 2>&1; then
  ufw allow OpenSSH >/dev/null
else
  ufw allow 22/tcp >/dev/null
fi
ufw allow 80/tcp >/dev/null
ufw allow 443/tcp >/dev/null
ufw --force enable >/dev/null

# --- 7. Repositório do ASK ----------------------------------------------------
repo_dir="${ASK_REPO_DIR:-/opt/ask}"
repo_url="${ASK_REPO_URL:-}"

if [[ -d "${repo_dir}/.git" ]]; then
  log "Repositório já presente em ${repo_dir} — pulando clone (dê 'git pull' manualmente se quiser atualizar)"
elif [[ -n "${repo_url}" ]]; then
  log "Clonando ${repo_url} em ${repo_dir}"
  git clone "${repo_url}" "${repo_dir}"
else
  warn "Nenhum repositório em ${repo_dir} e ASK_REPO_URL não foi definido."
  warn "Clone manualmente, ou rode de novo com: sudo ASK_REPO_URL=<url> bash $0"
fi

# --- 8. Esqueleto do .env -----------------------------------------------------
if [[ -d "${repo_dir}" ]]; then
  env_file="${repo_dir}/deploy/.env"
  env_example="${repo_dir}/deploy/.env.example"
  if [[ ! -f "${env_file}" && -f "${env_example}" ]]; then
    cp "${env_example}" "${env_file}"
    log "Criado ${env_file} a partir do template — preencha as credenciais do Azure antes de subir a stack"
  fi
fi

cat <<SUMMARY

===================================================================
 Provisionamento do host concluído.

   Docker:          $(docker --version)
   Compose plugin:  $(docker compose version)
   Repositório:      ${repo_dir}

 Próximos passos:
   1. Editar ${repo_dir}/deploy/.env com o endpoint/chave do modelo Azure
   2. cd ${repo_dir}/deploy/compose
   3. docker compose --env-file ../.env -f docker-compose.yaml -f docker-compose.ask.yaml up -d
      (docker-compose.ask.yaml ainda será criado — troca o Azure AI Search
      pelo OpenSearch e adiciona o roteador de modelo; ver deploy/ask/README.md)
===================================================================
SUMMARY
