-- profiles (estende auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role user_role not null,
  name text not null,
  cpf text unique,
  phone text,
  avatar_url text,
  created_at timestamptz default now() not null,
  updated_at timestamptz
);

-- locador_details
create table locador_details (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique not null references profiles(id) on delete cascade,
  pix_key text,
  bank text,
  agency text,
  account text
);

-- locatario_details
create table locatario_details (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique not null references profiles(id) on delete cascade,
  rg text,
  profession text,
  monthly_income numeric,
  marital_status text
);

-- properties
create table properties (
  id uuid primary key default gen_random_uuid(),
  locador_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  description text,
  type property_type not null,
  status property_status not null default 'available',
  address_street text not null,
  address_number text,
  address_complement text,
  address_neighborhood text not null,
  address_city text not null,
  address_state char(2) not null,
  address_zip text not null,
  lat numeric,
  lng numeric,
  rent_value numeric not null,
  condo_fee numeric not null default 0,
  iptu numeric not null default 0,
  deposit numeric not null default 0,
  bedrooms int not null default 0,
  bathrooms int not null default 0,
  parking_spots int not null default 0,
  area_sqm numeric,
  furnished boolean not null default false,
  created_at timestamptz default now() not null,
  updated_at timestamptz
);

-- property_media
create table property_media (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  type media_type not null,
  url text not null,
  "order" int not null default 0,
  created_at timestamptz default now() not null
);

-- contracts
create table contracts (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id),
  locador_id uuid not null references profiles(id),
  locatario_id uuid not null references profiles(id),
  status contract_status not null default 'draft',
  start_date date not null,
  end_date date not null,
  rent_value numeric not null,
  condo_fee numeric not null default 0,
  iptu numeric not null default 0,
  deposit_value numeric not null default 0,
  due_day int not null check (due_day between 1 and 28),
  adjustment_index adjustment_index not null default 'igpm',
  adjustment_months int not null default 12,
  fine_percentage numeric not null default 10,
  guarantee_type guarantee_type not null default 'none',
  pets_allowed boolean not null default false,
  notes text,
  pdf_url text,
  signed_at timestamptz,
  terminated_at timestamptz,
  termination_reason text,
  created_at timestamptz default now() not null,
  updated_at timestamptz
);

-- guarantors
create table guarantors (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id) on delete cascade,
  name text not null,
  cpf text not null,
  phone text,
  email text,
  address text,
  created_at timestamptz default now() not null
);

-- charges
create table charges (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id) on delete cascade,
  locatario_id uuid not null references profiles(id),
  locador_id uuid not null references profiles(id),
  type charge_type not null,
  description text,
  amount numeric not null,
  due_date date not null,
  paid_at timestamptz,
  status charge_status not null default 'pending',
  payment_method payment_method,
  asaas_charge_id text,
  asaas_invoice_url text,
  asaas_pix_qrcode text,
  receipt_url text,
  created_at timestamptz default now() not null,
  updated_at timestamptz
);

-- messages
create table messages (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id) on delete cascade,
  sender_id uuid not null references profiles(id),
  content text not null,
  type message_type not null default 'text',
  attachment_url text,
  read_at timestamptz,
  created_at timestamptz default now() not null
);

-- documents
create table documents (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references profiles(id) on delete cascade,
  contract_id uuid references contracts(id) on delete set null,
  property_id uuid references properties(id) on delete set null,
  type document_type not null,
  name text not null,
  url text not null,
  ocr_data jsonb,
  created_at timestamptz default now() not null
);

-- maintenance_requests
create table maintenance_requests (
  id uuid primary key default gen_random_uuid(),
  contract_id uuid not null references contracts(id) on delete cascade,
  locatario_id uuid not null references profiles(id),
  title text not null,
  description text,
  status maintenance_status not null default 'open',
  priority maintenance_priority not null default 'medium',
  photos text[],
  resolved_at timestamptz,
  created_at timestamptz default now() not null,
  updated_at timestamptz
);

-- notifications
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  type notification_type not null,
  title text not null,
  body text,
  read_at timestamptz,
  metadata jsonb,
  created_at timestamptz default now() not null
);
