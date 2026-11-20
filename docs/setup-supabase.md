# Setup do Supabase Cloud — Guia Passo a Passo

> Meta do dia: ter 23/06/2026
> Tempo estimado: 30–45 min
> Pré-requisito: build passando (`npm run build` ✅)

---

## Passo 1 — Criar conta e projeto no Supabase (5 min)

1. Abra [supabase.com](https://supabase.com) e clique em **Start your project**
2. Faça login com GitHub (usa o mesmo do repo)
3. Clique em **New project**
4. Preencha:
   - **Organization:** sua org pessoal (a que aparecer)
   - **Name:** `zuu`
   - **Database Password:** gere uma senha forte e **salve no seu gerenciador de senhas agora** (não vai dar pra recuperar depois)
   - **Region:** `South America (São Paulo) — sa-east-1` (latência mínima pro Brasil)
   - **Pricing Plan:** Free
5. Clique em **Create new project** e aguarde ~2 minutos (provisionamento)

---

## Passo 2 — Copiar credenciais (2 min)

Quando o projeto subir:

1. Vá em **Project Settings** (engrenagem no canto inferior esquerdo) → **API**
2. Copie:
   - **Project URL** → cola em `NEXT_PUBLIC_SUPABASE_URL`
   - **Project API Keys → anon public** → cola em `NEXT_PUBLIC_SUPABASE_ANON_KEY`

Edite `.env.local` no projeto:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR...
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

⚠️ `.env.local` está no `.gitignore` — nunca commitar.

---

## Passo 3 — Rodar as 4 migrations (10 min)

No painel Supabase, vá em **SQL Editor** (ícone de banco de dados na barra lateral).

Rode na ordem (clique **New query**, cole, clique **Run**):

### 3.1 — Enums
Abra `supabase/migrations/20260514000001_enums.sql`, cole o conteúdo todo no SQL Editor e rode.
Esperado: `Success. No rows returned`.

### 3.2 — Tabelas
Abra `supabase/migrations/20260514000002_tables.sql`, cole e rode.
Esperado: 12 tabelas criadas. Verifique em **Table Editor** se aparecem: profiles, locador_details, locatario_details, properties, property_media, contracts, guarantors, charges, messages, documents, maintenance_requests, notifications.

### 3.3 — RLS (Row Level Security)
Abra `supabase/migrations/20260514000003_rls.sql`, cole e rode.
Esperado: políticas criadas. No **Table Editor**, cada tabela deve mostrar o ícone de cadeado (RLS habilitado).

### 3.4 — Triggers
Abra `supabase/migrations/20260514000004_triggers.sql`, cole e rode.
Esperado: 2 funções criadas (`handle_new_user`, `set_updated_at`) + triggers.

> A 5ª migration (`20260623000001_storage_policies.sql`) é rodada no passo 4.1, depois que os buckets existirem.

---

## Passo 4 — Criar os 4 buckets Storage (5 min)

Vá em **Storage** (ícone de pasta na barra lateral) → **New bucket**.

Crie os 4 buckets na UI (só a criação — policies a gente faz via SQL no passo 4.1):

| Bucket | Public | Allowed MIME types | File size limit |
|---|---|---|---|
| `avatars` | ✅ Public | `image/jpeg,image/png,image/webp` | 2 MB |
| `properties` | ✅ Public | `image/jpeg,image/png,image/webp` | 5 MB |
| `documents` | ❌ Private | `image/jpeg,image/png,application/pdf` | 10 MB |
| `contracts` | ❌ Private | `application/pdf` | 10 MB |

**Por que cada um:**
- `avatars` + `properties` são públicos para servir imagens via CDN sem assinar URL
- `documents` + `contracts` privados — só as partes autorizadas acessam via signed URL

### 4.1 Policies via SQL — pula a UI inteira (3 min)

Criar 16 policies clicando em modais é doloroso e fácil de errar. **Skip a UI** e rode o SQL pronto.

No **SQL Editor → New query**, cole o conteúdo de `supabase/migrations/20260623000001_storage_policies.sql` e rode.

Isso cria 14 policies cobrindo:

| Bucket | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `avatars` | público | dono (`auth.uid()`) | dono | dono |
| `properties` | público | locador do imóvel | locador do imóvel | locador do imóvel |
| `documents` | dono | dono | — | dono |
| `contracts` | locador OU locatário do contrato | locador | locador | — |

**Convenção de caminhos no Storage:**
- `avatars/{user_id}/avatar.jpg`
- `properties/{property_id}/1.jpg`, `properties/{property_id}/2.jpg`...
- `documents/{user_id}/{document_id}.pdf`
- `contracts/{contract_id}/contrato.pdf`

Essa convenção é o que faz as policies funcionarem — a primeira pasta do caminho é o ID de quem tem permissão.

### Validação rápida

No SQL Editor:
```sql
select policyname, cmd
from pg_policies
where schemaname = 'storage' and tablename = 'objects'
order by policyname;
```

Deve listar 14 linhas:
- 4 do `avatars` (select, insert, update, delete)
- 4 do `properties` (select, insert, update, delete)
- 3 do `documents` (select, insert, delete)
- 3 do `contracts` (select, insert, update)

---

## Passo 5 — Testar a conexão (5 min)

No terminal do projeto:

```bash
npm run dev
```

Abra http://localhost:3000.

**Cenário 1 — não logado:** Deve redirecionar para `/login` (middleware funcionando).

**Cenário 2 — cadastro:**
1. Vá em http://localhost:3000/cadastro
2. Preencha: nome, e-mail real seu, telefone, senha (mínimo 6 chars), escolha "Proprietário"
3. Clique em **Criar conta**

**Esperado:**
- Redirect para `/dashboard`
- Aparece "Olá, [seu nome]"

**Validação no Supabase:**
- **Authentication → Users** — seu e-mail aparece
- **Table Editor → profiles** — uma linha com seu nome, role `locador`, mesmo id do usuário em Authentication

Se aparecer tudo isso: ✅ **fluxo end-to-end funcionando.**

---

## Passo 6 — Troubleshooting comum

### "Invalid API key" ou "Failed to fetch"
- Confira se `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY` estão certos
- Reinicie o `npm run dev` (variáveis `NEXT_PUBLIC_*` exigem restart)

### Cadastro funciona no Auth mas não cria linha em `profiles`
- O trigger `on_auth_user_created` não foi executado — rode novamente a migration `004_triggers.sql`
- Ou cheque em **Database → Triggers** se o trigger aparece em `auth.users`

### "permission denied for table profiles"
- RLS não foi configurado — rode `003_rls.sql`

### "duplicate key value violates unique constraint profiles_pkey"
- O Server Action está tentando inserir profile manualmente, mas o trigger já fez isso
- **Solução:** abrir `src/app/actions/auth.ts` e remover o `.insert()` em `cadastro` (depois que confirmar que o trigger funciona)

---

## Checklist final do dia

- [ ] Projeto Supabase criado em região São Paulo
- [ ] Senha do banco salva no gerenciador
- [ ] `.env.local` atualizado com URL e anon key reais
- [ ] 4 migrations rodadas sem erro
- [ ] 12 tabelas visíveis no Table Editor com RLS habilitado
- [ ] 4 buckets criados com policies corretas
- [ ] `npm run dev` rodando
- [ ] Cadastro de teste criou usuário em `auth.users` E linha em `profiles`
- [ ] Login com o mesmo e-mail redireciona para `/dashboard`

Se todos os itens checaram: ✅ **meta de ter 23/06 concluída.**

---

## Próximo passo (qua 24/06)

OAuth Google + páginas `/recuperar-senha` e `/atualizar-senha`. Crie a branch:

```bash
git checkout development
git pull
git checkout -b feature/oauth-google
```
