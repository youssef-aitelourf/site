-- Phase 7: V1 complete — micronutriments avancés, photos, gamification
-- Migration 012 — additive only

ALTER TABLE public.health_food_log_items
  ADD COLUMN IF NOT EXISTS micros jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE public.health_body_measurements
  ADD COLUMN IF NOT EXISTS body_fat_pct numeric CHECK (body_fat_pct IS NULL OR (body_fat_pct >= 3 AND body_fat_pct <= 70));

-- ---------------------------------------------------------------------------
-- health_progress_photos (WGT-07)
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_progress_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  logged_at timestamptz NOT NULL DEFAULT now(),
  storage_path text NOT NULL,
  caption text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX health_progress_photos_user_logged_at_idx
  ON public.health_progress_photos (user_id, logged_at DESC);

ALTER TABLE public.health_progress_photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_progress_photos_select_own ON public.health_progress_photos
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_progress_photos_insert_own ON public.health_progress_photos
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY health_progress_photos_delete_own ON public.health_progress_photos
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- health_user_achievements (COM-07)
-- ---------------------------------------------------------------------------
CREATE TABLE public.health_user_achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  badge_key text NOT NULL,
  earned_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, badge_key)
);

CREATE INDEX health_user_achievements_user_idx ON public.health_user_achievements (user_id);

ALTER TABLE public.health_user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_user_achievements_select_own ON public.health_user_achievements
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY health_user_achievements_insert_own ON public.health_user_achievements
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Storage bucket for progress photos
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'health-progress-photos',
  'health-progress-photos',
  false,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS health_photos_storage_select ON storage.objects;
DROP POLICY IF EXISTS health_photos_storage_insert ON storage.objects;
DROP POLICY IF EXISTS health_photos_storage_delete ON storage.objects;

CREATE POLICY health_photos_storage_select ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'health-progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY health_photos_storage_insert ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'health-progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY health_photos_storage_delete ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'health-progress-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
