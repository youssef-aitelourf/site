import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { resolveLoginEmail } from "@/lib/login";

export async function POST(request: NextRequest) {
  const body = (await request.json()) as {
    identifier?: string;
    email?: string;
    password: string;
  };

  const identifier = body.identifier ?? body.email ?? "";
  const password = body.password;

  const loginEmail = await resolveLoginEmail(identifier);

  if (!loginEmail || !password) {
    return NextResponse.json({ error: "Identifiants invalides" }, { status: 401 });
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({
    email: loginEmail,
    password,
  });

  if (error) {
    return NextResponse.json({ error: "Identifiants invalides" }, { status: 401 });
  }

  return NextResponse.json({ ok: true });
}

export async function DELETE() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  return NextResponse.json({ ok: true });
}
