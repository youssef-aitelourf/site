import Link from "next/link";
import { getProfile } from "@/lib/auth";
import LogoutButton from "./logout-button";

export default async function AdminPage() {
  const profile = await getProfile();
  const isSuperAdmin = profile?.role === "super_admin";

  return (
    <main className="mx-auto max-w-2xl px-4 py-16">
      <h1 className="mb-2 text-3xl font-bold tracking-tight">Admin</h1>
      <p className="mb-10 text-slate-500">youssef-aitelourf.com</p>

      <div className="grid gap-3">
        <Link
          href="/admin/health-app"
          className="rounded-xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm font-medium text-slate-700 hover:bg-slate-100 transition-colors"
        >
          Health App — Nutrition, entraînement & poids
        </Link>
      </div>

      {isSuperAdmin && (
        <nav className="mt-8">
          <Link
            href="/admin/users"
            className="text-sm font-medium text-slate-700 underline-offset-2 hover:underline"
          >
            Gérer les utilisateurs
          </Link>
        </nav>
      )}

      <LogoutButton />
    </main>
  );
}
