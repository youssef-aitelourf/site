-- Phase 1: nutrition tables
-- Migration 008 — additive only

ALTER TABLE public.health_goals
  ADD COLUMN IF NOT EXISTS water_target_ml integer NOT NULL DEFAULT 2000;

-- ---------------------------------------------------------------------------
-- health_food_logs
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_food_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  logged_at timestamptz NOT NULL DEFAULT now(),
  meal_type text NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  name text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_food_logs_user_logged_at_idx
  ON public.health_food_logs (user_id, logged_at DESC);

ALTER TABLE public.health_food_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_food_logs_select_own ON public.health_food_logs
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_food_logs_insert_own ON public.health_food_logs
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_food_logs_update_own ON public.health_food_logs
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_food_logs_delete_own ON public.health_food_logs
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_food_logs_updated_at
  BEFORE UPDATE ON public.health_food_logs
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_food_log_items
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_food_log_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  food_log_id uuid NOT NULL REFERENCES public.health_food_logs (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  source text NOT NULL CHECK (source IN ('usda', 'off', 'custom', 'recipe')),
  external_id text,
  name text NOT NULL,
  quantity numeric NOT NULL CHECK (quantity > 0),
  unit text NOT NULL DEFAULT 'g',
  calories numeric NOT NULL DEFAULT 0,
  protein_g numeric NOT NULL DEFAULT 0,
  carbs_g numeric NOT NULL DEFAULT 0,
  fat_g numeric NOT NULL DEFAULT 0,
  fiber_g numeric,
  sugar_g numeric,
  sat_fat_g numeric,
  sodium_mg numeric,
  reliability text NOT NULL CHECK (reliability IN ('verified', 'community', 'custom')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_food_log_items_food_log_id_idx
  ON public.health_food_log_items (food_log_id);

CREATE INDEX health_food_log_items_user_id_idx
  ON public.health_food_log_items (user_id, created_at DESC);

ALTER TABLE public.health_food_log_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_food_log_items_select_own ON public.health_food_log_items
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_food_log_items_insert_own ON public.health_food_log_items
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_food_log_items_update_own ON public.health_food_log_items
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_food_log_items_delete_own ON public.health_food_log_items
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- health_custom_foods
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_custom_foods (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  brand text,
  serving_size_g numeric NOT NULL DEFAULT 100 CHECK (serving_size_g > 0),
  calories numeric NOT NULL DEFAULT 0,
  protein_g numeric NOT NULL DEFAULT 0,
  carbs_g numeric NOT NULL DEFAULT 0,
  fat_g numeric NOT NULL DEFAULT 0,
  fiber_g numeric,
  sugar_g numeric,
  sat_fat_g numeric,
  sodium_mg numeric,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.health_custom_foods ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_custom_foods_select_own ON public.health_custom_foods
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_custom_foods_insert_own ON public.health_custom_foods
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_custom_foods_update_own ON public.health_custom_foods
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_custom_foods_delete_own ON public.health_custom_foods
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_custom_foods_updated_at
  BEFORE UPDATE ON public.health_custom_foods
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_recipes
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_recipes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  servings integer NOT NULL DEFAULT 1 CHECK (servings > 0),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.health_recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_recipes_select_own ON public.health_recipes
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_recipes_insert_own ON public.health_recipes
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_recipes_update_own ON public.health_recipes
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_recipes_delete_own ON public.health_recipes
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_recipes_updated_at
  BEFORE UPDATE ON public.health_recipes
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_recipe_ingredients
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_recipe_ingredients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id uuid NOT NULL REFERENCES public.health_recipes (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  source text NOT NULL CHECK (source IN ('usda', 'off', 'custom', 'recipe')),
  external_id text,
  name text NOT NULL,
  quantity numeric NOT NULL CHECK (quantity > 0),
  unit text NOT NULL DEFAULT 'g',
  calories numeric NOT NULL DEFAULT 0,
  protein_g numeric NOT NULL DEFAULT 0,
  carbs_g numeric NOT NULL DEFAULT 0,
  fat_g numeric NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.health_recipe_ingredients ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_recipe_ingredients_select_own ON public.health_recipe_ingredients
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_recipe_ingredients_insert_own ON public.health_recipe_ingredients
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_recipe_ingredients_update_own ON public.health_recipe_ingredients
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_recipe_ingredients_delete_own ON public.health_recipe_ingredients
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- health_meal_templates
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_meal_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  items jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.health_meal_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_meal_templates_select_own ON public.health_meal_templates
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_meal_templates_insert_own ON public.health_meal_templates
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_meal_templates_update_own ON public.health_meal_templates
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_meal_templates_delete_own ON public.health_meal_templates
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE TRIGGER health_meal_templates_updated_at
  BEFORE UPDATE ON public.health_meal_templates
  FOR EACH ROW EXECUTE FUNCTION public.health_set_updated_at();

-- ---------------------------------------------------------------------------
-- health_favorites
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  source text NOT NULL CHECK (source IN ('usda', 'off', 'custom', 'recipe')),
  external_id text NOT NULL,
  item_name text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, source, external_id)
);

ALTER TABLE public.health_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_favorites_select_own ON public.health_favorites
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_favorites_insert_own ON public.health_favorites
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_favorites_update_own ON public.health_favorites
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_favorites_delete_own ON public.health_favorites
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- health_water_logs
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_water_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  logged_at timestamptz NOT NULL DEFAULT now(),
  amount_ml integer NOT NULL CHECK (amount_ml > 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_water_logs_user_logged_at_idx
  ON public.health_water_logs (user_id, logged_at DESC);

ALTER TABLE public.health_water_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_water_logs_select_own ON public.health_water_logs
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_water_logs_insert_own ON public.health_water_logs
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_water_logs_update_own ON public.health_water_logs
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_water_logs_delete_own ON public.health_water_logs
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- health_external_food_cache (global shared cache)
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_external_food_cache (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source text NOT NULL CHECK (source IN ('usda', 'off')),
  external_id text NOT NULL,
  data jsonb NOT NULL,
  cached_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source, external_id)
);

CREATE INDEX health_external_food_cache_cached_at_idx
  ON public.health_external_food_cache (cached_at DESC);

ALTER TABLE public.health_external_food_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_external_food_cache_select_authenticated
  ON public.health_external_food_cache FOR SELECT TO authenticated
  USING (true);

-- INSERT/UPDATE: service_role only (no policy for authenticated)

-- ---------------------------------------------------------------------------
-- health_tdee_snapshots
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_tdee_snapshots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  computed_at timestamptz NOT NULL DEFAULT now(),
  tdee_kcal integer NOT NULL,
  avg_intake_kcal integer NOT NULL,
  weight_trend_kg_per_week numeric,
  adjustment_kcal integer NOT NULL DEFAULT 0,
  inputs jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_tdee_snapshots_user_computed_at_idx
  ON public.health_tdee_snapshots (user_id, computed_at DESC);

ALTER TABLE public.health_tdee_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_tdee_snapshots_select_own ON public.health_tdee_snapshots
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_tdee_snapshots_insert_own ON public.health_tdee_snapshots
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_tdee_snapshots_update_own ON public.health_tdee_snapshots
  FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_tdee_snapshots_delete_own ON public.health_tdee_snapshots
  FOR DELETE TO authenticated USING (auth.uid() = user_id);
