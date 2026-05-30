-- Phase 0: health-app core tables (user settings + goals)
-- Project: Site-Youssef (pcickkvgqjweqxqliwno)
-- Migration 007 — additive only

-- Shared updated_at trigger function (idempotent)
CREATE OR REPLACE FUNCTION public.health_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- health_user_settings (1:1 with auth.users)
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_user_settings (
  user_id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  locale text NOT NULL DEFAULT 'fr' CHECK (locale IN ('fr', 'en')),
  unit_system text NOT NULL DEFAULT 'metric' CHECK (unit_system IN ('metric', 'imperial')),
  timezone text NOT NULL DEFAULT 'Europe/Paris',
  sex text CHECK (sex IN ('male', 'female', 'other')),
  birth_date date,
  height_cm numeric CHECK (height_cm IS NULL OR height_cm > 0),
  activity_level text CHECK (
    activity_level IS NULL
    OR activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')
  ),
  onboarding_completed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.health_user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_user_settings_select_own
  ON public.health_user_settings FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY health_user_settings_insert_own
  ON public.health_user_settings FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY health_user_settings_update_own
  ON public.health_user_settings FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY health_user_settings_delete_own
  ON public.health_user_settings FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

CREATE TRIGGER health_user_settings_updated_at
  BEFORE UPDATE ON public.health_user_settings
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_goals (nutrition goals — historized)
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  phase text NOT NULL CHECK (phase IN ('cut', 'maintain', 'bulk', 'recomp')),
  target_rate_pct_per_week numeric NOT NULL DEFAULT 0.007,
  protein_g_per_kg numeric NOT NULL DEFAULT 2.0,
  calorie_target integer NOT NULL CHECK (calorie_target > 0),
  protein_g integer NOT NULL CHECK (protein_g >= 0),
  carbs_g integer NOT NULL CHECK (carbs_g >= 0),
  fat_g integer NOT NULL CHECK (fat_g >= 0),
  valid_from date NOT NULL DEFAULT CURRENT_DATE,
  valid_until date,
  is_active boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX health_goals_one_active_per_user
  ON public.health_goals (user_id)
  WHERE is_active;

CREATE INDEX health_goals_user_id_valid_from_idx
  ON public.health_goals (user_id, valid_from DESC);

ALTER TABLE public.health_goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_goals_select_own
  ON public.health_goals FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY health_goals_insert_own
  ON public.health_goals FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY health_goals_update_own
  ON public.health_goals FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY health_goals_delete_own
  ON public.health_goals FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

CREATE TRIGGER health_goals_updated_at
  BEFORE UPDATE ON public.health_goals
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();
