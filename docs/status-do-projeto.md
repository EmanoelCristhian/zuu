# ZUU — Documento de Status do Projeto

> **Data do levantamento:** 19/11/2026
> **Última atividade registrada no git:** 23/06/2026
> **Fonte:** estado real do repositório (branches, commits, PRs, arquivos), não do README.

---

## 1. Resumo executivo

O ZUU é uma plataforma SaaS de gestão de aluguéis, **WhatsApp-first**, para corretores autônomos e proprietários diretos (1 a ~30 imóveis). O projeto está em **pré-MVP**: arquitetura, banco de dados e esqueleto de autenticação existem em código. **Nada roda em produção, não há usuários e nenhuma funcionalidade de negócio (imóveis, contratos, cobranças) foi implementada.**

| Item | Situação |
|---|---|
| Estágio | Pré-MVP, Semana 1 do cronograma (parcialmente concluída) |
| Código de negócio | 0% (só autenticação em esqueleto) |
| Banco de dados | Modelado e migrations escritas; aplicadas em um projeto Supabase Cloud (ver seção 5 para o que não foi confirmado) |
| Produção / usuários | Nenhum |
| Parado desde | 23/06/2026 (~5 meses) |
| Marco original | 14/08/2026 — **já passou, sem ser atingido** |

**Conclusão honesta:** o cronograma diário do README está obsoleto. Antes de continuar, é preciso reancorar o plano (seção 9) e decidir o que cortar do escopo do MVP.

---

## 2. O que é o ZUU

- **Produto:** web app SaaS (Next.js + Supabase). App mobile e WhatsApp/IA vêm em fases posteriores.
- **Público:** corretores autônomos (CRECI individual) e proprietários com poucos imóveis. Não compete com QuintoAndar/Zap (marketplaces), e sim com planilha + WhatsApp manual, e com Imobia, Evoimob, Piloto Imóveis.
- **Diferencial pretendido:** onboarding via WhatsApp com OCR de documentos (CNH/RG), contrato em minutos, cobrança com split de pagamento nativo, portal do locatário.
- **Modelo de receita (hipótese não validada):** freemium até 3 contratos + pay-per-use por cobrança liquidada (~1,5–2,5%). Planos por carteira e módulos premium no futuro.
- **Equipe:** fundador solo (Emanoel).

---

## 3. Linha do tempo do que foi feito

| Data | Marco |
|---|---|
| 14/05/2026 | Repositório criado. README completo (posicionamento, stack, ERD, RLS, monetização, cronograma). PR #1 aberta (depois fechada sem merge). |
| 14/05/2026 | Decisões de stack registradas: Supabase, Asaas, Evolution API/Z-API, RLS desde o dia 1, pay-per-use, @react-pdf/renderer. |
| 22–23/06/2026 | Next.js inicializado, shadcn/ui, Supabase clients, middleware, validators Zod, server actions de auth, páginas de login/cadastro, migrations SQL. Build corrigido. |
| 23/06/2026 | Branch `development` criada; PR #2 ("Semana 1 — Setup técnico e autenticação") **mergeada**. Branches renomeadas para nomes legíveis; worktree do Claude removida. |
| 23/06/2026 | Projeto Supabase Cloud criado; `.env.local` configurado; guia `docs/setup-supabase.md` escrito; migration de policies de Storage escrita. Primeiro teste de cadastro chegou ao servidor. |
| 23/06 → hoje | **Sem atividade.** |

---

## 4. Estado do repositório (git)

### Branches

| Branch | Commit | Observação |
|---|---|---|
| `main` | `46c28dd` | Só README inicial + `.claude/`. **Não tem o código.** |
| `development` | `679c578` | Contém todo o código da Semana 1 (merge da PR #2). |
| `feature/supabase-cloud` | `f41b711` | Branch de trabalho atual; contém o guia do Supabase. |

### Situação do working tree — atenção

- O HEAD está **detached em `f41b711`** (não está em nenhuma branch).
- Há **alterações não commitadas**:

| Arquivo | Mudança |
|---|---|
| `src/app/actions/auth.ts` | Removido o `insert` manual em `profiles` no cadastro (o trigger `handle_new_user` já cria). |
| `src/app/auth/callback/route.ts` | Removido o insert/check de profile no callback OAuth (mesmo motivo). |
| `package.json` / `package-lock.json` | `@supabase/supabase-js` atualizado para `^2.108.2`. |
| `docs/setup-supabase.md` | Passo de Storage reescrito (policies via SQL) e query de validação corrigida (`pg_policies`). |
| `supabase/migrations/20260623000001_storage_policies.sql` | **Novo, não rastreado**: 14 policies de Storage. |

**Ação imediata:** voltar para `feature/supabase-cloud` (`git switch feature/supabase-cloud`) e commitar essas mudanças, ou elas ficam soltas.

### Problema de higiene

- O commit "Add .claude/" registrou `.claude/worktrees/angry-wu-bc76dd` como um item rastreado (aparece em `git ls-files`), mas a worktree foi deletada. Deve ser removido do índice (`git rm --cached .claude/worktrees/angry-wu-bc76dd`) e `.claude/` adicionado ao `.gitignore`.

### PRs

| PR | Título | Estado |
|---|---|---|
| #1 | Semana 0 — Arquitetura e Planejamento | Fechada (conteúdo veio via #2) |
| #2 | Semana 1 — Setup técnico e autenticação | Mergeada em `development` |

---

## 5. Inventário técnico

### 5.1 Stack em uso

Next.js 16.2.6 (App Router, Turbopack) · React 19.2 · TypeScript · Tailwind 4 · shadcn/ui sobre Base UI (`@base-ui/react`) · Supabase (`@supabase/ssr`, `supabase-js`) · Zod 4 · React Hook Form + resolvers · TanStack Query · `@react-pdf/renderer` · Resend (instalados, ainda sem uso).

### 5.2 Rotas existentes

| Rota | Estado |
|---|---|
| `/login` | Implementada (email/senha + botão Google) |
| `/cadastro` | Implementada (escolha locador/locatário) |
| `/dashboard` | Esqueleto com cards "—" (sem dados reais) |
| `/auth/callback` | Route handler do OAuth |
| `/` | Página inicial padrão do template Next.js (não é landing do ZUU) |
| `/recuperar-senha` | **Linkada no login, mas não existe** (404) |
| `/atualizar-senha` | Não existe (o reset aponta para `/auth/atualizar-senha`) |

### 5.3 Banco de dados

5 migrations em `supabase/migrations/`:

1. `20260514000001_enums.sql` — 15 enums
2. `20260514000002_tables.sql` — 12 tabelas (profiles, locador_details, locatario_details, properties, property_media, contracts, guarantors, charges, messages, documents, maintenance_requests, notifications)
3. `20260514000003_rls.sql` — RLS em todas as tabelas
4. `20260514000004_triggers.sql` — `handle_new_user` (cria profile ao registrar) e `updated_at`
5. `20260623000001_storage_policies.sql` — 14 policies para os buckets `avatars`, `properties`, `documents`, `contracts`

### 5.4 O que NÃO foi confirmado

Não tenho como verificar o painel do Supabase. Estes pontos ficaram em aberto na última sessão e precisam ser checados por você:

- [ ] A migration de Storage foi executada e a query de validação retornou 14 linhas?
- [ ] Os 4 buckets existem com os limites/MIME types corretos?
- [ ] O cadastro completo funcionou depois da correção (sem o insert manual)? O último erro visto foi **"email rate limit exceeded"** (limite de e-mail do plano Free); o workaround era desativar "Confirm email" ou criar usuário manualmente com Auto Confirm.
- [ ] Login com o usuário criado redireciona para `/dashboard`?
- [ ] Google OAuth: provedor configurado no Supabase e no Google Cloud? (não foi iniciado)

---

## 6. Problemas e dívidas técnicas identificados

### Bugs / lacunas de RLS (importantes antes de construir features)

1. **`profiles` — admin nunca enxerga tudo.** A policy `id = auth.uid() or role = 'admin'` avalia o `role` da *linha*, não o do usuário logado. Resultado: qualquer usuário vê perfis de admins, e o admin não ganha acesso a nada. Precisa de uma função `is_admin()` (security definer) e usá-la em todas as tabelas.
2. **Locador não consegue ver o locatário.** Para criar contrato, o locador precisa ler nome/telefone do locatário, mas `profiles` só libera a própria linha. Falta policy "partes de um mesmo contrato se enxergam" e uma forma de convidar/buscar locatário por e-mail.
3. **`locatario_details` / `locador_details`**: o locador não lê os dados do locatário do seu contrato (necessário para gerar o PDF).
4. **Operações que exigem service role** (webhook Asaas, cron de cobranças, geração de notificações) não têm cliente/chave server-only definidos. As tabelas `charges` e `notifications` não permitem INSERT pelo sistema via RLS comum.
5. **`properties` pública?** Os buckets `properties`/`avatars` são públicos, mas a tabela `properties` não é legível por quem não é locador/locatário — ok para o MVP, mas conflita com o futuro "marketplace".

### Código

6. **Convenção `middleware` deprecada** no Next 16 — o build avisa para renomear para `proxy`.
7. **Nome da variável do Supabase:** a UI nova chama a chave de *publishable key*; o código usa `NEXT_PUBLIC_SUPABASE_ANON_KEY`. Funciona, mas vale decidir um nome e documentar.
8. **Middleware só diferencia logado/deslogado.** O README promete proteção por role (locador vs locatário), que não existe.
9. **`cadastro` e `login` não tratam e-mail pendente de confirmação** (com "Confirm email" ligado, `signUp` não gera sessão e o redirect para `/dashboard` cai de volta em `/login`).
10. **Zero testes** (unitários, integração ou E2E).
11. **`.env.local.example` inexistente** — onboarding de outra máquina depende de memória.
12. **Documentação divergente:** README ainda marca tudo como pendente, com datas de junho/agosto, e a tabela de decisões não registra a decisão de remover o insert manual de profile.

---

## 7. O que falta (por módulo)

Legenda: ✅ feito · 🟡 parcial · ⬜ não iniciado

| Módulo / Fase | Estado | Observação |
|---|---|---|
| Arquitetura, ERD, decisões | ✅ | |
| Migrations SQL | ✅ | Revisar RLS (seção 6) |
| Auth — email/senha | 🟡 | Código pronto; fluxo não validado ponta a ponta |
| Auth — Google OAuth | 🟡 | Código pronto; provedor não configurado |
| Auth — recuperar/atualizar senha | ⬜ | Páginas inexistentes |
| Proteção por role | ⬜ | |
| Layout autenticado (sidebar/header/logout) | ⬜ | |
| Perfil + dados por role (PIX, RG, renda) | ⬜ | |
| CRUD de imóveis + upload de fotos | ⬜ | Validator Zod pronto |
| Contratos + PDF + convite do locatário | ⬜ | Validator Zod pronto |
| Dashboard real | ⬜ | Só esqueleto |
| Área do locatário | ⬜ | Rota `(locatario)` só criada vazia |
| Chat em tempo real | ⬜ | |
| Notificações in-app | ⬜ | |
| Asaas: cobrança, webhook, split, recibo | ⬜ | Sem conta Asaas |
| Cron jobs (cobranças, alertas, status) | ⬜ | |
| E-mails transacionais (Resend) | ⬜ | Dependência instalada, sem conta/SMTP |
| Landing page pública | ⬜ | |
| Hardening (RLS audit, logs, Sentry) | ⬜ | |
| Deploy (Vercel + domínio) | ⬜ | Sem domínio comprado |
| Fase 2: WhatsApp, OCR, assinatura eletrônica | ⬜ | Backlog |
| Fase 3: IA, DIMOB, marketplace | ⬜ | Backlog |

### Pendências de negócio (nunca decididas)

Domínio (`zuu.com.br` / `zuu.app`) · CNPJ/MEI · conta Asaas (sandbox) · cidade-alvo e primeiros 5 usuários piloto · identidade visual (cor, logo) · repositório público ou privado · beta fechado vs aberto.

---

## 8. Decisões que precisam ser tomadas

| # | Decisão | Recomendação |
|---|---|---|
| 1 | **Reduzir o escopo do MVP?** Pelo ritmo real (1 semana de trabalho em ~6 meses), as 8 semanas originais não se sustentam. | Cortar o MVP ao fluxo mínimo que prova valor: **auth → imóvel → contrato (PDF) → cobrança Asaas → recibo**. Chat, notificações push, landing elaborada e dashboard analítico ficam para depois. |
| 2 | Disponibilidade real | Definir horas/semana reais e fixar um novo marco com folga. O plano anterior assumia 3–5 h/dia. |
| 3 | Confirmação de e-mail | Desligada em dev. Em produção, ligar e configurar SMTP via Resend. |
| 4 | Como o locador adiciona um locatário | Convite por e-mail (link mágico) vs. busca de usuário existente. Define o desenho das policies de `profiles`. |
| 5 | Papel de admin | Usar função `is_admin()` + claim em `app_metadata`, ou tabela de admins. |
| 6 | Service role | Onde vive a chave server-only (webhooks/cron) e como é protegida. |
| 7 | Next 16: migrar `middleware` → `proxy` agora ou depois | Agora (mudança pequena, remove o aviso). |
| 8 | Branches: padronizar | `feature/*` → `development` → `main`; proteger `main`. `main` hoje não tem o código. |
| 9 | Ambientes | Um único projeto Supabase (Free) por ora; criar `zuu-staging` antes do deploy. |
| 10 | Validar mercado antes de construir mais? | Conversar com 5–10 corretores/proprietários na cidade-alvo antes da Semana 3 reduz o risco de construir o que ninguém usa. |

---

## 9. Plano proposto de retomada

> Premissa a confirmar: **~2 h/dia em dias úteis** (≈10 h/semana). Datas relativas à retomada; ajustar quando você definir o dia de início.

### Fase 0 — Higiene (1 sessão)
- Voltar para `feature/supabase-cloud`, commitar as mudanças pendentes, abrir PR → `development`.
- Remover o gitlink de `.claude/worktrees/...` do índice e ignorar `.claude/`.
- Atualizar o README (status, datas, decisões) e mergear `development` → `main`.
- Criar `.env.local.example`.

### Semana 1 — Auth validada
- Validar cadastro/login ponta a ponta (confirmação de e-mail desligada em dev).
- Corrigir RLS de `profiles` (`is_admin()`, visibilidade entre partes de contrato).
- Páginas de recuperar/atualizar senha; Google OAuth.
- Layout autenticado (sidebar, header, logout) e proteção por role.
- Migrar `middleware` → `proxy`.

### Semana 2 — Perfil + Imóveis
- Perfil e dados bancários/pessoais por role.
- CRUD de imóveis com upload de fotos (Storage já pronto), listagem e filtros.

### Semana 3 — Contratos
- Formulário de contrato, convite do locatário, PDF, visão do locatário.

### Semana 4 — Cobrança (Asaas sandbox)
- Cliente + cobrança PIX/boleto, webhook, split, recibo PDF.

### Semana 5 — Automação mínima + deploy
- Cron de cobranças mensais e marcação de atrasadas; e-mails essenciais.
- Deploy Vercel + domínio, Supabase de produção, revisão final de RLS.

### Semana 6 — Pilotos
- Onboarding de 3–5 usuários reais, correção de bugs.

**Marco proposto:** MVP em produção ao fim da Semana 6 a partir da retomada. Chat, notificações in-app, landing completa e dashboard analítico entram depois, guiados pelo feedback dos pilotos.

---

## 10. Próximas 5 ações concretas

1. `git switch feature/supabase-cloud` e commitar as alterações pendentes.
2. Confirmar no painel do Supabase: policies de Storage (14), buckets (4), usuário de teste e linha em `profiles`.
3. Testar login/cadastro com "Confirm email" desligado.
4. Definir horas/semana e a data de retomada para fixar o novo marco.
5. Decidir o escopo cortado do MVP (decisão 1) e registrá-lo no README.

---

## Apêndice — Referências no repositório

- Guia de setup do Supabase: [docs/setup-supabase.md](setup-supabase.md)
- README (visão geral, ERD, RLS, cronograma antigo): [README.md](../README.md)
- Migrations: [supabase/migrations/](../supabase/migrations)
- Tipos do banco: [src/types/database.ts](../src/types/database.ts)
- Server actions de auth: [src/app/actions/auth.ts](../src/app/actions/auth.ts)
