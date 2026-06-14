CREATE TABLE public.health_refeed_days (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date       date        NOT NULL,
  type       text        NOT NULL DEFAULT 'refeed' CHECK (type IN ('refeed', 'diet_break')),
  calorie_adjustment_pct numeric NOT NULL DEFAULT 0.20,
  notes      text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT health_refeed_days_user_date UNIQUE (user_id, date)
);

ALTER TABLE public.health_refeed_days ENABLE ROW LEVEL SECURITY;

CREATE POLICY health_refeed_days_own
  ON public.health_refeed_days FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE INDEX health_refeed_days_user_month
  ON public.health_refeed_days (user_id, date DESC);
