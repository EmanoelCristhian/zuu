export type UserRole = 'admin' | 'locador' | 'locatario'
export type PropertyType = 'apartment' | 'house' | 'room' | 'commercial' | 'land'
export type PropertyStatus = 'available' | 'rented' | 'reserved' | 'maintenance'
export type ContractStatus = 'draft' | 'pending_signature' | 'active' | 'terminated' | 'expired'
export type AdjustmentIndex = 'igpm' | 'ipca' | 'ivar' | 'inpc'
export type GuaranteeType = 'deposit' | 'guarantor' | 'insurance' | 'none'
export type ChargeType = 'rent' | 'condo' | 'iptu' | 'fine' | 'repair' | 'other'
export type ChargeStatus = 'pending' | 'paid' | 'overdue' | 'cancelled'
export type PaymentMethod = 'pix' | 'boleto' | 'transfer' | 'cash'
export type DocumentType = 'rg' | 'cpf' | 'cnh' | 'income_proof' | 'contract' | 'inspection' | 'other'
export type MessageType = 'text' | 'image' | 'document'
export type NotificationType = 'charge_due' | 'charge_paid' | 'contract_expiring' | 'new_message' | 'maintenance' | 'other'
export type MaintenanceStatus = 'open' | 'in_progress' | 'resolved' | 'cancelled'
export type MaintenancePriority = 'low' | 'medium' | 'high' | 'urgent'
export type MediaType = 'photo' | 'video' | 'document'

export interface Profile {
  id: string
  role: UserRole
  name: string
  cpf: string | null
  phone: string | null
  avatar_url: string | null
  created_at: string
  updated_at: string | null
}

export interface LocadorDetails {
  id: string
  profile_id: string
  pix_key: string | null
  bank: string | null
  agency: string | null
  account: string | null
}

export interface LocatarioDetails {
  id: string
  profile_id: string
  rg: string | null
  profession: string | null
  monthly_income: number | null
  marital_status: string | null
}

export interface Property {
  id: string
  locador_id: string
  title: string
  description: string | null
  type: PropertyType
  status: PropertyStatus
  address_street: string
  address_number: string | null
  address_complement: string | null
  address_neighborhood: string
  address_city: string
  address_state: string
  address_zip: string
  lat: number | null
  lng: number | null
  rent_value: number
  condo_fee: number
  iptu: number
  deposit: number
  bedrooms: number
  bathrooms: number
  parking_spots: number
  area_sqm: number | null
  furnished: boolean
  created_at: string
  updated_at: string | null
}

export interface PropertyMedia {
  id: string
  property_id: string
  type: MediaType
  url: string
  order: number
  created_at: string
}

export interface Contract {
  id: string
  property_id: string
  locador_id: string
  locatario_id: string
  status: ContractStatus
  start_date: string
  end_date: string
  rent_value: number
  condo_fee: number
  iptu: number
  deposit_value: number
  due_day: number
  adjustment_index: AdjustmentIndex
  adjustment_months: number
  fine_percentage: number
  guarantee_type: GuaranteeType
  pets_allowed: boolean
  notes: string | null
  pdf_url: string | null
  signed_at: string | null
  terminated_at: string | null
  termination_reason: string | null
  created_at: string
  updated_at: string | null
}

export interface Guarantor {
  id: string
  contract_id: string
  name: string
  cpf: string
  phone: string | null
  email: string | null
  address: string | null
  created_at: string
}

export interface Charge {
  id: string
  contract_id: string
  locatario_id: string
  locador_id: string
  type: ChargeType
  description: string | null
  amount: number
  due_date: string
  paid_at: string | null
  status: ChargeStatus
  payment_method: PaymentMethod | null
  asaas_charge_id: string | null
  asaas_invoice_url: string | null
  asaas_pix_qrcode: string | null
  receipt_url: string | null
  created_at: string
  updated_at: string | null
}

export interface Message {
  id: string
  contract_id: string
  sender_id: string
  content: string
  type: MessageType
  attachment_url: string | null
  read_at: string | null
  created_at: string
}

export interface Document {
  id: string
  owner_id: string
  contract_id: string | null
  property_id: string | null
  type: DocumentType
  name: string
  url: string
  ocr_data: Record<string, unknown> | null
  created_at: string
}

export interface MaintenanceRequest {
  id: string
  contract_id: string
  locatario_id: string
  title: string
  description: string | null
  status: MaintenanceStatus
  priority: MaintenancePriority
  photos: string[] | null
  resolved_at: string | null
  created_at: string
  updated_at: string | null
}

export interface Notification {
  id: string
  user_id: string
  type: NotificationType
  title: string
  body: string | null
  read_at: string | null
  metadata: Record<string, unknown> | null
  created_at: string
}
