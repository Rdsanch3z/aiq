# INOVA 3.0 — Plano de Ação (Equipe 3: Robson, João, Jessica)
## ASK — Blueprint de Estrutura Agêntica de Consulta de Dados + ASK Revendas (MVP aplicado)

| Campo | Valor |
|---|---|
| Documento | Plano de Ação Segmentado — INOVA 3.0 |
| Time | Equipe 3 — Robson (líder), João Andrade, Jessica Magalhães |
| Capacidade | 2h/semana por pessoa (~6h/semana de equipe), 8 semanas |
| Demo Day | **23/11 — confirmado** |
| Status | Em andamento — decisões de arquitetura e nomenclatura fechadas |

---

## 0. Dois produtos, uma apresentação

| | Blueprint **ASK** | MVP **ASK Revendas** |
|---|---|---|
| Natureza | Especificação reaplicável — diagrama de nós, framework de intake, modelo de customização | Instância aplicada do blueprint, configurada para um caso de uso real |
| O que prova | Escalabilidade (25% da nota) — vira oferta de catálogo, não solução única | Impacto financeiro (30%) e eficiência (20%) — funciona de verdade |
| Entra na lista de ofertas ScanSource | Sim — é o produto de catálogo | Não — é o caso de uso demonstrativo do blueprint |
| Risco a evitar | Prometer nó que não estará ativo na demo | Tentar cobrir múltiplos fabricantes/cenários no tempo disponível |

**Regra para o pitch:** todo nó do blueprint apresentado como "disponível" precisa estar marcado como **ativo na demo** ou **desenhado, não ativado nesta entrega** — nunca ambíguo.

---

## 1. Decisões de arquitetura fechadas

| # | Decisão | Impacto |
|---|---|---|
| D1 | Nome do blueprint: **ASK**. Nome do MVP aplicado: **ASK Revendas** | Evita fricção de marca com "AI-Q" da NVIDIA fora do hackathon |
| D2 | Hospedagem: **modelo gerenciado nativo da cloud (Azure/OCI), sem NIM** | Maior ponto de adaptação do blueprint original — funciona mesmo sem o cliente ter licença NVIDIA AI Enterprise. Coerente com a feature nativa do AI-Q de trocar modelos via YAML — não é desvio do padrão, é uso do ponto de extensão já previsto |
| D3 | Demo ao vivo em **Azure**; **OCI como prova de portabilidade documentada** (mesmo Helm chart, troca de endpoint de modelo e backend de dados), sem precisar estar rodando no dia | Sustenta a tese de agnosticismo sem duplicar esforço de infra nas 6 semanas disponíveis |
| D4 | Custo do MVP muda de "por token" (rota NVIDIA hospedada) para **"por hora de compute + modelo gerenciado"** | Argumento financeiro mais forte para revenda: custo previsível é mais fácil de colocar em contrato do que custo variável de tokens |
| D5 | **Aberto** — avaliação de oferta de agentes da Adobe para resposta sobre bases documentais (Base X). Não altera o blueprint (é um nó pluggable de fonte de dados), mas altera o custo e a stack do MVP se adotada | Ver item 4 — decisão a fechar até o fim da Descoberta, antes de iniciar a Construção |
| D6 | **Modelo de propriedade federado:** cada base de conhecimento e nó especializado é de responsabilidade do time de arquitetos/pré-vendas do respectivo fabricante — nosso time de 3 não mantém as bases, só o blueprint | Resolve o bloqueador de escalabilidade (500+ fabricantes é inviável para um time de 3), mas **exige que a inclusão de nó/base seja self-service — sem YAML, sem código** para quem não é do time técnico. Ver seção 5a |

---

## 2. Escopo do MVP (já decidido pela equipe — mantido)

**Dentro do escopo:** pesquisador de produtos, soluções e ofertas ScanSource. Recebe uma necessidade (transcrição de pré-vendas ou pergunta direta), classifica, orquestra entre agentes especializados, consulta bases de conhecimento, avalia a resposta antes de entregar, retorna solução com produtos e preço estimado, **com fonte citada**.

**Fora do escopo do MVP (não construir nestas 8 semanas):**
- Discovery de infraestrutura do cliente
- Geração/implementação de código ou automação em sistemas do cliente
- Suporte a múltiplos fabricantes simultâneos — começar com um fabricante piloto
- Interface polida — o Demo Day pede MVP funcional, não produto acabado

---

## 3. Arquitetura simplificada (versão para apresentação)

```
Usuário (pré-vendas)
      │
      ▼
Classificador ──► fora de escopo (ex.: preço de revista) → descarta
      │
      ▼
Orquestrador ──► decide se é resposta simples ou precisa de especialista
      │
      ├──► Agente Pré-vendas (produto, preço, disponibilidade)
      ├──► Agente Arquiteto (cenário técnico, quando a pergunta exigir desenho)
      │
      ▼
Bases de conhecimento
  • Base X — Documentação técnica do fabricante piloto
  • Base Y — Regras comerciais / price list
      │
      ▼
Avaliador de resposta ──► sem fonte suficiente? devolve para reformulação
      │
      ▼
Resposta final + citação da fonte consultada
```

**Princípio herdado do trabalho de arquitetura já feito:** o orquestrador roteia e resolve identidade — nunca decide regra de negócio. Regra comercial mora na Base Y, não no código do orquestrador. Isso evita que o MVP vire um bloco monolítico difícil de explicar no pitch.

---

## 4. Mapeamento para os 5 entregáveis obrigatórios

| Entregável INOVA | O que já existe e pode ser adaptado | Trabalho novo necessário |
|---|---|---|
| **1. Problem Statement** | Ata da reunião já tem a frase-chave: *"o problema de fato são os dados — qual é a fonte da verdade"* | Formalizar em 1 página: problema, público (GDN/pré-vendas), impacto atual (tempo perdido, respostas inconsistentes) |
| **2. Business Case** | Estrutura de Business Case já desenhada em conversas anteriores (visão, benefícios, público, custos, riscos) | Preencher com números do fabricante piloto escolhido; custo agora é **por hora de compute + modelo gerenciado** (D4), não mais por token |
| **3. MVP** | Padrão classificador/orquestrador/avaliador já validado como arquitetura de referência; blueprint ASK adaptado sem NIM (D2) | Implementação real das 6 semanas de construção |
| **4. Canvas Financeiro** | Modelo de custo definido (D4) | Preencher com valores reais de Azure (compute + modelo gerenciado) e, se Adobe for adotado (D5), somar linha de assinatura |
| **5. Plano de Escala** | Já existe o padrão de sequenciamento por fases (fatia read-only → expansão gradual) usado no trabalho de arquitetura anterior; portabilidade OCI (D3) já é argumento pronto de escala multi-cloud | Adaptar a linguagem: 90 dias validação, 180 dias expansão a mais fabricantes/revendas, 365 dias comercialização |

---

## 5. Bloqueadores a resolver na Descoberta (semanas 2-3)

Resta um item da ata original ainda sem fechamento (o segundo — dono da base de conhecimento — foi resolvido: **modelo federado, D6**, ver acima):

1. **Decisão Adobe (D5)** — validar se a oferta de agentes da Adobe substitui ou complementa o agente de resposta sobre Base X (documental). Não é bloqueador de arquitetura (o nó é pluggable por design), mas é bloqueador de **custo** e de **stack de implementação** — precisa fechar antes do início da Construção (semana 4), senão a Semana 5 (Agente Pré-vendas consultando Base X) não tem stack definida.

Recomendação: fechar até o fim da semana 3, mesmo que com premissa explícita e não resposta definitiva — uma premissa declarada é aceitável num MVP de hackathon; uma lacuna não é.

### 5a. Onboarding self-service de novo fabricante (peça central da demo)

O modelo federado (D6) só é verdade na prática se adicionar um fabricante não exigir código nem YAML de quem não é do time técnico. Mínimo necessário para o Demo Day:

- **Formulário de intake** (interface simples — pode ser web form ou até planilha estruturada no MVP) preenchido pelo arquiteto/pré-vendas do fabricante: nome do fabricante, localização dos documentos técnicos, tipo de regra comercial, contato responsável pela manutenção da base
- O formulário **materializa o nó e a base de conhecimento** — sem intervenção manual do time de 3 no código
- Este fluxo, não o agente de resposta isoladamente, é o que prova a tese de escalabilidade no pitch — priorizar como item de demo, não como detalhe de implementação

---

## 6. Cronograma detalhado (6h de equipe/semana)

### Semana 1 — Kickoff (04/09)
- Decidir fabricante piloto único (reduz escopo de dados no início)
- Provisionar acesso ao modelo gerenciado no Azure (deployment via Foundry) — iniciar cedo, mesmo que setup leve
- Rascunhar Problem Statement (1 página)

### Semanas 2-3 — Descoberta (11/09, 18/09)
- Levantar 15–20 exemplos reais de solicitações de pré-vendas (transcrições ou relatos) para servir de dataset de teste do classificador
- Estruturar Base Y (regras comerciais) em formato consultável — mesmo que uma planilha estruturada no início
- **Desenhar o formulário de intake self-service** (seção 5a) — define os campos mínimos que um arquiteto/pré-vendas de fabricante precisa preencher
- **Fechar decisão Adobe (D5)** — define a stack do agente de Base X antes da Construção
- Primeiro rascunho do Business Case (problema, visão, benefícios, público, riscos)
- Configurar o YAML do blueprint ASK: modelos (Azure gerenciado), fontes de dados, política de execução — sem NIM

### Semanas 4-6 — Construção (25/09–09/10)
- Semana 4: Classificador + Orquestrador funcionando (roteamento correto entre "simples" e "precisa especialista")
- Semana 5: Agente Pré-vendas consultando Base X/Y com citação de fonte (stack conforme decisão Adobe) + **formulário de intake materializando um segundo fabricante de teste**, provando o modelo federado (D6) na prática
- Semana 6: Avaliador de resposta — regra simples primeiro (ex.: resposta sem fonte citada é rejeitada e reformulada)
- Apresentação parcial ao final da semana 6 (conforme calendário oficial)

### Semana 7 — Validação (16/10)
- Testar com 5–10 solicitações reais não usadas no desenvolvimento
- Coletar feedback de um pré-vendas real, se possível
- Preencher Canvas Financeiro com custo real medido (compute Azure + modelo gerenciado + Adobe, se aplicável)
- Documentar o caminho de portabilidade OCI (D3) — diagrama e config equivalente, não deploy ao vivo

### Semana 8 — Ajustes e ensaio (23/10, 30/10)
- Ajustes finais do MVP com base no feedback
- Fechar Plano de Escala (90/180/365 dias)
- Preparar o slide de separação Blueprint ASK vs. MVP ASK Revendas (seção 0) — deixar explícito o que está ativo vs. documentado
- **Garantir que a demo do formulário de intake (segundo fabricante, seção 5a) esteja no roteiro do pitch** — é o momento que prova escalabilidade ao vivo, não só no slide
- Ensaiar pitch de 30 minutos + preparar respostas para as 5 minutos de perguntas — incluir resposta pronta para "isso não é só o produto da NVIDIA?" (diferenciação: curadoria das bases, framework de intake, nós efetivamente ativados, adaptação sem NIM)

---

## 7. O que fica fora e por quê (defesa antecipada para a banca)

Se a banca perguntar por que não há discovery de infraestrutura, implementação automática ou suporte multi-fabricante no MVP: a resposta correta é que o programa segue um princípio deliberado de **read-only primeiro, escrita depois** — o MVP entrega valor sem tocar em nenhum sistema do cliente, o que reduz risco e acelera aprovação. Expansão para múltiplos fabricantes e automação de implementação são o Plano de Escala, não o MVP — e é exatamente esse tipo de corte de escopo disciplinado que o critério de "eficiência operacional" (20%) tende a recompensar melhor do que uma demo mais ambiciosa e mais frágil.

---

## 8. Divisão de trabalho sugerida (3 pessoas, 2h/semana cada)

| Papel | Foco | Observação |
|---|---|---|
| Robson | Arquitetura, orquestrador, avaliador, Business Case, deployment Azure | Já tem o desenho de referência e a fundação de infraestrutura Azure (landing zone, Foundry) mapeados de trabalho anterior — menor curva de aprendizado no provisionamento |
| João | Base de conhecimento, integração de dados do fabricante piloto, Canvas Financeiro | Conhece o material da NVIDIA/Oracle levantado na ata — reaproveitar pesquisa já feita; acompanhar decisão Adobe (D5) |
| Jessica | Classificador, testes com casos reais, Plano de Escala | Já mapeou material Microsoft e tem experiência com agente de padronização documental (Cloud Delivery) — reaproveitar esse padrão para a citação de fonte; conduzir avaliação da oferta Adobe (D5) |
