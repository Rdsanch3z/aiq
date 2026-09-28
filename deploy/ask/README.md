# deploy/ask/

Overlay específico do projeto **ASK** sobre o blueprint AI-Q original da NVIDIA.
Nada aqui faz parte do upstream — é a camada de adaptação descrita na
documentação técnica do blueprint ASK (pasta "ASK documentação").

| Arquivo | Para quê |
|---|---|
| `one-click-install.sh` | Provisiona uma VM Linux (Ubuntu/Debian) do zero: Docker Engine + Compose, firewall, ajuste de kernel para o OpenSearch, clona o repositório e prepara o `.env` |
| `docker-compose.ask.yaml` | Override sobre `deploy/compose/docker-compose.yaml`: troca Azure AI Search por OpenSearch, adiciona o gateway de modelo (LiteLLM) e o Caddy (TLS automático); fecha as portas 8000/3000 do host |
| `litellm.yaml` | Roteia os 2 deployments de modelo + 1 de embeddings do Azure atrás de um único endpoint OpenAI-compatible |
| `Caddyfile` | Proxy reverso + TLS automático (Let's Encrypt quando `ASK_DOMAIN` é um domínio real) |
| `.env.ask.example` | Variáveis adicionais a colar dentro de `deploy/.env` (ver instruções no próprio arquivo) |
| `configs/config_ask.yml` *(na raiz do repo, não aqui)* | Perfil de workflow: 2 deployments de modelo, backend OpenSearch, sem busca na internet |

## Como subir

```bash
sudo bash deploy/ask/one-click-install.sh          # 1. provisiona o host
cp deploy/.env.example deploy/.env                 # 2. se ainda não existir
cat deploy/ask/.env.ask.example                     # 3. cole o conteúdo em deploy/.env e preencha
cd deploy/ask && edit litellm.yaml                  # 4. troque os 3 placeholders pelos nomes reais dos deployments Azure
cd ../compose
docker compose --env-file ../.env \
  -f docker-compose.yaml -f ../ask/docker-compose.ask.yaml up -d
```

Por que uma pasta separada em vez de editar `deploy/compose/docker-compose.yaml`
ou `configs/config_web_opensearch.yml` direto: mantém o upstream intacto,
então uma atualização futura do blueprint original (`git pull` de cima) não
gera conflito com a adaptação do ASK.

## Decisões registradas

- **RAG Blueprint da NVIDIA** (`github.com/NVIDIA-AI-Blueprints/rag`, backend
  `foundational_rag`) não é usado aqui — exige GPU/NIM próprio ou
  dependência de infraestrutura hospedada da NVIDIA, o que contradiz a
  decisão de hospedagem 100% Azure sem NIM. Fica documentado como opção de
  roadmap, não ativada.
- **OpenSearch sem plugin de segurança** (`DISABLE_SECURITY_PLUGIN=true`):
  aceitável apenas porque o serviço não publica porta nenhuma para o host —
  só é alcançável de dentro da rede Docker interna. Se algum dia o
  OpenSearch precisar ser acessado de fora desse container (outra VM, por
  exemplo), trocar para `opensearch_auth_type: basic` com usuário/senha
  antes de expor qualquer porta.
- **`NVIDIA_API_KEY` como workaround para a chave de embeddings**: o
  adapter OpenSearch do AI-Q só lê essa variável para autenticar a chamada
  de embeddings, mesmo com `embed_base_url` apontando para o LiteLLM (ver
  `.env.ask.example`). Funciona, mas é uma dívida técnica pequena — o
  patch correto é adicionar um `AIQ_EMBED_API_KEY` próprio no adapter.
- **Versões fixadas (`git pull` deste repositório não muda essas versões
  sozinho — revisitar periodicamente):**
  - OpenSearch `2.19.6` — linha 2.x mais recente; a 3.x já existe mas não
    está validada contra o cliente que o AI-Q usa.
  - LiteLLM `v1.90.2` — conforme a própria documentação oficial do
    LiteLLM recomenda (pinar versão, nunca `latest`).
  - Caddy `2-alpine` — tag flutuante oficialmente recomendada pelo próprio
    Caddy para sempre pegar o último patch da major 2.
