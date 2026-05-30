-- Login par username ou email (username unique, insensible à la casse).

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS username text;

CREATE UNIQUE INDEX IF NOT EXISTS profiles_username_lower_key
  ON public.profiles (lower(username))
  WHERE username IS NOT NULL;

-- Compte admin initial
UPDATE public.profiles
SET username = 'admin'
WHERE email = 'admin@youssef-aitelourf.com' AND username IS NULL;
