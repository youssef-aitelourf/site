import Link from "next/link";
import { redirect } from "next/navigation";
import { hasRole } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import CreateUserForm from "./create-user-form";

export default async function UsersPage() {
  if (!(await hasRole(["super_admin"]))) {
    redirect("/admin");
  }

  const admin = createAdminClient();
  const { data: users, error } = await admin
    .from("profiles")
    .select("id, username, email, role, active, created_at")
    .order("created_at", { ascending: false });

  return (
    <main className="mx-auto max-w-2xl px-4 py-16">
      <div className="mb-8 flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Utilisateurs</h1>
        <Link href="/admin" className="text-sm text-slate-500 hover:text-slate-700">
          ← Admin
        </Link>
      </div>

      <CreateUserForm />

      {error && (
        <p className="mb-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">
          {error.message}
        </p>
      )}

      <div className="overflow-hidden rounded-xl border border-slate-200">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-left text-slate-600">
            <tr>
              <th className="px-4 py-3 font-medium">Username</th>
              <th className="px-4 py-3 font-medium">Email</th>
              <th className="px-4 py-3 font-medium">Rôle</th>
              <th className="px-4 py-3 font-medium">Actif</th>
            </tr>
          </thead>
          <tbody>
            {users && users.length > 0 ? (
              users.map((user) => (
                <tr key={user.id} className="border-t border-slate-200">
                  <td className="px-4 py-3 font-medium text-slate-900">{user.username ?? "—"}</td>
                  <td className="px-4 py-3 text-slate-600">{user.email ?? "—"}</td>
                  <td className="px-4 py-3 text-slate-600">{user.role}</td>
                  <td className="px-4 py-3 text-slate-600">{user.active ? "oui" : "non"}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={4} className="px-4 py-6 text-center text-slate-500">
                  Aucun utilisateur trouvé.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </main>
  );
}
