-- Sync email on profiles for admin UI listing.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS email text;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, role, email)
  VALUES (NEW.id, 'member', NEW.email);
  RETURN NEW;
END;
$$;

-- Backfill email from auth.users for existing rows.
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS DISTINCT FROM u.email;

-- Super admins can update profiles (role, active) for user management.
CREATE POLICY profiles_update_super_admin
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role = 'super_admin'
        AND p.active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role = 'super_admin'
        AND p.active = true
    )
  );
