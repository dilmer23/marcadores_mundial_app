-- Create banners storage bucket (public for direct image serving)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('banners', 'banners', true, 5242880, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO NOTHING;

-- Public read access to banner images
CREATE POLICY "Public read banner images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'banners');

-- Anyone can upload banner images (bucket is public)
CREATE POLICY "Anyone can upload banner images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'banners');

-- Anyone can update banner images
CREATE POLICY "Anyone can update banner images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'banners');

-- Anyone can delete banner images
CREATE POLICY "Anyone can delete banner images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'banners');
