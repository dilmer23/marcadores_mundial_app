-- Banners table for promotional/advertising images in the app drawer
CREATE TABLE IF NOT EXISTS public.banners (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  image_url TEXT NOT NULL,
  link_url TEXT,
  title TEXT,
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Allow public read access (anon key can read)
CREATE POLICY "Allow public read" ON public.banners
  FOR SELECT USING (true);

-- Sample banner (replace with your own image URLs)
-- INSERT INTO public.banners (image_url, link_url, title, display_order)
-- VALUES
--   ('https://your-image-url.com/banner1.jpg', 'https://your-link.com', 'Sponsor 1', 1),
--   ('https://your-image-url.com/banner2.jpg', 'https://your-link.com', 'Sponsor 2', 2);
