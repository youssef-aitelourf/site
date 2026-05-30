/**
 * Seed one super_admin user.
 *
 * Requires: npm install @supabase/supabase-js (not added to package.json by default).
 *
 * Usage:
 *   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
 *   SEED_EMAIL=... SEED_PASSWORD=... \
 *   node scripts/seed-super-admin.mjs
 *
 * The auth.users insert trigger creates a profile with role 'member';
 * this script then promotes that profile to super_admin.
 */

import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const email = process.env.SEED_EMAIL;
const password = process.env.SEED_PASSWORD;
const username = (process.env.SEED_USERNAME ?? "admin").toLowerCase();

const missing = [
  ["SUPABASE_URL", supabaseUrl],
  ["SUPABASE_SERVICE_ROLE_KEY", serviceRoleKey],
  ["SEED_EMAIL", email],
  ["SEED_PASSWORD", password],
]
  .filter(([, value]) => !value)
  .map(([name]) => name);

if (missing.length > 0) {
  console.error(`Missing required env vars: ${missing.join(", ")}`);
  process.exit(1);
}

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function findUserByEmail(targetEmail) {
  let page = 1;
  const perPage = 200;

  while (true) {
    const { data, error } = await supabase.auth.admin.listUsers({ page, perPage });
    if (error) throw error;

    const match = data.users.find((user) => user.email === targetEmail);
    if (match) return match;

    if (data.users.length < perPage) return null;
    page += 1;
  }
}

async function ensureSuperAdminUser() {
  let userId;

  const { data: created, error: createError } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });

  if (createError) {
    const alreadyExists =
      createError.message?.toLowerCase().includes("already") ||
      createError.status === 422;

    if (!alreadyExists) {
      throw createError;
    }

    const existing = await findUserByEmail(email);
    if (!existing) {
      throw new Error(`User ${email} may exist but could not be found via admin API`);
    }

    userId = existing.id;
    console.log(`User already exists: ${email} (${userId})`);
  } else {
    userId = created.user.id;
    console.log(`Created user: ${email} (${userId})`);
  }

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .update({ role: "super_admin", active: true, email, username })
    .eq("id", userId)
    .select("id, role, active")
    .maybeSingle();

  if (profileError) {
    throw profileError;
  }

  if (!profile) {
    const { data: inserted, error: insertError } = await supabase
      .from("profiles")
      .insert({ id: userId, role: "super_admin", active: true, email, username })
      .select("id, role, active")
      .single();

    if (insertError) {
      throw insertError;
    }

    console.log("Inserted super_admin profile:", inserted);
    return;
  }

  console.log("Updated profile to super_admin:", profile);
}

ensureSuperAdminUser().catch((err) => {
  console.error(err);
  process.exit(1);
});
