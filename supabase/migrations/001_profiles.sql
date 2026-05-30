-- Profiles for multi-user admin auth with roles.
-- Each auth.users row gets a matching profile via trigger (default role: member).

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('super_admin', 'admin', 'member')),
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES auth.users (id) ON DELETE SET NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.profiles FROM PUBLIC;
GRANT SELECT ON public.profiles TO authenticated;

-- Auto-create profile when a user signs up (seed/admin flows update role afterward).
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (NEW.id, 'member');
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Users can read their own profile.
CREATE POLICY profiles_select_own
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Super admins can read all profiles (inline exists check on profiles.role).
CREATE POLICY profiles_select_super_admin
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role = 'super_admin'
        AND p.active = true
    )
  );
