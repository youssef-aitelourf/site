-- Fix infinite recursion: policies must not SELECT from profiles directly.
-- Use SECURITY DEFINER is_super_admin() instead.

DROP POLICY IF EXISTS profiles_select_super_admin ON public.profiles;
DROP POLICY IF EXISTS profiles_update_super_admin ON public.profiles;

CREATE POLICY profiles_select_super_admin
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (public.is_super_admin());

CREATE POLICY profiles_update_super_admin
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());
