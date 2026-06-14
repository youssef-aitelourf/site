-- Phase 6: user preferences (theme, privacy, notifications)
-- Migration 011 — additive only

ALTER TABLE public.health_user_settings
  ADD COLUMN IF NOT EXISTS theme text NOT NULL DEFAULT 'system'
    CHECK (theme IN ('light', 'dark', 'system')),
  ADD COLUMN IF NOT EXISTS hide_numbers boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS notify_weight boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS notify_meals boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS notify_workout boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS experience_level text
    CHECK (experience_level IS NULL OR experience_level IN ('beginner', 'intermediate', 'advanced'));
