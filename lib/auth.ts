import { createClient } from "@/lib/supabase/server";
import type { User } from "@supabase/supabase-js";

export type Role = "super_admin" | "admin" | "member";

export type Profile = {
  id: string;
  role: Role;
  email: string | null;
};

export async function getSession(): Promise<User | null> {
  const supabase = await createClient();
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user) {
    return null;
  }

  return user;
}

export async function getProfile(): Promise<Profile | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return null;
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, role, email, active")
    .eq("id", user.id)
    .single();

  if (!profile || profile.active === false) {
    return null;
  }

  return {
    id: profile.id,
    role: profile.role as Role,
    email: profile.email ?? user.email ?? null,
  };
}

export async function hasRole(roles: Role[]): Promise<boolean> {
  const profile = await getProfile();
  if (!profile) {
    return false;
  }

  return roles.includes(profile.role);
}
