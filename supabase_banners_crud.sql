-- ============================================================
-- PROFILES TABLE (for future role-based access control)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin', 'editor', 'viewer')),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Everyone can read profiles
CREATE POLICY "Profiles are publicly readable" ON public.profiles
  FOR SELECT USING (true);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update own profile
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- BANNERS TABLE (add created_by for future role tracking)
-- ============================================================
ALTER TABLE public.banners ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);

-- Admin full access
CREATE POLICY "Admins can do everything on banners" ON public.banners
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role = 'admin')
  );

-- Editors can insert/update (but not delete)
CREATE POLICY "Editors can insert banners" ON public.banners
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
  );

CREATE POLICY "Editors can update banners" ON public.banners
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
  );

-- Public read (anon)
CREATE POLICY "Public read banners" ON public.banners
  FOR SELECT USING (true);

-- ============================================================
-- INSERT SAMPLE ADMIN (run after auth user exists)
-- ============================================================
-- INSERT INTO public.profiles (user_id, role)
-- VALUES ('<AUTH_USER_UUID>', 'admin');
