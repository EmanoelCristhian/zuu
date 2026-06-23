import { z } from 'zod'

export const propertySchema = z.object({
  title: z.string().min(3, 'Título deve ter ao menos 3 caracteres'),
  description: z.string().optional(),
  type: z.enum(['apartment', 'house', 'room', 'commercial', 'land']),
  address_street: z.string().min(3, 'Endereço obrigatório'),
  address_number: z.string().optional(),
  address_complement: z.string().optional(),
  address_neighborhood: z.string().min(2, 'Bairro obrigatório'),
  address_city: z.string().min(2, 'Cidade obrigatória'),
  address_state: z.string().length(2, 'UF inválida'),
  address_zip: z.string().length(8, 'CEP inválido'),
  rent_value: z.number().positive('Valor do aluguel deve ser positivo'),
  condo_fee: z.number().min(0).default(0),
  iptu: z.number().min(0).default(0),
  deposit: z.number().min(0).default(0),
  bedrooms: z.number().int().min(0).default(0),
  bathrooms: z.number().int().min(0).default(0),
  parking_spots: z.number().int().min(0).default(0),
  area_sqm: z.number().positive().optional(),
  furnished: z.boolean().default(false),
})

export type PropertyInput = z.infer<typeof propertySchema>
