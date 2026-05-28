"use client";

import { useRouter } from "next/navigation";

export default function AdminPage() {
  const router = useRouter();

  async function handleLogout() {
    await fetch("/api/auth", { method: "DELETE" });
    router.push("/admin/login");
  }

  return (
    <main className="mx-auto max-w-2xl px-4 py-16">
      <h1 className="mb-2 text-3xl font-bold tracking-tight">Admin</h1>
      <p className="mb-10 text-slate-500">youssef-aitelourf.com</p>

      <p className="rounded-xl border border-slate-200 bg-slate-50 px-5 py-4 text-sm text-slate-600">
        Aucun outil actif pour le moment. CV Adapter est désactivé.
      </p>

      <button
        onClick={handleLogout}
        className="mt-12 text-sm text-slate-400 hover:text-slate-600"
      >
        Se déconnecter
      </button>
    </main>
  );
}
