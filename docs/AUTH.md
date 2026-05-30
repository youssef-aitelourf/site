# Auth Supabase — setup

## Ce que tu dois faire (une fois)

### 1. Créer un projet Supabase

1. Va sur [supabase.com](https://supabase.com) → **New project**
2. Note l’**URL** du projet et les clés **anon** + **service_role** (Settings → API)

### 2. Exécuter les migrations SQL

Dans Supabase → **SQL Editor**, exécute dans l’ordre :

1. `supabase/migrations/001_profiles.sql`
2. `supabase/migrations/002_is_super_admin.sql`
3. `supabase/migrations/003_profiles_email_and_admin_policies.sql`

### 3. Variables d’environnement

**Local** — copie `.env.local.example` vers `.env.local` :

```bash
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SEED_EMAIL=ton@email.com
SEED_PASSWORD=mot-de-passe-fort
```

**Vercel** — projet `site` → Settings → Environment Variables (Production + Preview) :

| Variable | Notes |
|----------|--------|
| `SUPABASE_URL` | |
| `SUPABASE_ANON_KEY` | |
| `SUPABASE_SERVICE_ROLE_KEY` | Serveur uniquement |

Tu peux **supprimer** `ADMIN_USERNAME` et `ADMIN_PASSWORD` (obsolètes).

### 4. Créer ton compte super_admin

```bash
cd site
npm install
node scripts/seed-super-admin.mjs
```

### 5. Déployer

Push sur `main` → Vercel rebuild.

### 6. Tester

1. [youssef-aitelourf.com/admin/login](https://youssef-aitelourf.com/admin/login) — email + mot de passe seed
2. `/admin` — hub
3. `/admin/users` — liste + création de comptes (super_admin seulement)

## Rôles

| Rôle | Droits |
|------|--------|
| `super_admin` | `/admin/users`, création de comptes |
| `admin` | Zone `/admin` |
| `member` | Zone `/admin` (outils futurs) |

## Scripts

```bash
npm run seed:admin   # alias seed super_admin
```
