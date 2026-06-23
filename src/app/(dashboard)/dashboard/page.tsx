import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

export default async function DashboardPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()

  if (!profile) redirect('/login')

  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold mb-2">Olá, {profile.name}</h1>
      <p className="text-gray-500 mb-8">
        {profile.role === 'locador' ? 'Painel do Gestor' : 'Minha Área'}
      </p>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard label="Imóveis ativos" value="—" />
        <StatCard label="Contratos ativos" value="—" />
        <StatCard label="Cobranças pendentes" value="—" />
        <StatCard label="Inadimplência" value="—" />
      </div>
    </main>
  )
}

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border bg-white p-6 shadow-sm">
      <p className="text-sm text-gray-500">{label}</p>
      <p className="mt-1 text-3xl font-bold">{value}</p>
    </div>
  )
}
