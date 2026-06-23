'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import type { LoginInput, CadastroInput, ResetPasswordInput } from '@/lib/validators/auth'

export async function login(data: LoginInput) {
  const supabase = await createClient()

  const { error } = await supabase.auth.signInWithPassword({
    email: data.email,
    password: data.password,
  })

  if (error) return { error: error.message }

  revalidatePath('/', 'layout')
  redirect('/dashboard')
}

export async function cadastro(data: CadastroInput) {
  const supabase = await createClient()

  const { data: authData, error } = await supabase.auth.signUp({
    email: data.email,
    password: data.password,
    options: {
      data: {
        name: data.name,
        role: data.role,
        phone: data.phone ?? null,
      },
    },
  })

  if (error) return { error: error.message }
  if (!authData.user) return { error: 'Erro ao criar usuário' }

  const { error: profileError } = await supabase.from('profiles').insert({
    id: authData.user.id,
    name: data.name,
    role: data.role,
    phone: data.phone ?? null,
  })

  if (profileError) return { error: profileError.message }

  revalidatePath('/', 'layout')
  redirect('/dashboard')
}

export async function loginComGoogle() {
  const supabase = await createClient()

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/auth/callback`,
    },
  })

  if (error) throw new Error(error.message)
  if (data.url) redirect(data.url)
}

export async function resetPassword(data: ResetPasswordInput) {
  const supabase = await createClient()

  const { error } = await supabase.auth.resetPasswordForEmail(data.email, {
    redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/auth/atualizar-senha`,
  })

  if (error) return { error: error.message }
  return { success: true }
}

export async function logout() {
  const supabase = await createClient()
  await supabase.auth.signOut()
  revalidatePath('/', 'layout')
  redirect('/login')
}
