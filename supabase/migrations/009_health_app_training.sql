-- Phase 2: training tables
-- Migration 009 — additive only

-- ---------------------------------------------------------------------------
-- health_exercises (wger cache + custom)
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_exercises (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users (id) ON DELETE CASCADE,
  wger_id integer,
  name text NOT NULL,
  name_fr text,
  muscle_groups text[] NOT NULL DEFAULT '{}',
  equipment text[] NOT NULL DEFAULT '{}',
  instructions text,
  image_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX health_exercises_wger_id_unique
  ON public.health_exercises (wger_id)
  WHERE user_id IS NULL AND wger_id IS NOT NULL;

CREATE INDEX health_exercises_user_id_idx ON public.health_exercises (user_id);
CREATE INDEX health_exercises_name_idx ON public.health_exercises (lower(name));

ALTER TABLE public.health_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_exercises_select_global_or_own
  ON public.health_exercises FOR SELECT TO authenticated
  USING (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY health_exercises_insert_own
  ON public.health_exercises FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY health_exercises_update_own
  ON public.health_exercises FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY health_exercises_delete_own
  ON public.health_exercises FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

CREATE TRIGGER health_exercises_updated_at
  BEFORE UPDATE ON public.health_exercises
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_workout_sessions
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_workout_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  session_type text NOT NULL CHECK (session_type IN ('strength', 'cardio', 'mixed')),
  name text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_workout_sessions_user_started_idx
  ON public.health_workout_sessions (user_id, started_at DESC);

ALTER TABLE public.health_workout_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_workout_sessions_select_own ON public.health_workout_sessions
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_workout_sessions_insert_own ON public.health_workout_sessions
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_workout_sessions_update_own ON public.health_workout_sessions
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_workout_sessions_delete_own ON public.health_workout_sessions
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_workout_sessions_updated_at
  BEFORE UPDATE ON public.health_workout_sessions
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_workout_sets
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_workout_sets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.health_workout_sessions (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  exercise_id uuid NOT NULL REFERENCES public.health_exercises (id),
  set_order integer NOT NULL DEFAULT 1,
  weight_kg numeric NOT NULL DEFAULT 0 CHECK (weight_kg >= 0),
  reps integer NOT NULL DEFAULT 0 CHECK (reps >= 0),
  rpe numeric CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10)),
  rir integer CHECK (rir IS NULL OR (rir >= 0 AND rir <= 10)),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_workout_sets_session_idx ON public.health_workout_sets (session_id, set_order);
CREATE INDEX health_workout_sets_exercise_idx ON public.health_workout_sets (user_id, exercise_id, created_at DESC);

ALTER TABLE public.health_workout_sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_workout_sets_select_own ON public.health_workout_sets
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_workout_sets_insert_own ON public.health_workout_sets
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_workout_sets_update_own ON public.health_workout_sets
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_workout_sets_delete_own ON public.health_workout_sets
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- health_workout_templates
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_workout_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  exercises jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.health_workout_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_workout_templates_select_own ON public.health_workout_templates
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_workout_templates_insert_own ON public.health_workout_templates
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_workout_templates_update_own ON public.health_workout_templates
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_workout_templates_delete_own ON public.health_workout_templates
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_workout_templates_updated_at
  BEFORE UPDATE ON public.health_workout_templates
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_cardio_sessions
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_cardio_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid REFERENCES public.health_workout_sessions (id) ON DELETE SET NULL,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  activity_type text NOT NULL DEFAULT 'run',
  duration_seconds integer NOT NULL CHECK (duration_seconds > 0),
  distance_m numeric CHECK (distance_m IS NULL OR distance_m > 0),
  pace_sec_per_km numeric,
  avg_hr integer,
  rpe numeric CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10)),
  notes text,
  logged_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_cardio_sessions_user_logged_idx
  ON public.health_cardio_sessions (user_id, logged_at DESC);

ALTER TABLE public.health_cardio_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_cardio_sessions_select_own ON public.health_cardio_sessions
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_cardio_sessions_insert_own ON public.health_cardio_sessions
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_cardio_sessions_update_own ON public.health_cardio_sessions
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_cardio_sessions_delete_own ON public.health_cardio_sessions
  FOR DELETE TO authenticated USING (auth.uid() = user_id);
