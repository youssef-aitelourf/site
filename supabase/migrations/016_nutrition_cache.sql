-- Nutrition app: dedicated Postgres schema (Prisma) + shared food cache in public

CREATE SCHEMA IF NOT EXISTS nutrition;

-- External food API cache (USDA + OFF)
CREATE TABLE IF NOT EXISTS public.nutrition_external_food_cache (
  source      text NOT NULL,
  external_id text NOT NULL,
  data        jsonb NOT NULL,
  cached_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (source, external_id)
);

CREATE INDEX IF NOT EXISTS nutrition_external_food_cache_cached_at_idx
  ON public.nutrition_external_food_cache (cached_at DESC);

ALTER TABLE public.nutrition_external_food_cache ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS nutrition_external_food_cache_select_authenticated
  ON public.nutrition_external_food_cache;

CREATE POLICY nutrition_external_food_cache_select_authenticated
  ON public.nutrition_external_food_cache FOR SELECT TO authenticated
  USING (true);
