-- =====================================================
-- Storage Policies para os 4 buckets do Zuu
-- =====================================================
-- Convenção de caminhos:
--   avatars/{user_id}/avatar.{ext}
--   properties/{property_id}/{n}.{ext}
--   documents/{user_id}/{document_id}.{ext}
--   contracts/{contract_id}/contrato.pdf
-- =====================================================

-- =====================================================
-- BUCKET: avatars (público)
-- =====================================================

create policy "avatars: qualquer um vê (CDN)"
on storage.objects for select
to public
using (bucket_id = 'avatars');

create policy "avatars: usuário sobe o próprio"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "avatars: usuário atualiza o próprio"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "avatars: usuário deleta o próprio"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- =====================================================
-- BUCKET: properties (público — fotos de imóveis)
-- =====================================================

create policy "properties: qualquer um vê"
on storage.objects for select
to public
using (bucket_id = 'properties');

create policy "properties: locador dono do imóvel sobe"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'properties'
  and (storage.foldername(name))[1] in (
    select id::text from properties where locador_id = auth.uid()
  )
);

create policy "properties: locador atualiza fotos"
on storage.objects for update
to authenticated
using (
  bucket_id = 'properties'
  and (storage.foldername(name))[1] in (
    select id::text from properties where locador_id = auth.uid()
  )
);

create policy "properties: locador deleta fotos"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'properties'
  and (storage.foldername(name))[1] in (
    select id::text from properties where locador_id = auth.uid()
  )
);

-- =====================================================
-- BUCKET: documents (privado — RG, CNH, comprovante renda)
-- =====================================================

create policy "documents: dono vê os próprios"
on storage.objects for select
to authenticated
using (
  bucket_id = 'documents'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "documents: dono sobe os próprios"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'documents'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "documents: dono deleta os próprios"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'documents'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- =====================================================
-- BUCKET: contracts (privado — PDF compartilhado entre as partes)
-- =====================================================

create policy "contracts: partes do contrato veem"
on storage.objects for select
to authenticated
using (
  bucket_id = 'contracts'
  and (storage.foldername(name))[1] in (
    select id::text from contracts
    where locador_id = auth.uid() or locatario_id = auth.uid()
  )
);

create policy "contracts: locador sobe PDF"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'contracts'
  and (storage.foldername(name))[1] in (
    select id::text from contracts where locador_id = auth.uid()
  )
);

create policy "contracts: locador atualiza PDF"
on storage.objects for update
to authenticated
using (
  bucket_id = 'contracts'
  and (storage.foldername(name))[1] in (
    select id::text from contracts where locador_id = auth.uid()
  )
);
