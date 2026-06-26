-- ============================================================
-- PROFILES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  nombre TEXT,
  apellido TEXT,
  telefono TEXT,
  edad INTEGER,
  role TEXT NOT NULL DEFAULT 'user',
  acepta_politicas BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can insert their own profile (after email confirmation)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Admins can read all profiles
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;
CREATE POLICY "Admins can read all profiles"
  ON public.profiles FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- ROLE CHECK CONSTRAINT
-- ============================================================
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('user', 'admin', 'moderator', 'editor', 'premium', 'super_admin'));

ALTER TABLE public.profiles
  ALTER COLUMN role SET DEFAULT 'user';

-- ============================================================
-- BANNERS RLS
-- ============================================================
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Everyone can read active banners
DROP POLICY IF EXISTS "Anyone can read active banners" ON public.banners;
CREATE POLICY "Anyone can read active banners"
  ON public.banners FOR SELECT
  USING (is_active = true);

-- Admins can do everything on banners
DROP POLICY IF EXISTS "Admins can manage banners" ON public.banners;
CREATE POLICY "Admins can manage banners"
  ON public.banners FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- CHANNELS RLS
-- ============================================================
ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;

-- Everyone can read active channels
DROP POLICY IF EXISTS "Anyone can read active channels" ON public.channels;
CREATE POLICY "Anyone can read active channels"
  ON public.channels FOR SELECT
  USING (is_active = true);

-- Admins can do everything on channels
DROP POLICY IF EXISTS "Admins can manage channels" ON public.channels;
CREATE POLICY "Admins can manage channels"
  ON public.channels FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ============================================================
-- STORAGE: BANNERS BUCKET
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('banners', 'banners', true, 5242880, ARRAY['image/png', 'image/jpeg', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public read banners" ON storage.objects;
CREATE POLICY "Public read banners"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'banners');

DROP POLICY IF EXISTS "Admins can upload banners" ON storage.objects;
CREATE POLICY "Admins can upload banners"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'banners'
    AND auth.role() = 'authenticated'
  );

DROP POLICY IF EXISTS "Admins can update banners" ON storage.objects;
CREATE POLICY "Admins can update banners"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'banners' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admins can delete banners" ON storage.objects;
CREATE POLICY "Admins can delete banners"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'banners' AND auth.role() = 'authenticated');
