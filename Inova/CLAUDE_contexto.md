# CLAUDE.md — Contexto do Projeto ASK

Este arquivo é lido automaticamente pelo Claude Code no início de cada sessão neste repositório. Ele existe para que qualquer sessão — de qualquer pessoa do time — comece com o mesmo contexto, sem precisar reexplicar o projeto do zero.

---

## O que é o projeto

**ASK** (Agentic Solution & Knowledge) é um blueprint de estrutura agêntica para orquestração de agentes sobre bases de conhecimento dispersas, desenvolvido dentro do programa de inovação interna **INOVA 3.0** da ScanSource Brasil.

**ASK Revendas** é a aplicação concreta desse blueprint: um MVP de pesquisa de produtos, soluções e precificação, cobrindo o portfólio de 500+ fabricantes distribuídos pela ScanSource, começando por **um fabricante piloto**.

**Regra de ouro do projeto:** tudo que este código faz deve ser rastreável a um blueprint documentado. Se você (Claude Code) estiver implementando algo que não existe em `/docs/ASK-EAP-detalhada.md` ou nos ADRs, pare e pergunte antes de prosseguir — não é para inventar escopo novo.

---

## Time e capacidade

| Papel | Pessoa | Nível |
|---|---|---|
| Arquiteto / líder | Robson Sanchez | Solution Architect |
| Integração de dados | João Andrade | N1, início de carreira |
| Qualidade e escala | Jessica Magalhães | N1, início de carreira |

**Capacidade real:** ~2h/semana por pessoa, cadência de sexta-feira. **Demo Day: 23/11/2026.**

**Implicação prática para o Claude Code:** João e Jessica são juniores. Código gerado ou revisado para eles deve vir com explicação do porquê, não só do quê — eles vão precisar sustentar o que entregam sozinhos, sem o arquiteto por perto o tempo todo. Prefira soluções legíveis e bem comentadas a soluções elegantes porém opacas.

---

## Arquitetura de referência

Adaptação do blueprint **AI-Q da NVIDIA** (`github.com/NVIDIA-AI-Blueprints/aiq`, LangGraph-based). Confirme sempre contra o README atual do repositório antes de assumir comandos ou estrutura — blueprints da NVIDIA mudam com frequência.

### Fluxo (versão simplificada usada no ASK)

```
Usuário (pré-vendas) → Classificador → Orquestrador
                                            │
                            ┌───────────────┴───────────────┐
                            ▼                                ▼
                    Agente Pré-vendas                Agente Arquiteto
                    (produto, preço,                 (cenário técnico —
                     disponibilidade)                 ROADMAP, não ativo no MVP)
                            │
                            ▼
                Base de conhecimento do fabricante piloto
                  (documentação técnica + regras comerciais)
                            │
                            ▼
                     Avaliador de resposta
              (rejeita resposta sem fonte citada — regra dura)
                            │
                            ▼
              Resposta final + citação da fonte consultada
```

Diagramas completos (blueprint total vs. subconjunto ativado no MVP) estão em `/docs/ask-blueprint-diagram.png` e `/docs/ask-revendas-mvp-diagram.png`.

### Nós do AI-Q original e status de uso no ASK

| Nó do AI-Q | Usado no ASK? |
|---|---|
| Orchestration node | Sim — vira o Classificador + Orquestrador |
| Shallow research agent | Sim — vira o Agente Pré-vendas |
| Deep research agent | Roadmap — vira o Agente Arquiteto, não ativo no MVP |
| Workflow configuration (YAML) | Sim — ponto de extensão usado para trocar modelo sem NIM |
| Pluggable data sources | Sim — é onde entra a base do fabricante piloto |
| MCP integration | Não avaliado ainda |
| Skills e sandbox execution | Não usado no MVP |
| Durable generated files | Não usado no MVP |
| Evaluation harnesses (FreshQA/DeepResearch) | Não usado — o "avaliador" do ASK é uma regra simples (exige citação), não o harness completo da NVIDIA |

---

## Decisões de arquitetura (não reabrir sem justificativa nova)

| # | Decisão | Motivo |
|---|---|---|
| D1 | Nome do blueprint: **ASK**. Nome do MVP: **ASK Revendas** | Evita fricção de marca com "AI-Q" da NVIDIA fora do hackathon |
| D2 | Hospedagem via **modelo gerenciado nativo de cloud (Azure), sem NIM** | Funciona mesmo sem o cliente ter licença NVIDIA AI Enterprise — maior ponto de adaptação do blueprint original |
| D3 | Demo ao vivo em **Azure**; **OCI é portabilidade documentada**, não deploy ao vivo | Sustenta a tese de agnosticismo sem duplicar esforço de infra em 6 semanas |
| D4 | Custo do MVP é **por hora de compute + modelo gerenciado**, não por token | Mais previsível para o Canvas Financeiro e para precificar contrato com revenda |
| D5 | Uso de oferta Adobe para a base documental — **decisão aberta**, não altera o blueprint (nó pluggable) | Ver `/areas/inova-ask.md` para status atualizado |
| D6 | **Modelo de propriedade federado**: cada base de conhecimento é mantida pelo time do fabricante correspondente, nunca pelo time central de 3 pessoas | Só assim a solução escala para 500+ fabricantes. Consequência direta: onboarding de novo fabricante **precisa ser self-service, sem YAML nem código** — ver Fase 4 do EAP |
| D7 | Orquestrador nunca contém regra de negócio | Regra de negócio mora na base de conhecimento do fabricante. Se a tradução entre nós começar a ficar complexa no código, o sinal é que o modelo de dados do produtor está errado — corrige-se lá, não no orquestrador |
| D8 | Saída do avaliador é sempre "aceita com fonte citada" ou "rejeita e reformula" — nunca resposta sem proveniência | Proveniência é requisito do produto, não feature opcional |

---

## Stack técnica

- **Orquestração:** LangGraph (herdado do AI-Q)
- **Configuração:** YAML — modelos, fontes de dados, política de execução, sem alteração de código para trocar componentes
- **Modelo de inferência:** deployment de modelo gerenciado no **Azure AI Foundry** (não NIM, não self-hosted em GPU própria)
- **Fonte de dados do MVP:** base do fabricante piloto — documentação técnica + regras comerciais (formato a definir no Pacote 2.2 do EAP)
- **Portabilidade:** o mesmo Helm chart deve funcionar trocando só o endpoint de modelo e o backend de dados para OCI — não codar nada Azure-specific fora da camada de configuração

---

## Onde estamos agora (atualizar a cada marco)

> ⚠️ Esta seção precisa ser mantida atualizada manualmente. Se estiver desatualizada, confie no `/docs/ASK-EAP-detalhada.md` e pergunte ao time.

- **Fase atual:** Fase 0 — entendimento do blueprint AI-Q (clonar, rodar local via Docker Compose, mapear YAML, mapear pluggable data sources)
- **Bloqueadores conhecidos:** decisão Adobe (D5) ainda aberta; fabricante piloto pendente de confirmação; acesso Azure pendente de provisionamento
- **Não iniciado ainda:** qualquer código de produção — a Fase 0 é só exploração do blueprint original, sem Azure envolvido

Consulte `/docs/ASK-EAP-detalhada.md` para o detalhamento completo de cada fase e pacote de trabalho.

---

## Convenções para o Claude Code neste repositório

1. **Nunca ativar/chamar NIM ou infraestrutura de GPU própria.** Toda inferência passa pelo endpoint de modelo gerenciado do Azure (D2). Se um exemplo do AI-Q original usar NIM, adapte para a camada de modelo antes de rodar.
2. **Nunca hardcode regra de negócio no orquestrador.** Regra comercial (preço, licenciamento, condição) vive na base de conhecimento do fabricante, nunca em código de roteamento (D7).
3. **Toda resposta gerada pelo fluxo precisa citar fonte.** Se você estiver implementando o avaliador, a regra "sem fonte = rejeita" não é negociável (D8).
4. **Onboarding de fabricante não pode exigir edição manual de YAML ou código.** Se estiver implementando o formulário de intake (Fase 4), o critério de pronto é: alguém de fora do time técnico consegue usar sem ajuda.
5. **Não adicionar dependência de licenciamento NVIDIA AI Enterprise.** Isso contradiz D2 e quebra a tese de vendas do produto.
6. **Comente o código pensando em leitura por júnior**, especialmente em partes que envolvem configuração YAML e lógica de roteamento — João e Jessica vão manter isso sozinhos.
7. **Antes de assumir um comando ou estrutura do AI-Q original, confira contra o README atual do repositório clonado** — não repita de memória o que está descrito aqui sem checar, porque o blueprint evolui.
8. **Escopo fora do MVP (não implementar sem decisão explícita do time):** agente arquiteto (deep research), suporte multi-fabricante simultâneo, deploy self-hosted via NIM, discovery automatizado de infraestrutura do cliente, geração automática de código em sistemas de terceiros.

---

## Documentos de referência (fora deste repositório de código)

- Termo de Abertura de Projeto (TAP) — governança, escopo, riscos
- Business Plan ASK — modelo de negócio, mercado, diferenciação
- EAP Detalhada — pacotes de trabalho fase a fase, com "pronto quando" objetivo
- Diagramas de arquitetura (blueprint completo e MVP)

Se uma decisão de código conflitar com algo nesses documentos, o documento vence — atualize o documento junto com o código, não deixe divergir silenciosamente.
