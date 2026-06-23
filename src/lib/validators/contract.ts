import { z } from 'zod'

export const contractSchema = z.object({
  property_id: z.string().uuid('Imóvel inválido'),
  locatario_id: z.string().uuid('Locatário inválido'),
  start_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Data inválida'),
  end_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Data inválida'),
  rent_value: z.number().positive('Valor do aluguel deve ser positivo'),
  condo_fee: z.number().min(0).default(0),
  iptu: z.number().min(0).default(0),
  deposit_value: z.number().min(0).default(0),
  due_day: z.number().int().min(1).max(28, 'Dia de vencimento deve ser entre 1 e 28'),
  adjustment_index: z.enum(['igpm', 'ipca', 'ivar', 'inpc']).default('igpm'),
  adjustment_months: z.number().int().positive().default(12),
  fine_percentage: z.number().min(0).max(100).default(10),
  guarantee_type: z.enum(['deposit', 'guarantor', 'insurance', 'none']).default('none'),
  pets_allowed: z.boolean().default(false),
  notes: z.string().optional(),
})

export type ContractInput = z.infer<typeof contractSchema>
