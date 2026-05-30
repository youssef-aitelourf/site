import { createAdminClient } from "@/lib/supabase/admin";

const USERNAME_RE = /^[a-z0-9_-]{3,32}$/;

export function normalizeUsername(value: string): string {
  return value.trim().toLowerCase();
}

export function isValidUsername(username: string): boolean {
  return USERNAME_RE.test(normalizeUsername(username));
}

export function isEmailLike(value: string): boolean {
  return value.trim().includes("@");
}

/** Résout identifiant de connexion (email ou username) vers l'email Supabase Auth. */
export async function resolveLoginEmail(identifier: string): Promise<string | null> {
  const raw = identifier.trim();
  if (!raw) return null;

  if (isEmailLike(raw)) {
    return raw.toLowerCase();
  }

  const username = normalizeUsername(raw);
  if (!isValidUsername(username)) {
    return null;
  }

  const admin = createAdminClient();
  const { data } = await admin
    .from("profiles")
    .select("email")
    .eq("username", username)
    .eq("active", true)
    .maybeSingle();

  return data?.email?.toLowerCase() ?? null;
}

/** Email interne si aucun email fourni à la création de compte. */
export function internalEmailForUsername(username: string): string {
  return `${normalizeUsername(username)}@accounts.youssef-aitelourf.com`;
}
