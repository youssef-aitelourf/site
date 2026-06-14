-- Phase 3: weight & body composition
-- Migration 010 — additive only

-- ---------------------------------------------------------------------------
-- health_weight_entries
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_weight_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  logged_at timestamptz NOT NULL DEFAULT now(),
  weight_kg numeric NOT NULL CHECK (weight_kg > 0 AND weight_kg < 500),
  notes text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_weight_entries_user_logged_at_idx
  ON public.health_weight_entries (user_id, logged_at DESC);

CREATE UNIQUE INDEX health_weight_entries_user_logged_at_unique_idx
  ON public.health_weight_entries (user_id, logged_at);

ALTER TABLE public.health_weight_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_weight_entries_select_own ON public.health_weight_entries
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_weight_entries_insert_own ON public.health_weight_entries
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_weight_entries_update_own ON public.health_weight_entries
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_weight_entries_delete_own ON public.health_weight_entries
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_weight_entries_updated_at
  BEFORE UPDATE ON public.health_weight_entries
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_body_measurements
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_body_measurements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  logged_at timestamptz NOT NULL DEFAULT now(),
  waist_cm numeric CHECK (waist_cm IS NULL OR (waist_cm > 0 AND waist_cm < 300)),
  hips_cm numeric CHECK (hips_cm IS NULL OR (hips_cm > 0 AND hips_cm < 300)),
  chest_cm numeric CHECK (chest_cm IS NULL OR (chest_cm > 0 AND chest_cm < 300)),
  arm_cm numeric CHECK (arm_cm IS NULL OR (arm_cm > 0 AND arm_cm < 300)),
  thigh_cm numeric CHECK (thigh_cm IS NULL OR (thigh_cm > 0 AND thigh_cm < 300)),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_body_measurements_user_logged_at_idx
  ON public.health_body_measurements (user_id, logged_at DESC);

ALTER TABLE public.health_body_measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_body_measurements_select_own ON public.health_body_measurements
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_body_measurements_insert_own ON public.health_body_measurements
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_body_measurements_update_own ON public.health_body_measurements
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_body_measurements_delete_own ON public.health_body_measurements
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_body_measurements_updated_at
  BEFORE UPDATE ON public.health_body_measurements
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_weight_goals
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_weight_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  target_weight_kg numeric NOT NULL CHECK (target_weight_kg > 0 AND target_weight_kg < 500),
  target_date date,
  milestones jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX health_weight_goals_user_unique_idx
  ON public.health_weight_goals (user_id);

ALTER TABLE public.health_weight_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_weight_goals_select_own ON public.health_weight_goals
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_weight_goals_insert_own ON public.health_weight_goals
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_weight_goals_update_own ON public.health_weight_goals
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_weight_goals_delete_own ON public.health_weight_goals
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_weight_goals_updated_at
  BEFORE UPDATE ON public.health_weight_goals
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();
