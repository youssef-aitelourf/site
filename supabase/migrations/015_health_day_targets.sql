ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS day_targets_enabled boolean NOT NULL DEFAULT false;

ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS rest_carb_multiplier numeric NOT NULL DEFAULT 0.85
  CHECK (rest_carb_multiplier >= 0.50 AND rest_carb_multiplier <= 1.00);

ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS training_carb_multiplier numeric NOT NULL DEFAULT 1.20
  CHECK (training_carb_multiplier >= 1.00 AND training_carb_multiplier <= 1.50);

ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS long_run_carb_multiplier numeric NOT NULL DEFAULT 1.35
  CHECK (long_run_carb_multiplier >= 1.00 AND long_run_carb_multiplier <= 1.80);

ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS long_run_distance_km numeric NOT NULL DEFAULT 15
  CHECK (long_run_distance_km >= 5 AND long_run_distance_km <= 50);

ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS long_run_duration_min integer NOT NULL DEFAULT 90
  CHECK (long_run_duration_min >= 30 AND long_run_duration_min <= 300);
