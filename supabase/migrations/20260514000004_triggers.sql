-- Cria profile automaticamente ao registrar via Supabase Auth
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into profiles (id, name, role, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', new.email),
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'locador'),
    new.raw_user_meta_data->>'phone'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- Atualiza updated_at automaticamente
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at
  before update on profiles
  for each row execute procedure set_updated_at();

create trigger set_properties_updated_at
  before update on properties
  for each row execute procedure set_updated_at();

create trigger set_contracts_updated_at
  before update on contracts
  for each row execute procedure set_updated_at();

create trigger set_charges_updated_at
  before update on charges
  for each row execute procedure set_updated_at();

create trigger set_maintenance_updated_at
  before update on maintenance_requests
  for each row execute procedure set_updated_at();
