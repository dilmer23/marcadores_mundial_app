-- ============================================================
-- DEVICE TOKENS TABLE (FCM push notifications)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_info TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Unique per user + token (same device re-registers, upserts)
ALTER TABLE public.device_tokens
  DROP CONSTRAINT IF EXISTS device_tokens_user_token_unique;

ALTER TABLE public.device_tokens
  ADD CONSTRAINT device_tokens_user_token_unique
  UNIQUE (user_id, fcm_token);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON public.device_tokens(user_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

-- Users can read their own tokens
DROP POLICY IF EXISTS "Users can read own device tokens" ON public.device_tokens;
CREATE POLICY "Users can read own device tokens"
  ON public.device_tokens FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own tokens
DROP POLICY IF EXISTS "Users can insert own device tokens" ON public.device_tokens;
CREATE POLICY "Users can insert own device tokens"
  ON public.device_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own tokens
DROP POLICY IF EXISTS "Users can update own device tokens" ON public.device_tokens;
CREATE POLICY "Users can update own device tokens"
  ON public.device_tokens FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tokens
DROP POLICY IF EXISTS "Users can delete own device tokens" ON public.device_tokens;
CREATE POLICY "Users can delete own device tokens"
  ON public.device_tokens FOR DELETE
  USING (auth.uid() = user_id);
