# Zuu

Plataforma SaaS de gestão de aluguéis focada em corretores autônomos e proprietários diretos. Abordagem WhatsApp-first com OCR automático de documentos, geração de contratos digitais e split de pagamento nativo.

> **Última atualização do README:** 2026-06-22
> **Fase atual:** Semana 1 — Setup técnico e autenticação
> **Marco-alvo:** MVP em produção com 5 usuários reais até **14/08/2026** (8 semanas)

---

## Sumário

- [Contexto e Posicionamento](#contexto-e-posicionamento)
- [Stack Técnica](#stack-técnica)
- [Arquitetura de Usuários](#arquitetura-de-usuários)
- [Módulos e Fases do MVP](#módulos-e-fases-do-mvp)
- [Modelo de Dados (ERD)](#modelo-de-dados-erd)
- [Políticas de Segurança (RLS)](#políticas-de-segurança-rls)
- [Fluxo Principal](#fluxo-principal)
- [Monetização](#monetização)
- [Cronograma](#cronograma)
- [Decisões de Arquitetura](#decisões-de-arquitetura)

---

## Contexto e Posicionamento

O mercado brasileiro de locação abrange 17,8 milhões de domicílios alugados (2024), com crescimento de 45,4% em uma década. A Selic elevada (~15% em 2025) pressiona potenciais compradores para a locação, mantendo demanda aquecida.

**Público-alvo:** corretores autônomos e proprietários com até ~30 imóveis. Não grandes imobiliárias.

**Problema:** ferramentas existentes (Superlógica, Kenlo) são complexas e caras para esse perfil. Proprietários amadores ainda operam com planilhas e WhatsApp manual.

**Solução:** gestão completa iniciada e conduzida pelo WhatsApp — o brasileiro já usa, eliminando curva de aprendizado. OCR extrai dados de documentos automaticamente. Contratos gerados em minutos. Pagamentos com split automático.

**Concorrentes diretos:** Imobia, Evoimob, Piloto Imóveis. Diferencial: único com fluxo WhatsApp-first nativo no MVP.

---

## Stack Técnica

### Frontend
| Ferramenta | Versão | Uso |
|---|---|---|
| Next.js | 15 (App Router) | Framework principal, SSR + API Routes |
| Tailwind CSS | 4 | Estilização |
| shadcn/ui | latest | Componentes de UI |
| React Hook Form | 7 | Formulários |
| Zod | 3 | Validação de esquema (compartilhado frontend/backend) |
| TanStack Query | 5 | Cache e data fetching |

### Backend / BaaS
| Ferramenta | Uso |
|---|---|
| Supabase Auth | Autenticação (email, Google OAuth) |
| Supabase PostgreSQL | Banco de dados principal |
| Supabase Storage | Upload de fotos, documentos, PDFs |
| Supabase Realtime | Chat em tempo real (mensagens) |

### Serviços Externos
| Serviço | Uso | Fase |
|---|---|---|
| Asaas | Boleto, PIX, split de pagamento, webhooks | Fase 1b |
| Resend | E-mail transacional (cobranças, notificações) | Fase 1 |
| Evolution API / Z-API | WhatsApp (MVP — sem aprovação Meta) | Fase 2 |
| WhatsApp Cloud API | WhatsApp oficial (produção) | Fase 3 |
| Mindee | OCR de CNH, RG, comprovantes BR | Fase 2 |
| @react-pdf/renderer | Geração de contratos em PDF | Fase 1 |
| Vercel Cron Jobs | Jobs recorrentes (alertas, cobranças) | Fase 1b |

### Infraestrutura
| Serviço | Uso |
|---|---|
| Vercel | Hospedagem Next.js |
| Supabase Cloud | Banco, auth, storage |
| Railway | Evolution API / workers futuros |

---

## Arquitetura de Usuários

```
ADMIN
└── controle total da plataforma

LOCADOR (corretor ou proprietário)
├── cadastra e edita imóveis
├── cria e gerencia contratos
├── visualiza e gera cobranças
├── conversa com locatários
└── acessa dashboard financeiro

LOCATÁRIO (inquilino)
├── visualiza contrato e imóvel
├── visualiza e paga cobranças (PIX/boleto)
├── baixa recibos e documentos
├── conversa com locador
└── abre solicitações de manutenção
```

Permissões implementadas via **Row Level Security (RLS)** no PostgreSQL — segurança no banco, independente do frontend.

---

## Módulos e Fases do MVP

### Fase 1 — Núcleo Operacional
> Objetivo: provar que pessoas conseguem gerir imóveis e contratos na plataforma.

- [ ] **Autenticação** — cadastro, login (email/senha + Google), recuperação de senha, roles
- [ ] **CRUD Usuários** — perfil locador (dados bancários) e locatário (dados pessoais/financeiros)
- [ ] **CRUD Imóveis** — cadastro completo com fotos, status, localização, valores
- [ ] **Contratos** — geração de contrato PDF, histórico, renovação
- [ ] **Dashboard Locador** — indicadores: imóveis ativos, contratos, inadimplência, vencimentos
- [ ] **Área do Locatário** — visualização de contrato, cobranças, documentos
- [ ] **Mensageria** — chat interno locador ↔ locatário via Supabase Realtime

### Fase 1b — Financeiro
> Objetivo: ter recorrência real — cobranças funcionando e split automático.

- [ ] **Integração Asaas** — emissão de boleto e PIX por cobrança
- [ ] **Split de pagamento** — repasse automático ao locador, retenção da taxa Zuu
- [ ] **Webhooks Asaas** — atualização de status de cobrança em tempo real
- [ ] **Geração de recibos PDF** — automático após liquidação
- [ ] **Histórico financeiro** — por contrato e por imóvel
- [ ] **Vercel Cron Jobs** — geração automática de cobranças mensais e alertas de vencimento

### Fase 2 — Automação e Comunicação
> Objetivo: reduzir trabalho manual do gestor.

- [ ] **Integração WhatsApp** (Evolution API / Z-API) — envio de cobranças e recibos
- [ ] **OCR de documentos** (Mindee) — extração automática de dados de CNH/RG
- [ ] **Assinatura eletrônica** — integração Clicksign ou similar
- [ ] **Notificações push** — alertas de vencimento, pagamento, manutenção
- [ ] **Solicitações de manutenção** — fluxo locatário → locador com fotos e status

### Fase 3 — Inteligência e Escala
> Objetivo: transformar dados em vantagem competitiva.

- [ ] **WhatsApp Cloud API** — migração para API oficial Meta
- [ ] **IA Assistente** — sugestões de reajuste, previsão de vacância
- [ ] **Anúncios automáticos** — publicação em portais quando imóvel fica disponível
- [ ] **Smart Contracts** — automações baseadas em eventos financeiros
- [ ] **Relatórios DIMOB** — geração para declaração de IR
- [ ] **Marketplace / matching** — locador anunciando para locatário dentro da plataforma

---

## Modelo de Dados (ERD)

### Enums

```sql
create type user_role as enum ('admin', 'locador', 'locatario');
create type property_type as enum ('apartment', 'house', 'room', 'commercial', 'land');
create type property_status as enum ('available', 'rented', 'reserved', 'maintenance');
create type contract_status as enum ('draft', 'pending_signature', 'active', 'terminated', 'expired');
create type adjustment_index as enum ('igpm', 'ipca', 'ivar', 'inpc');
create type guarantee_type as enum ('deposit', 'guarantor', 'insurance', 'none');
create type charge_type as enum ('rent', 'condo', 'iptu', 'fine', 'repair', 'other');
create type charge_status as enum ('pending', 'paid', 'overdue', 'cancelled');
create type payment_method as enum ('pix', 'boleto', 'transfer', 'cash');
create type document_type as enum ('rg', 'cpf', 'cnh', 'income_proof', 'contract', 'inspection', 'other');
create type message_type as enum ('text', 'image', 'document');
create type notification_type as enum ('charge_due', 'charge_paid', 'contract_expiring', 'new_message', 'maintenance', 'other');
create type maintenance_status as enum ('open', 'in_progress', 'resolved', 'cancelled');
create type maintenance_priority as enum ('low', 'medium', 'high', 'urgent');
create type media_type as enum ('photo', 'video', 'document');
```

### Tabelas

#### `profiles` — estende `auth.users`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | FK → auth.users.id |
| role | user_role | admin / locador / locatario |
| name | text | |
| cpf | text UNIQUE | |
| phone | text | |
| avatar_url | text | Supabase Storage |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `locador_details`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| profile_id | uuid UNIQUE | FK → profiles.id |
| pix_key | text | chave PIX para repasse |
| bank | text | |
| agency | text | |
| account | text | |

#### `locatario_details`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| profile_id | uuid UNIQUE | FK → profiles.id |
| rg | text | |
| profession | text | |
| monthly_income | numeric | |
| marital_status | text | |

#### `properties`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| locador_id | uuid | FK → profiles.id |
| title | text | |
| description | text | |
| type | property_type | |
| status | property_status | default: available |
| address_street | text | |
| address_number | text | |
| address_complement | text | nullable |
| address_neighborhood | text | |
| address_city | text | |
| address_state | char(2) | |
| address_zip | text | |
| lat | numeric | nullable |
| lng | numeric | nullable |
| rent_value | numeric | |
| condo_fee | numeric | default: 0 |
| iptu | numeric | default: 0 |
| deposit | numeric | default: 0 |
| bedrooms | int | |
| bathrooms | int | |
| parking_spots | int | |
| area_sqm | numeric | |
| furnished | boolean | default: false |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `property_media`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| property_id | uuid | FK → properties.id |
| type | media_type | |
| url | text | Supabase Storage |
| order | int | ordem de exibição |
| created_at | timestamptz | |

#### `contracts`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| property_id | uuid | FK → properties.id |
| locador_id | uuid | FK → profiles.id |
| locatario_id | uuid | FK → profiles.id |
| status | contract_status | default: draft |
| start_date | date | |
| end_date | date | |
| rent_value | numeric | valor no momento do contrato |
| condo_fee | numeric | default: 0 |
| iptu | numeric | default: 0 |
| deposit_value | numeric | default: 0 |
| due_day | int | dia do vencimento (1–28) |
| adjustment_index | adjustment_index | default: igpm |
| adjustment_months | int | default: 12 |
| fine_percentage | numeric | default: 10 |
| guarantee_type | guarantee_type | default: none |
| pets_allowed | boolean | default: false |
| notes | text | nullable |
| pdf_url | text | nullable — Supabase Storage |
| signed_at | timestamptz | nullable |
| terminated_at | timestamptz | nullable |
| termination_reason | text | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `guarantors`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| contract_id | uuid | FK → contracts.id |
| name | text | |
| cpf | text | |
| phone | text | |
| email | text | |
| address | text | |
| created_at | timestamptz | |

#### `charges`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| contract_id | uuid | FK → contracts.id |
| locatario_id | uuid | FK → profiles.id |
| locador_id | uuid | FK → profiles.id |
| type | charge_type | |
| description | text | nullable |
| amount | numeric | |
| due_date | date | |
| paid_at | timestamptz | nullable |
| status | charge_status | default: pending |
| payment_method | payment_method | nullable |
| asaas_charge_id | text | nullable — ID externo Asaas |
| asaas_invoice_url | text | nullable — link boleto |
| asaas_pix_qrcode | text | nullable — QR Code Pix |
| receipt_url | text | nullable — recibo gerado |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `messages`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| contract_id | uuid | FK → contracts.id |
| sender_id | uuid | FK → profiles.id |
| content | text | |
| type | message_type | default: text |
| attachment_url | text | nullable |
| read_at | timestamptz | nullable |
| created_at | timestamptz | |

#### `documents`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| owner_id | uuid | FK → profiles.id |
| contract_id | uuid | FK → contracts.id — nullable |
| property_id | uuid | FK → properties.id — nullable |
| type | document_type | |
| name | text | |
| url | text | Supabase Storage |
| ocr_data | jsonb | nullable — dados extraídos pelo OCR |
| created_at | timestamptz | |

#### `maintenance_requests`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| contract_id | uuid | FK → contracts.id |
| locatario_id | uuid | FK → profiles.id |
| title | text | |
| description | text | |
| status | maintenance_status | default: open |
| priority | maintenance_priority | default: medium |
| photos | text[] | nullable — URLs Supabase Storage |
| resolved_at | timestamptz | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

#### `notifications`
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | FK → profiles.id |
| type | notification_type | |
| title | text | |
| body | text | |
| read_at | timestamptz | nullable |
| metadata | jsonb | nullable — ex: `{ charge_id, contract_id }` |
| created_at | timestamptz | |

### Diagrama de Relacionamentos

```
auth.users
    └── profiles (1:1)
            ├── locador_details (1:1, role = locador)
            ├── locatario_details (1:1, role = locatario)
            ├── properties (1:N, como locador)
            ├── documents (1:N, como owner)
            └── notifications (1:N)

properties
    ├── property_media (1:N)
    └── contracts (1:N)
            ├── guarantors (1:N)
            ├── charges (1:N)
            ├── messages (1:N)
            ├── documents (1:N)
            └── maintenance_requests (1:N)
```

---

## Políticas de Segurança (RLS)

RLS ativo em todas as tabelas. Segurança no banco — independente do frontend.

```sql
-- profiles
SELECT: id = auth.uid() OR role = 'admin'
UPDATE: id = auth.uid()

-- properties
SELECT (locador):   locador_id = auth.uid()
SELECT (locatario): id IN (SELECT property_id FROM contracts WHERE locatario_id = auth.uid())
INSERT/UPDATE/DELETE: locador_id = auth.uid()

-- contracts
SELECT:  locador_id = auth.uid() OR locatario_id = auth.uid()
INSERT:  caller tem role = 'locador'
UPDATE:  locador_id = auth.uid()

-- charges
SELECT:  locador_id = auth.uid() OR locatario_id = auth.uid()
INSERT/UPDATE: locador_id = auth.uid()

-- messages
SELECT/INSERT: sender_id = auth.uid()
           OR EXISTS (
             SELECT 1 FROM contracts
             WHERE id = contract_id
             AND (locador_id = auth.uid() OR locatario_id = auth.uid())
           )

-- documents
SELECT: owner_id = auth.uid()
     OR contract_id IN (
       SELECT id FROM contracts
       WHERE locador_id = auth.uid() OR locatario_id = auth.uid()
     )
INSERT: owner_id = auth.uid()

-- notifications
SELECT/UPDATE: user_id = auth.uid()

-- maintenance_requests
SELECT:  contract_id IN (SELECT id FROM contracts WHERE locador_id = auth.uid() OR locatario_id = auth.uid())
INSERT:  locatario_id = auth.uid()
UPDATE:  locador_id em contracts relacionado = auth.uid()
```

---

## Fluxo Principal

```
1. Locador cadastra imóvel
   → property criada (status: available)

2. Locador inicia contrato com locatário
   → contract criado (status: draft)
   → locatário recebe convite por e-mail

3. Locatário assina / locador finaliza
   → contract (status: active)
   → property (status: rented)

4. Cron job gera cobranças mensais
   → charges criadas (status: pending)
   → Asaas emite boleto/PIX
   → locatário notificado por e-mail (Fase 1) e WhatsApp (Fase 2)

5. Locatário paga
   → webhook Asaas → charge (status: paid)
   → split automático: repasse ao locador, taxa retida pela Zuu
   → recibo PDF gerado e enviado

6. Contrato vence ou é encerrado
   → contract (status: expired / terminated)
   → property (status: available)
```

---

## Monetização

**Modelo principal:** Pay-per-use — taxa por cobrança liquidada (sem mensalidade fixa no MVP).

**Fórmula do split:**
```
P_total = R_prop + T_adm + T_plat + D_acess
```
- `R_prop` — repasse ao proprietário
- `T_adm` — comissão do corretor (quando aplicável)
- `T_plat` — taxa da Zuu
- `D_acess` — despesas acessórias (IPTU, seguro, condomínio)

**Evolução:**
| Fase | Modelo |
|---|---|
| MVP | Freemium até 3 contratos + pay-per-use |
| Escala | Planos por carteira (Starter / Pro / Unlimited) |
| Futuro | Taxa por liquidação + módulos premium (assinatura digital, DIMOB, IA) |

---

## Cronograma

> Cronograma diário com datas reais. Atualizar status ao final de cada dia.
> **Meta:** MVP em produção com 5 usuários reais até **sex 14/08/2026**.
> **Premissa:** ~3–5 h/dia de execução. Domingo é folga.

### Semana 0 — Arquitetura e Planejamento ✅ (concluída em 14/05)
- [x] Definição do posicionamento e público-alvo
- [x] Escolha da stack técnica
- [x] Modelagem ERD completa
- [x] Definição das fases do MVP
- [x] Documentação inicial do README
- [x] Migrations SQL escritas (enums, tabelas, RLS, triggers)
- [x] Esqueleto Next.js + Supabase + auth (em código, não testado)

---

### Semana 1 — Desbloqueio técnico e auth funcional (22–28/06) 🔴 ATUAL

**Seg 22/06** — Replanejamento e desbloqueio
- [x] Cronograma diário realinhado para datas reais
- [ ] Corrigir `npm run build` (erros de module not found)
- [ ] Commitar tudo o que está pronto + abrir PR "Semana 1"

**Ter 23/06** — Supabase Cloud
- [ ] Criar projeto Supabase Cloud
- [ ] Rodar as 4 migrations
- [ ] Configurar buckets Storage (`avatars`, `properties`, `documents`, `contracts`)
- [ ] Atualizar `.env.local` com credenciais reais

**Qua 24/06** — OAuth e fluxo de auth
- [ ] Configurar Google OAuth no Supabase
- [ ] Testar login/cadastro/Google end-to-end
- [ ] Criar páginas `/recuperar-senha` e `/atualizar-senha`

**Qui 25/06** — Layout autenticado
- [ ] Sidebar com navegação por role (locador vs locatário)
- [ ] Header com avatar + logout
- [ ] Página `/perfil` (editar nome, foto, telefone)

**Sex 26/06** — Dados específicos por role
- [ ] Formulário de dados bancários do locador (PIX, banco, agência)
- [ ] Formulário de dados pessoais do locatário (RG, profissão, renda)
- [ ] Abrir PR "Semana 1 — Auth e perfis"

**Sáb 27/06** — Decisões estratégicas
- [ ] Comprar domínios (`zuu.com.br` + `zuu.app`)
- [ ] Definir cidade-alvo para os 5 primeiros usuários
- [ ] Escolher cor primária e logotipo simples
- [ ] Abrir CNPJ MEI (ou agendar)

**Dom 28/06** — Folga

---

### Semana 2 — CRUD de Imóveis (29/06–05/07)

**Seg 29/06** — Schema de formulário e validação
- [ ] Formulário completo de cadastro de imóvel
- [ ] Auto-complete de CEP (API ViaCEP)

**Ter 30/06** — Upload de fotos
- [ ] Upload múltiplo via Supabase Storage
- [ ] Reordenação por drag-and-drop
- [ ] Compressão client-side antes do upload

**Qua 01/07** — Listagem
- [ ] Grid de imóveis do locador
- [ ] Filtros: status, tipo, cidade

**Qui 02/07** — Edição e exclusão
- [ ] Página de edição
- [ ] Confirmação de exclusão com modal

**Sex 03/07** — Detalhes do imóvel
- [ ] Página `/imoveis/[id]` com galeria
- [ ] Indicadores: contratos ativos, histórico

**Sáb 04/07** — Buffer + PR "Semana 2 — Imóveis"
**Dom 05/07** — Folga

---

### Semana 3 — Contratos (06–12/07)

**Seg 06/07** — Formulário de contrato
- [ ] Vincular imóvel + locatário existente

**Ter 07/07** — Convite de locatário novo
- [ ] Convite por e-mail (Resend) com link mágico
- [ ] Página de aceite do convite

**Qua 08/07** — Geração de PDF
- [ ] Template de contrato em `@react-pdf/renderer`
- [ ] Upload do PDF gerado para Storage

**Qui 09/07** — Listagem e detalhes
- [ ] `/contratos` (visão locador)
- [ ] `/contratos/[id]` com download PDF

**Sex 10/07** — Visão do locatário
- [ ] `/minha-area/contrato` (visualização do contrato ativo)

**Sáb 11/07** — Buffer + PR "Semana 3 — Contratos"
**Dom 12/07** — Folga

---

### Semana 4 — Dashboard e Comunicação (13–19/07)

**Seg 13/07** — Dashboard do locador (real)
- [ ] Queries agregadas: contratos ativos, MRR estimado, inadimplência

**Ter 14/07** — Área do locatário
- [ ] Visão de cobranças, documentos, histórico

**Qua 15/07** — Notificações in-app
- [ ] Badge + dropdown + página `/notificacoes`

**Qui 16/07** — Chat em tempo real
- [ ] Lista de conversas por contrato
- [ ] Subscription Supabase Realtime

**Sex 17/07** — Anexos no chat
- [ ] Envio de imagem e documento via Storage

**Sáb 18/07** — Buffer + PR "Semana 4 — Comunicação"
**Dom 19/07** — Folga

---

### Semana 5 — Asaas e Cobranças (20–26/07)

**Seg 20/07** — Setup Asaas
- [ ] Criar cliente Asaas a partir do locatário
- [ ] Service de geração de cobrança PIX/boleto

**Ter 21/07** — Webhook de pagamento
- [ ] Endpoint `/api/webhooks/asaas`
- [ ] Validação de assinatura

**Qua 22/07** — Split de pagamento
- [ ] Configurar wallet do locador
- [ ] Regras de split (taxa Zuu + repasse)

**Qui 23/07** — Recibo PDF
- [ ] Geração automática após `paid_at`
- [ ] Envio por e-mail (Resend)

**Sex 24/07** — Histórico financeiro
- [ ] Página `/financeiro` (locador)
- [ ] Página `/minhas-cobrancas` (locatário)

**Sáb 25/07** — Buffer + PR "Semana 5 — Pagamentos"
**Dom 26/07** — Folga

---

### Semana 6 — Automação e Cron Jobs (27/07–02/08)

**Seg 27/07** — Cron de cobranças mensais
- [ ] Vercel Cron Job: gerar `charges` no dia 1 de cada mês

**Ter 28/07** — Alertas de vencimento
- [ ] 3 dias antes, dia do vencimento, atraso

**Qua 29/07** — E-mails transacionais
- [ ] Templates Resend: cobrança emitida, pagamento confirmado, contrato vencendo

**Qui 30/07** — Atualização automática de status
- [ ] Job diário para marcar `overdue` e `expired`

**Sex 31/07** — Página inicial pública
- [ ] Landing page simples explicando o ZUU
- [ ] CTA para cadastro

**Sáb 01/08** — Buffer + PR "Semana 6 — Automação"
**Dom 02/08** — Folga

---

### Semana 7 — Hardening e Deploy (03–09/08)

**Seg 03/08** — Auditoria de RLS
- [ ] Tentar burlar permissões como cada role (locador, locatário, admin)

**Ter 04/08** — Logs e erros
- [ ] Estruturar logs + integração com Sentry

**Qua 05/08** — Deploy Vercel
- [ ] Configurar projeto Vercel + variáveis de ambiente
- [ ] Domínio + DNS

**Qui 06/08** — Supabase Cloud em produção
- [ ] Plano Pro Supabase (se necessário) + backup configurado

**Sex 07/08** — Testes E2E manuais
- [ ] Fluxo completo: cadastro → imóvel → contrato → cobrança → pagamento → recibo

**Sáb 08/08** — Correções finais
**Dom 09/08** — Folga

---

### Semana 8 — Validação real (10–14/08) 🎯 MARCO

**Seg 10/08** — Onboarding piloto 1
- [ ] Eu mesmo cadastro 1 contrato real

**Ter 11/08** — Onboarding piloto 2 e 3
- [ ] 2 amigos/conhecidos como primeiros locadores

**Qua 12/08** — Onboarding piloto 4 e 5
- [ ] Mais 2 locadores via indicação

**Qui 13/08** — Acompanhamento
- [ ] Coletar feedback diário, corrigir bugs P0

**Sex 14/08** — 🏁 MARCO
- [ ] MVP em produção com **5 usuários reais ativos**
- [ ] Retrospectiva da fase 1
- [ ] Planejamento da Fase 2 (WhatsApp + OCR)

---

### Backlog — Fase 2 (pós-MVP)
- [ ] WhatsApp (Evolution API / Z-API)
- [ ] OCR de documentos (Mindee)
- [ ] Assinatura eletrônica (Clicksign)
- [ ] Solicitações de manutenção
- [ ] Notificações push

### Backlog — Fase 3
- [ ] WhatsApp Cloud API (oficial Meta)
- [ ] IA assistente (reajustes, vacância)
- [ ] Relatórios DIMOB
- [ ] Marketplace / matching

---

## Decisões de Arquitetura

Registro de decisões técnicas relevantes para referência futura.

| Data | Decisão | Motivo |
|---|---|---|
| 2026-05-14 | Supabase como BaaS principal | Auth + DB + Storage + Realtime em pacote único — ideal para velocidade de MVP |
| 2026-05-14 | Asaas para pagamentos (não Stripe) | Boleto e PIX nativos, split de pagamento, conformidade BR |
| 2026-05-14 | Evolution API/Z-API para WhatsApp no MVP | Aprovação Meta leva semanas; Z-API e Evolution permitem iniciar sem burocracia |
| 2026-05-14 | RLS no banco desde o dia 1 | Segurança independente do frontend; evita reescrever permissões depois |
| 2026-05-14 | Pay-per-use como modelo inicial | Baixa barreira de entrada; usuário sente valor antes de pagar mensalidade fixa |
| 2026-05-14 | @react-pdf/renderer para contratos | Geração no servidor Next.js sem dependência externa |
| 2026-05-15 | Cronograma diário com marco de produção em 10/07/2026 | Substituir o cronograma semanal por metas diárias rastreáveis; ancorar o projeto em datas reais para evitar drift |
| 2026-06-22 | Cronograma reancorado: marco de produção em 14/08/2026 | Realinhar com a data real de retomada do projeto; manter as 8 semanas de execução |

---

*Este documento é o ponto de verdade do projeto. Qualquer decisão de arquitetura, mudança de stack ou alteração de escopo deve ser registrada aqui antes de ser implementada.*
