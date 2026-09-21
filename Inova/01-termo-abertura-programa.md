# Termo de Abertura do Programa
## Agentic Process Solver

| Campo | Valor |
|---|---|
| **Documento** | 01 — Termo de Abertura do Programa (Program Charter) |
| **Versão** | 0.1 — Rascunho para aprovação |
| **Data** | 31 de agosto de 2026 |
| **Patrocinador / CIO** | Robson |
| **Gerente do Programa** | Robson |
| **Status** | Aguardando aprovação |

---

## 1. Justificativa do Programa

Empresas e departamentos com múltiplos sistemas enfrentam um gargalo recorrente na autorização e execução de processos. O diagnóstico comum atribui o problema à escassez de desenvolvedores, mas a causa raiz é anterior: **falta de conhecimento consolidado sobre o que já existe** — qual sistema é fonte da verdade, quais integrações já resolvem parcialmente o caso de uso, e o quanto a documentação de processo diverge do comportamento real em produção.

Ferramentas low-code atacam a etapa de construção, não a de descoberta. Consultorias tradicionais atacam a descoberta, mas com custo e prazo incompatíveis com departamentos de médio porte.

O programa propõe uma família de produtos agênticos que ataca a descoberta primeiro, e só depois a construção — sempre por integração e composição, nunca por reescrita de aplicações existentes.

---

## 2. Objetivo do Programa

Desenvolver e comercializar uma família de cinco produtos agênticos independentes, que operam isoladamente e ganham valor combinado quando integrados por um orquestrador.

### Componentes do programa

| # | Componente | Natureza |
|---|---|---|
| 0 | Fundação de dados (grafo/modelo canônico) | Habilitador, não vendável isoladamente |
| 1 | Agente de Discovery de Infraestrutura | Produto |
| 2 | Catálogo de Conexões | Produto |
| 3 | AI-Q para Processos | Produto (núcleo de valor) |
| 4 | AI-Dev-Q (Implementador) | Produto |
| 5 | Orquestrador Master | Produto de integração |

**Princípio arquitetural do programa:** cada componente publica seu próprio modelo de entrada e saída, opera de forma autônoma, e não se comunica diretamente com os demais. A integração é responsabilidade exclusiva do componente 5.

**Princípio de design do produto:** *colcha de retalhos bem feita* — integrar e documentar o que existe, em vez de substituir.

---

## 3. Benefícios Esperados

| Benefício | Indicador | Prazo |
|---|---|---|
| Redução do tempo de diagnóstico de ambiente | Semanas → dias | Componente 1 |
| Documentação de processo confiável e rastreável | % de afirmações com proveniência | Componente 3 |
| Redução de dependência de time de desenvolvimento | Nº de soluções entregues sem alocação de dev | Componente 4 |
| Receita recorrente | Contratos-piloto assinados | A partir do primeiro cliente |

---

## 4. Escopo de Alto Nível

### Dentro do escopo do programa
- Cinco produtos conforme seção 2
- Discovery read-only de ambientes cloud e on-premises
- Ingestão e reconciliação de documentação de processo (Visio, draw.io, BPMN, texto, transcrições)
- Geração de artefatos revisáveis por humanos
- Aprovação humana obrigatória antes de qualquer escrita em ambiente de cliente

### Fora do escopo do programa
- Escrita automática em ambiente de produção sem aprovação humana registrada
- Reescrita ou substituição de aplicações existentes do cliente
- Armazenamento de credenciais de cliente (registra-se o método de autenticação, nunca o valor)
- Auto-modificação de grafos de execução agêntica pelo orquestrador (v1)
- Desenvolvimento de ferramentas low-code próprias (utiliza-se o ferramental já presente no cliente)

---

## 5. Premissas

> ⚠️ **Premissas marcadas com [DECISÃO] exigem confirmação do patrocinador antes da aprovação deste documento.**

| # | Premissa |
|---|---|
| P1 | **[DECISÃO]** "Produto vendável em 3 meses" é redefinido como **prova de conceito demonstrável, suficiente para contratar um cliente-piloto que financie a construção do produto completo**. Ver seção 7. |
| P2 | O AI-Q Blueprint da NVIDIA é utilizado como referência arquitetural e ponto de partida, não como dependência de produto |
| P3 | Infraestrutura de desenvolvimento própria (workstation com GPU) é suficiente para prototipagem; custos de cloud são incorridos apenas em validação com cliente |
| P4 | Clientes-alvo possuem ferramental low-code já licenciado (APEX, Power Platform ou equivalente) |
| P5 | Não haverá contratação de equipe durante a fase 1 do programa |

---

## 6. Restrições

| # | Restrição | Impacto |
|---|---|---|
| R1 | **Recurso único** — patrocinador, gerente e executor são a mesma pessoa | Sem paralelismo real entre componentes; escopo de equipe precisa ser reduzido a escopo de indivíduo |
| R2 | **10 horas semanais** | ~40h/mês, ~120h por trimestre. Capacidade total do programa é a variável mais escassa |
| R3 | Orçamento de capital limitado; sem investimento externo na fase inicial | Preferência obrigatória por infraestrutura local e ferramental open-source |
| R4 | Ausência de revisão por pares | Mitigado por registro de decisões de arquitetura (ADR) e critérios de aceite explícitos |

**Consequência declarada da restrição R2:** a capacidade do programa (~120h/trimestre) é incompatível com a entrega de cinco produtos completos em qualquer horizonte curto. O programa é explicitamente estruturado para **parar em um gate** caso a validação comercial não ocorra — ver seção 8.

---

## 7. Marcos do Programa

| Marco | Entrega | Estimativa |
|---|---|---|
| **M0** | Documentação de programa aprovada (docs 1–5) | Mês 1 |
| **M1** | Fundação de dados (componente 0) + fatia vertical do discovery (Azure, read-only) | Mês 3 |
| **M2** | **Gate comercial** — demonstração a cliente-piloto potencial | Mês 3–4 |
| **M3** | Componente 1 completo (cloud + on-prem), financiado ou não conforme M2 | Mês 9 |
| **M4** | Componente 3 (AI-Q para Processos) — maior valor comercial isolado | A definir |
| **M5** | Componente 2a; **marco de produto read-only completo** | A definir |
| **M6** | Componentes 4 e 5 | A definir |

Marcos M4 em diante permanecem sem data até a conclusão do gate M2. Estimar além do primeiro ponto de validação seria ficção de planejamento.

---

## 8. Critérios de Sucesso e Critérios de Parada

### Sucesso do programa (fase 1)
- Prova de conceito do componente 1 demonstrada em ambiente real
- Ao menos um cliente-piloto formalizado até o mês 6
- Fundação de dados (componente 0) estável o suficiente para suportar o componente 3 sem reescrita

### Critérios de parada — o programa é suspenso se:
- Nenhum cliente-piloto for formalizado até o mês 9
- A dedicação real cair consistentemente abaixo de 5h semanais por dois meses
- Surgir solução comercial equivalente com adoção significativa no mercado-alvo

> A existência de critérios de parada explícitos é intencional. Em operação solo, o custo de um programa que não termina nem avança é maior que o de um encerramento deliberado.

---

## 9. Riscos Iniciais de Alto Nível

| # | Risco | Severidade |
|---|---|---|
| RK1 | Capacidade de execução insuficiente para o escopo declarado | **Alta** |
| RK2 | Ponto único de falha — indisponibilidade do recurso único paralisa o programa | Alta |
| RK3 | Autorização para discovery em ambiente de cliente é obstáculo político, não técnico | Média |
| RK4 | Ambientes legados sem API exigem coleta humana, reduzindo o grau de automação prometido | Média |
| RK5 | Custo de inferência escala com o tamanho do ambiente do cliente, comprometendo margem | Média |
| RK6 | Entrada de player estabelecido (hyperscaler ou consultoria) no mesmo nicho | Média |

Registro detalhado será mantido no documento 10.

---

## 10. Governança

| Aspecto | Definição |
|---|---|
| Papel de decisão | CIO (patrocinador) — decisões de gate, escopo e parada |
| Papel de execução | Gerente de Programa / Executor técnico |
| Cadência de revisão | Revisão de marco a cada gate; revisão de capacidade mensal |
| Gestão de mudança de escopo | Toda alteração de escopo registrada como ADR, com impacto em capacidade declarado |
| Registro de decisões | ADR mantido continuamente (documento 9) |

> Nota sobre acúmulo de papéis: patrocinador e executor sendo a mesma pessoa elimina o contraditório natural da governança. Mitigação adotada: critérios de parada declarados **antecipadamente** neste documento, avaliados contra evidência e não contra intenção.

---

## 11. Aprovação

| Papel | Nome | Decisão | Data |
|---|---|---|---|
| Patrocinador / CIO | Robson | ☐ Aprovado ☐ Aprovado com ressalvas ☐ Rejeitado | |

**Pendências para aprovação:**
1. Confirmar ou substituir a premissa **P1** (definição de "vendável em 3 meses")
2. Confirmar os critérios de parada da seção 8
3. Confirmar a ordem dos marcos M3–M6
