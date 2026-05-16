import { NextRequest, NextResponse } from "next/server";

const COOKIE = "admin_session";
const MAX_AGE = 60 * 60 * 24 * 7; // 7 days

export async function POST(request: NextRequest) {
  const { username, password } = await request.json() as { username: string; password: string };

  const validUsername = process.env.ADMIN_USERNAME ?? "streetpack";
  const validPassword = process.env.ADMIN_PASSWORD ?? "1234567890azerty";

  if (username !== validUsername || password !== validPassword) {
    return NextResponse.json({ error: "Identifiants invalides" }, { status: 401 });
  }

  const response = NextResponse.json({ ok: true });
  response.cookies.set(COOKIE, "1", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: MAX_AGE,
    path: "/",
  });

  return response;
}

export async function DELETE() {
  const response = NextResponse.json({ ok: true });
  response.cookies.delete(COOKIE);
  return response;
}
