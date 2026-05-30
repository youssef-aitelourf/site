-- Helper for app/middleware checks: true when the current user is an active super_admin.
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND role = 'super_admin'
      AND active = true
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;
