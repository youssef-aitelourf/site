"use client";

import Link from "next/link";
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

      <div className="grid gap-4">
        <Link
          href="/admin/cv-adapter"
          className="flex items-center justify-between rounded-xl border border-slate-200 bg-white p-5 shadow-sm hover:shadow-md transition-shadow"
        >
          <div>
            <p className="font-semibold text-slate-900">CV Adapter</p>
            <p className="mt-0.5 text-sm text-slate-500">
              Adapte un CV LaTeX à une offre d&apos;emploi — score ATS avant/après.
            </p>
          </div>
          <span className="text-slate-400">→</span>
        </Link>
      </div>

      <button
        onClick={handleLogout}
        className="mt-12 text-sm text-slate-400 hover:text-slate-600"
      >
        Se déconnecter
      </button>
    </main>
  );
}
