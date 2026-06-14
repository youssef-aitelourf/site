ALTER TABLE public.health_refeed_days
  ADD CONSTRAINT health_refeed_days_adjustment_pct_range
  CHECK (calorie_adjustment_pct >= 0.10 AND calorie_adjustment_pct <= 0.50);
