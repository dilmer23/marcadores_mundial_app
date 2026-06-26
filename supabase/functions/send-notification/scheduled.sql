-- Table to schedule future notifications
CREATE TABLE IF NOT EXISTS public.scheduled_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  target_type TEXT NOT NULL CHECK (target_type IN ('all', 'age_range', 'user')),
  target_user_id UUID REFERENCES auth.users(id),
  target_min_age INTEGER,
  target_max_age INTEGER,
  send_at TIMESTAMPTZ NOT NULL,
  sent BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable pg_cron (run once in SQL Editor if not enabled)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Cron job: call send-notification every minute for due notifications
-- (uncomment and adjust function URL after deploying)
-- SELECT cron.schedule('process-notifications', '* * * * *',
--   $$
--   SELECT net.http_post(
--     url:='https://YOUR_PROJECT.supabase.co/functions/v1/send-notification',
--     headers:='{"Content-Type":"application/json","Authorization":"Bearer YOUR_ANON_KEY"}'::jsonb,
--     body:=jsonb_build_object(
--       'title', sn.title,
--       'body', sn.body,
--       'data', sn.data,
--       'target', jsonb_build_object(
--         'type', sn.target_type,
--         'userId', sn.target_user_id,
--         'minAge', sn.target_min_age,
--         'maxAge', sn.target_max_age
--       )
--     )
--   )
--   FROM public.scheduled_notifications sn
--   WHERE sn.send_at <= now() AND NOT sn.sent;
--   $$
-- );
