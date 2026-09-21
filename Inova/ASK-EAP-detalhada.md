# ASK — EAP Detalhada e Guia de Execução
## Como sair do papel: pacotes de trabalho pequenos, com passo a passo

| Campo | Valor |
|---|---|
| Documento | EAP + Guia de Execução — complementa o TAP |
| Uso | Cada pacote é independente e pode ser puxado por qualquer pessoa do time, mesmo sem o arquiteto por perto |
| Regra de ouro | Se um pacote não tem uma saída clara e verificável, ele não está pronto — ele só parece que está |

---

## Como ler este documento

Cada **fase macro** vira **pacotes de trabalho**. Cada pacote tem:
- **O quê** — o que precisa existir ao final
- **Como** — passo a passo mínimo para chegar lá
- **Responsável sugerido** — considerando quem já é dono do quê no TAP
- **Pronto quando** — o teste objetivo de que o pacote acabou, não uma sensação de "acho que terminei"

A Fase 0 está detalhada por completo, porque é o bloqueador de agora. As Fases 1-6 estão no nível de pacote (o suficiente para começar a dividir trabalho), e cada uma será detalhada como esta quando chegar sua vez — detalhar tudo agora seria planejar em cima de terreno que vocês ainda não pisaram.

---

## FASE 0 — Entender o blueprint NVIDIA AI-Q (esta semana)

> Objetivo desta fase: sair de "ouvi falar, li a documentação" para "já rodei localmente e sei onde cada peça mora". Nada de Azure ainda — isso é só para aprender o blueprint original, sem custo.

### Pacote 0.1 — Obter o material fonte
**O quê:** repositório do AI-Q clonado localmente, documentação lida.
**Como:**
1. Acessar `github.com/NVIDIA-AI-Blueprints/aiq` (confirmar que o nome/organização ainda é esse — blueprints da NVIDIA mudam de local ocasionalmente)
2. `git clone` do repositório
3. Ler o `README.md` inteiro, sem pular — anotar tudo que não fizer sentido de primeira, não travar tentando entender tudo sozinho
4. Acessar `docs.nvidia.com` e localizar a documentação do blueprint AI-Q (instalação, arquitetura)
**Responsável sugerido:** Jessica (ela já tinha ficado com "materiais prontos Microsoft" na ata — inverter para NVIDIA/documentação técnica faz sentido dado o foco agora)
**Pronto quando:** repositório clonado na máquina, e a pessoa consegue explicar em 3 frases, sem consultar nada, o que o AI-Q faz.

### Pacote 0.2 — Identificar o modelo de instalação
**O quê:** clareza sobre as três formas de rodar o AI-Q (Docker Compose, Helm, NVIDIA Launchable) e qual usar em cada momento do projeto.
**Como:**
1. Localizar no repositório a pasta/arquivo de instalação via Docker Compose
2. Localizar a pasta/arquivo do Helm chart (`aiq2-web`)
3. Anotar: Docker Compose = bom para aprender local, sem custo de cloud. Helm = o que vocês vão usar de verdade no Azure mais adiante. NVIDIA Launchable = ambiente pronto de um clique, útil só para "ver funcionando" rápido, não para o MVP.
4. Decidir: para esta fase (aprendizado), usar **Docker Compose local**
**Responsável sugerido:** João
**Pronto quando:** o time consegue responder "qual desses três eu uso para quê" sem hesitar.

### Pacote 0.3 — Rodar localmente (modo demo)
**O quê:** o AI-Q rodando na máquina de alguém do time, mesmo que com modelo de exemplo/gratuito, só para ver o fluxo funcionando de ponta a ponta.
**Como:**
1. Verificar os requisitos mínimos no README (Docker instalado, versão mínima, alguma chave de API se o exemplo pedir)
2. Subir o ambiente conforme instrução do Docker Compose
3. Acessar a interface local (geralmente `localhost` em alguma porta)
4. Fazer uma pergunta simples pela interface e observar a resposta
**Responsável sugerido:** João (dá sequência ao pacote 0.2)
**Pronto quando:** uma pergunta simples feita na UI local retorna uma resposta, mesmo que genérica. Se travar em erro de ambiente por mais de 1h, parar e trazer para o grupo — não é para resolver sozinho indefinidamente.

### Pacote 0.4 — Mapear a configuração (YAML)
**O quê:** entender onde e como o comportamento do AI-Q é definido sem mexer em código.
**Como:**
1. Localizar o(s) arquivo(s) YAML de configuração do workflow
2. Para cada seção do YAML, escrever numa frase o que ela controla: qual modelo é chamado, qual fonte de dados é usada, qual política de execução está ativa
3. Identificar especificamente onde fica definido: orchestration node (classificador/roteador), shallow research agent, deep research agent
4. Testar uma mudança pequena e segura no YAML (ex.: trocar um texto de exemplo) e confirmar que o comportamento muda ao reiniciar
**Responsável sugerido:** Jessica
**Pronto quando:** existe uma lista simples (pode ser uma nota, não precisa ser documento formal) de "o que cada parte do YAML faz", e a pessoa já editou o YAML pelo menos uma vez e viu o efeito.

### Pacote 0.5 — Skills, fontes de dados e acessos
**O quê:** entender como o AI-Q se conecta a fontes externas (bases de conhecimento, ferramentas, credenciais) — essa é a parte que vocês vão adaptar de verdade para o fabricante piloto.
**Como:**
1. Localizar a documentação de "pluggable data sources" — como uma nova fonte de dados é registrada
2. Localizar onde ficam as credenciais/chaves de acesso no exemplo (variável de ambiente, arquivo `.env`, secret)
3. Entender a diferença entre "skill" (o que um agente sabe fazer) e "fonte de dados" (de onde ele busca informação)
4. Anotar: isso aqui é literalmente onde o fabricante piloto vai entrar depois
**Responsável sugerido:** Robson (esta parte conecta direto com a decisão de arquitetura D2 — hospedagem sem NIM — então precisa do olhar de quem já tomou essa decisão)
**Pronto quando:** o time consegue apontar exatamente qual arquivo/seção vai precisar mudar quando conectarem a base do fabricante piloto.

### Pacote 0.6 — Compartilhar o aprendizado
**O quê:** o que cada um aprendeu nos pacotes 0.1-0.5 vira conhecimento do time inteiro, não conhecimento isolado de quem executou.
**Como:**
1. Reunião curta (pode ser a sexta-feira normal) onde cada pessoa mostra o que rodou/descobriu, ao vivo se possível
2. Cada um escreve 5 linhas de notas: "o que entendi, o que não entendi, onde travei"
**Responsável sugerido:** todos; Robson consolida
**Pronto quando:** as três pessoas conseguem, individualmente, explicar o diagrama do ASK Blueprint (já produzido) apontando para o código/config real, não só para o desenho.

---

## FASE 1 — Adaptar a camada de modelo (sem NIM, Azure gerenciado)

| Pacote | O quê | Responsável | Pronto quando |
|---|---|---|---|
| 1.1 | Acesso Azure confirmado/provisionado (deployment de modelo gerenciado) | Robson | Existe um endpoint de modelo respondendo a uma chamada de teste simples (fora do AI-Q ainda, só validando o Azure) |
| 1.2 | Localizar no YAML (mapeado no pacote 0.4) onde trocar o modelo/endpoint da NVIDIA pelo endpoint Azure | Robson | Uma chamada simples do AI-Q local já responde usando o modelo do Azure, não mais o modelo de exemplo |
| 1.3 | Documentar a troca como nota técnica curta (o que mudou, onde) | Quem executou | Outra pessoa do time consegue repetir a troca sozinha lendo a nota |

---

## FASE 2 — Conectar o fabricante piloto

| Pacote | O quê | Responsável | Pronto quando |
|---|---|---|---|
| 2.1 | Fabricante piloto confirmado (já delegado) | João | Nome definido, contato de pré-vendas/arquitetura identificado |
| 2.2 | Levantar documentação técnica + regras comerciais do fabricante em formato consultável (mesmo que planilha/pasta organizada) | João | Existe uma pasta/fonte única com o material do fabricante, sem estar espalhado |
| 2.3 | Registrar essa fonte como "pluggable data source" no AI-Q, seguindo o que foi mapeado no pacote 0.5 | Jessica | Uma pergunta sobre o fabricante retorna resposta usando esse material, com fonte citada |
| 2.4 | Testar com 5 perguntas reais do dataset (a ser levantado) | Jessica | Pelo menos 3 das 5 respostas são consideradas corretas por quem conhece o fabricante |

---

## FASE 3 — Classificador, orquestrador e agente pré-vendas para o caso ScanSource

| Pacote | O quê | Responsável | Pronto quando |
|---|---|---|---|
| 3.1 | Ajustar o classificador para reconhecer o domínio de pré-vendas ScanSource (vs. fora de escopo) | Jessica | Uma pergunta fora do escopo (ex.: "preço de revista") é corretamente descartada |
| 3.2 | Configurar o agente pré-vendas (shallow research) para responder sobre o fabricante piloto | Robson | Resposta correta e citada para pergunta de produto/preço simples |
| 3.3 | Configurar a regra do avaliador (rejeita resposta sem fonte) | Robson | Uma resposta sem fonte é de fato barrada e reformulada, testado propositalmente |

---

## FASE 4 — Onboarding self-service (formulário de intake)

| Pacote | O quê | Responsável | Pronto quando |
|---|---|---|---|
| 4.1 | Desenhar os campos mínimos do formulário (nome do fabricante, localização dos docs, tipo de regra comercial, contato) | João | Lista de campos validada com o próprio time (dogfooding) |
| 4.2 | Implementar o formulário materializando um novo nó/base sem código | João + Jessica | Um segundo fabricante é onboardado só preenchendo o formulário |
| 4.3 | Testar com pessoa de fora do time técnico preenchendo | Robson coordena | Alguém que não é do time de 3 consegue preencher sem ajuda |

---

## FASE 5 — Validação

| Pacote | O quê | Responsável | Pronto quando |
|---|---|---|---|
| 5.1 | Rodar com solicitações reais não usadas no desenvolvimento | Todos | Taxa de acerto registrada, mesmo que informalmente |
| 5.2 | Coletar feedback de um pré-vendas real | João | Feedback documentado, positivo ou não |
| 5.3 | Preencher Canvas Financeiro com custo real medido | João | Documento fechado com números reais, não estimativas |

---

## FASE 6 — Ajustes finais e pitch

| Pacote | O quê | Responsável | Pronto quando |
|---|---|---|---|
| 6.1 | Ajustes de MVP conforme feedback da Fase 5 | Todos | — |
| 6.2 | Fechar Plano de Escala | Jessica | Documento já rascunhado, só precisa validar contra o que foi aprendido |
| 6.3 | Ensaiar o pitch de 30 min + Q&A | Todos | Ensaio cronometrado feito pelo menos uma vez antes do dia |

---

## Nota para Jessica e João

Vocês não precisam entender o AI-Q inteiro para começar — ninguém entende um sistema assim de uma vez. A Fase 0 existe justamente para isso: cada pacote é pequeno o suficiente para travar, pedir ajuda, e seguir. Se um pacote tomar muito mais tempo que as 2h da semana, isso não é sinal de que vocês estão fazendo errado — é sinal de trazer para o grupo na sexta-feira e ajustar o pacote, não empurrar sozinho.

O critério "pronto quando" de cada pacote existe para vocês mesmos saberem quando parar — sem isso, é fácil ficar mexendo em algo que já está bom o suficiente, achando que falta mais.
