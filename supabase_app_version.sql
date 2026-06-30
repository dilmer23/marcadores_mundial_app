-- App version check table (single row, id always 1)
CREATE TABLE IF NOT EXISTS app_version (
  id BIGINT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  version TEXT NOT NULL,
  mandatory BOOLEAN DEFAULT false,
  download_url TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO app_version (id, version, mandatory, download_url)
VALUES (1, '1.0.0', false, 'https://github.com/dilmer23/worldcup26-app/releases')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE app_version ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read app_version" ON app_version
  FOR SELECT USING (true);
