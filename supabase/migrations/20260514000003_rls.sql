-- Ativa RLS em todas as tabelas
alter table profiles enable row level security;
alter table locador_details enable row level security;
alter table locatario_details enable row level security;
alter table properties enable row level security;
alter table property_media enable row level security;
alter table contracts enable row level security;
alter table guarantors enable row level security;
alter table charges enable row level security;
alter table messages enable row level security;
alter table documents enable row level security;
alter table maintenance_requests enable row level security;
alter table notifications enable row level security;

-- ==================== profiles ====================
create policy "profiles: leitura própria ou admin"
  on profiles for select
  using (id = auth.uid() or role = 'admin');

create policy "profiles: edição própria"
  on profiles for update
  using (id = auth.uid());

create policy "profiles: inserção no cadastro"
  on profiles for insert
  with check (id = auth.uid());

-- ==================== locador_details ====================
create policy "locador_details: leitura própria"
  on locador_details for select
  using (profile_id = auth.uid());

create policy "locador_details: escrita própria"
  on locador_details for all
  using (profile_id = auth.uid());

-- ==================== locatario_details ====================
create policy "locatario_details: leitura própria"
  on locatario_details for select
  using (profile_id = auth.uid());

create policy "locatario_details: escrita própria"
  on locatario_details for all
  using (profile_id = auth.uid());

-- ==================== properties ====================
create policy "properties: locador vê as suas"
  on properties for select
  using (locador_id = auth.uid());

create policy "properties: locatário vê as do seu contrato"
  on properties for select
  using (
    id in (
      select property_id from contracts
      where locatario_id = auth.uid()
    )
  );

create policy "properties: locador gerencia as suas"
  on properties for insert
  with check (locador_id = auth.uid());

create policy "properties: locador atualiza as suas"
  on properties for update
  using (locador_id = auth.uid());

create policy "properties: locador exclui as suas"
  on properties for delete
  using (locador_id = auth.uid());

-- ==================== property_media ====================
create policy "property_media: visível se property visível"
  on property_media for select
  using (
    property_id in (select id from properties)
  );

create policy "property_media: locador gerencia mídia das suas propriedades"
  on property_media for all
  using (
    property_id in (select id from properties where locador_id = auth.uid())
  );

-- ==================== contracts ====================
create policy "contracts: participantes veem"
  on contracts for select
  using (locador_id = auth.uid() or locatario_id = auth.uid());

create policy "contracts: locador cria"
  on contracts for insert
  with check (locador_id = auth.uid());

create policy "contracts: locador atualiza"
  on contracts for update
  using (locador_id = auth.uid());

-- ==================== guarantors ====================
create policy "guarantors: locador do contrato acessa"
  on guarantors for all
  using (
    contract_id in (select id from contracts where locador_id = auth.uid())
  );

-- ==================== charges ====================
create policy "charges: participantes veem"
  on charges for select
  using (locador_id = auth.uid() or locatario_id = auth.uid());

create policy "charges: locador gerencia"
  on charges for insert
  with check (locador_id = auth.uid());

create policy "charges: locador atualiza"
  on charges for update
  using (locador_id = auth.uid());

-- ==================== messages ====================
create policy "messages: participantes do contrato veem"
  on messages for select
  using (
    contract_id in (
      select id from contracts
      where locador_id = auth.uid() or locatario_id = auth.uid()
    )
  );

create policy "messages: participantes do contrato enviam"
  on messages for insert
  with check (
    sender_id = auth.uid()
    and contract_id in (
      select id from contracts
      where locador_id = auth.uid() or locatario_id = auth.uid()
    )
  );

-- ==================== documents ====================
create policy "documents: dono ou participante do contrato vê"
  on documents for select
  using (
    owner_id = auth.uid()
    or contract_id in (
      select id from contracts
      where locador_id = auth.uid() or locatario_id = auth.uid()
    )
  );

create policy "documents: usuário insere os seus"
  on documents for insert
  with check (owner_id = auth.uid());

create policy "documents: dono atualiza"
  on documents for update
  using (owner_id = auth.uid());

create policy "documents: dono exclui"
  on documents for delete
  using (owner_id = auth.uid());

-- ==================== maintenance_requests ====================
create policy "maintenance: participantes do contrato veem"
  on maintenance_requests for select
  using (
    contract_id in (
      select id from contracts
      where locador_id = auth.uid() or locatario_id = auth.uid()
    )
  );

create policy "maintenance: locatário abre solicitação"
  on maintenance_requests for insert
  with check (locatario_id = auth.uid());

create policy "maintenance: locador atualiza status"
  on maintenance_requests for update
  using (
    contract_id in (select id from contracts where locador_id = auth.uid())
  );

-- ==================== notifications ====================
create policy "notifications: cada um vê as suas"
  on notifications for select
  using (user_id = auth.uid());

create policy "notifications: cada um atualiza as suas"
  on notifications for update
  using (user_id = auth.uid());
