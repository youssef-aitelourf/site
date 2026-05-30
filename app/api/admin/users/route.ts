import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { Role } from "@/lib/auth";
import {
  internalEmailForUsername,
  isValidUsername,
  normalizeUsername,
} from "@/lib/login";

const ROLES: Role[] = ["super_admin", "admin", "member"];

export async function POST(request: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Non authentifié" }, { status: 401 });
  }

  const { data: caller } = await supabase
    .from("profiles")
    .select("role, active")
    .eq("id", user.id)
    .single();

  if (!caller?.active || caller.role !== "super_admin") {
    return NextResponse.json({ error: "Interdit" }, { status: 403 });
  }

  const body = (await request.json()) as {
    username: string;
    email?: string;
    password: string;
    role: Role;
  };

  const username = normalizeUsername(body.username ?? "");
  const emailInput = body.email?.trim().toLowerCase();
  const password = body.password;
  const role = body.role;

  if (!isValidUsername(username) || !password || !ROLES.includes(role)) {
    return NextResponse.json({ error: "Données invalides" }, { status: 400 });
  }

  if (password.length < 8) {
    return NextResponse.json(
      { error: "Mot de passe : 8 caractères minimum" },
      { status: 400 },
    );
  }

  const email = emailInput || internalEmailForUsername(username);

  const admin = createAdminClient();

  const { data: existing } = await admin
    .from("profiles")
    .select("id")
    .eq("username", username)
    .maybeSingle();

  if (existing) {
    return NextResponse.json({ error: "Ce username est déjà pris" }, { status: 400 });
  }

  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });

  if (createError) {
    return NextResponse.json(
      { error: createError.message },
      { status: 400 },
    );
  }

  const userId = created.user.id;

  const { error: profileError } = await admin
    .from("profiles")
    .update({
      role,
      email,
      username,
      created_by: user.id,
      active: true,
    })
    .eq("id", userId);

  if (profileError) {
    return NextResponse.json({ error: profileError.message }, { status: 500 });
  }

  return NextResponse.json({ ok: true, id: userId });
}
