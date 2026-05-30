-- Super-admin policies queried profiles again and caused RLS recursion.
-- Middleware only needs each user's own row; admin UI uses service_role.

DROP POLICY IF EXISTS profiles_select_super_admin ON public.profiles;
DROP POLICY IF EXISTS profiles_update_super_admin ON public.profiles;
