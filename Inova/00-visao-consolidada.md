# Agentic Process Solver — Visão Consolidada do Programa

| Campo | Valor |
|---|---|
| **Documento** | 00 — Visão Consolidada (documento de alinhamento) |
| **Versão** | 0.1 |
| **Data** | 31 de agosto de 2026 |
| **Status** | Referência viva — atualizado a cada decisão de arquitetura |

> Este documento existe para colocar qualquer pessoa (cliente-piloto, sócio potencial, ou você mesmo daqui a seis meses) na mesma página em uma leitura. Não substitui o Termo de Abertura nem os documentos de escopo.

---

## 1. O problema

Empresas com muitos sistemas travam na autorização e execução de processos. O diagnóstico usual culpa a falta de desenvolvedores. **A causa raiz é anterior: ninguém sabe o que já existe.**

Sintomas concretos:
- Qual sistema é a fonte da verdade para um dado — ninguém sabe com certeza
- Qual integração já resolve 80% do caso de uso — ninguém lembra
- O processo desenhado no Visio há três anos — não reflete o que roda em produção

Ferramentas low-code atacam a construção, não a descoberta. Consultoria tradicional ataca a descoberta, com custo e prazo incompatíveis com departamentos de médio porte.

---

## 2. A solução

Uma família de **cinco produtos agênticos independentes** que ataca a descoberta primeiro e a construção depois, sempre por integração e composição.

**Princípio de design:** *colcha de retalhos bem feita*. Integrar e documentar o que existe, nunca reescrever aplicações existentes.

**Princípio arquitetural:** cada produto publica seu próprio modelo de entrada/saída, opera de forma autônoma, e **não se comunica diretamente com os demais**. A integração é responsabilidade exclusiva do orquestrador.

---

## 3. Diagrama do blueprint

```
┌───────────────────────────────────────────────────────────────────────────┐
│                          AMBIENTE DO CLIENTE                                    │
│                                                                                    │
│   Cloud (Azure/OCI/GCP/AWS)    On-premises    Docs de processo    Pessoas       │
│   Resource graphs, APIs         CMDB, rede     Visio, drawio,      Entrevistas   │
│                                                  BPMN, POPs                        │
└──────┬──────────────────────┬──────────────────┬──────────────────┬───────┘
        │  somente leitura       │  somente leitura  │  ingestão         │ estruturada
        ▼                        ▼                    ▼                    ▼
┌──────────────────────┐  ┌───────────────────┐  ┌──────────────────────────┐
│  ① DISCOVERY            │  │  ②a CATÁLOGO DE     │  │  ③ AI-Q PARA PROCESSOS      │
│     DE INFRAESTRUTURA   │  │     CONEXÕES         │  │                              │
│                          │  │                      │  │  Ingere, entende,             │
│  Inventaria sistemas,    │  │  Caracteriza COMO    │  │  reconcilia, redesenha        │
│  conexões, lacunas       │  │  conectar em cada    │  │  e documenta processos        │
│                          │  │  sistema             │  │                              │
│  SAÍDA: nós System +     │  │                      │  │  SAÍDA: processo             │
│  Connection, relatório   │  │  SAÍDA: perfil de    │  │  reconciliado, mapa de       │
│  de divergência c/ CMDB  │  │  conectividade,      │  │  divergências, proposta      │
│                          │  │  mapa de sobreposição│  │  de redesenho, BPMN + doc    │
│  🔒 READ-ONLY            │  │  🔒 READ-ONLY        │  │  🔒 NÃO IMPLEMENTA NADA      │
└──────────┬───────────┘  └────────┬──────────┘  └──────────┬───────────────┘
            │                          │                        │
            │  ┌───────────────────┴────────────────────┘
            │  │
            ▼  ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  ⓪ GRAFO CORPORATIVO  (fundação — não é agente, não é vendável isolado)       │
│                                                                                 │
│   System ── Connection ── Process ── DataFlow ── Divergence ── Evidence         │
│                                                                                 │
│   • Toda afirmação carrega proveniência, timestamp e confiança                  │
│   • Versionado: o grafo de hoje vs. o de 3 meses atrás é a prova de valor       │
│   • Chaves naturais estáveis (FQDN, resource ID) — habilitam resolução de       │
│     identidade entre produtos                                                   │
└───────────────────────────────────────────────────────────────────────────┘
                                    ▲
                                    │ lê o contexto aprovado
                                    │
                    ╔═══════════════╧═══════════════╗
                    ║   ✋ APROVAÇÃO HUMANA           ║   ← fronteira read-only
                    ║   Obrigatória, registrada,      ║      Nada à direita/abaixo
                    ║   nó de primeira classe          ║      acontece sem isto
                    ╚═══════════════╤═══════════════╝
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  ④ AI-DEV-Q — IMPLEMENTADOR                                                     │
│                                                                                 │
│   ┌─ construir PRIMEIRO ─────────┐   ┌─ construir DEPOIS ───────────────┐   │
│   │  CAMADA DE VALIDAÇÃO           │   │  CAMADA DE GERAÇÃO                 │   │
│   │  • sandbox obrigatório          │   │  • módulos de conexão (ex-2b)      │   │
│   │  • testes de contrato vs. ②a    │   │  • low-code: APEX, Power Apps      │   │
│   │  • diff legível por humano      │   │  • scripts, ETL, fluxos            │   │
│   └───────────────────────────┘   └────────────────────────────────┘   │
│                                                                                 │
│   SAÍDA: artefato revisável (PR, pacote com rollback, app em sandbox)           │
│   ⛔ NUNCA escreve direto em produção                                            │
└───────────────────────────────────────────────────────────────────────────┘


        ═══════════════════ CAMADA DE INTEGRAÇÃO ═══════════════════

┌───────────────────────────────────────────────────────────────────────────┐
│  ⑤ ORQUESTRADOR MASTER                                                          │
│                                                                                 │
│      ①  ←──┐                                                                    │
│      ②a ←──┤                                                                    │
│      ③  ←──┼── único caminho de comunicação entre produtos                      │
│      ④  ←──┘   (produtos NUNCA se falam diretamente, por design)                │
│                                                                                 │
│   FAZ:                                    NÃO FAZ:                              │
│   • roteamento entre produtos             • regra de negócio                    │
│   • tradução de formato                   • gerar/modificar os próprios         │
│   • resolução de identidade                 grafos de execução (v1)             │
│   • estado e retomada de fluxos longos                                          │
│   • checkpoints de aprovação humana       ⚠️ Se a tradução ficar complexa,       │
│   • tracing de decisão fim a fim             o modelo de entrada do produto      │
│   • controle de custo e quota                receptor está errado — corrige-se   │
│   • compatibilidade entre versões            o produto, não o orquestrador       │
│     dos modelos de entrada                                                      │
└───────────────────────────────────────────────────────────────────────────┘
```

### Como ler o diagrama

- **Cada produto opera sozinho.** Sem orquestrador, o encadeamento é manual: exporta a saída de ①, importa em ③. Isso é modo de operação legítimo, não gambiarra — e valida os modelos de entrada com uso real antes de automatizar.
- **A fronteira de aprovação humana é o divisor de risco.** Tudo acima dela é read-only e não pode causar dano no ambiente do cliente. Tudo abaixo escreve.
- **O grafo (⓪) é o ativo real.** Os agentes são intercambiáveis; o grafo acumulado não é.

---

## 4. Decisões de arquitetura já tomadas

| # | Decisão | Justificativa |
|---|---|---|
| D1 | AI-Q Blueprint da NVIDIA é referência arquitetural, não dependência | O AI-Q é blueprint de pesquisa governada, não de coding agent. Aproveita-se o padrão (RAG multimodal, agent toolkit, observabilidade), não o produto |
| D2 | Componente 0 (grafo) existe como fundação separada | Sem modelo compartilhado, os cinco produtos trocam texto e o orquestrador vira camada de tradução |
| D3 | Geração de conectores movida de ②b para ④ | Gerar código com credenciais privilegiadas é risco de escrita — deve estar sob o mesmo regime de aprovação e sandbox do implementador |
| D4 | Contrato entre produtos = modelo de entrada publicado por cada produto | Mais desacoplado que ontologia global imposta; preserva soberania de cada produto |
| D5 | Produtos não se comunicam diretamente | Garante que a integração seja auditável e versionável em um único ponto |
| D6 | Orquestrador não contém regra de negócio | Evita o padrão ESB — mediador que vira monolito impossível de alterar |
| D7 | Orquestrador v1 não gera nem modifica os próprios grafos de execução | Auto-modificação é difícil de auditar e reverter; exige telemetria de produção antes |
| D8 | Camada de validação de ④ antes da camada de geração | Gerador sem harness de teste produz volume, não valor |
| D9 | Saída de ④ é sempre artefato revisável, nunca deploy automático | Público-alvo (departamento sem dev) não consegue auditar código gerado |
| D10 | Programa, não projeto único; ciclo de vida híbrido PMI | Cinco produtos com valor e ciclo de vida independentes é a definição de programa |

---

## 5. Sequenciamento

```
Fase 0   ⓪ Grafo + contrato mínimo de interoperação
Fase 1   ① Discovery  ─┐
          ③ Processos  ─┴─ podem ser paralelos
Fase 2   ②a Catálogo de conexões
          ══════ MARCO: produto read-only vendável ══════
          Até aqui: risco zero de escrita no cliente. Ponto natural de
          validação comercial antes de assumir o risco da fase seguinte.
Fase 3   ④ camada de validação
Fase 4   ④ camada de geração
Fase 5   ⑤ runtime de orquestração
Futuro   ⑤ geração de fluxos agênticos (só com telemetria real)
```

---

## 6. Restrições que moldam tudo

| # | Restrição | Consequência |
|---|---|---|
| R1 | Recurso único (patrocinador = executor) | Sem paralelismo real; sem contraditório de governança |
| R2 | ~10h/semana (~120h/trimestre) | Escopo de cinco produtos completos é incompatível com qualquer horizonte curto |
| R3 | Capital limitado, sem investimento externo | Infraestrutura local e open-source obrigatórios |

**Consequência declarada:** o programa é estruturado para **parar em um gate** se a validação comercial não ocorrer. Critérios de parada declarados antecipadamente no documento 01, avaliados contra evidência e não contra intenção.

---

## 7. Pontos de atenção transversais

1. **Proveniência é requisito, não feature.** Agente que afirma sem citar evidência destrói a confiança do produto — e confiança é o que se vende a quem não tem time técnico para verificar.
2. **Aprovação humana é nó do grafo, não checkbox.** Identidade de quem aprovou, timestamp e artefato exato.
3. **Discovery é questão política antes de ser técnica.** Autorização em ambiente corporativo tem lead time próprio.
4. **Legado sem API exige humanos.** Entrevista estruturada é entrada de primeira classe do ①, não exceção.
5. **Custo de inferência escala com o ambiente.** LLM só nas etapas de julgamento; coleta e normalização em código determinístico.
6. **AuthN/AuthZ é responsabilidade do deployer.** Lição herdada do AI-Q: o blueprint não cobre isso, e é onde os incidentes acontecem.

---

## 8. Estado da documentação do programa

| # | Documento | Status |
|---|---|---|
| 00 | Visão Consolidada | ✅ Este documento |
| 01 | Termo de Abertura do Programa | ⏳ Rascunho — 3 pendências de decisão |
| 02 | Business Case | ⬜ Não iniciado |
| 03 | Mapa de Benefícios e Roadmap | ⬜ Não iniciado |
| 04 | Plano de Governança | ⬜ Não iniciado |
| 05 | Registro de Premissas e Restrições | ⬜ Não iniciado |
| 06–08 | Escopo, EAP, Aceite (por componente) | ⬜ Não iniciado |
| 09 | Registro de Decisões de Arquitetura (ADR) | 🔄 Seção 4 é a semente |
| 10 | Registro de Riscos | ⬜ Não iniciado |
| 11 | Log de Marcos e Aprendizados | ⬜ Não iniciado |
