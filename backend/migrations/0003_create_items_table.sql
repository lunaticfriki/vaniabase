CREATE TABLE IF NOT EXISTS items (
  id UUID PRIMARY KEY,
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  creator TEXT[] NOT NULL,
  publisher TEXT NOT NULL,
  category TEXT NOT NULL,
  format TEXT NOT NULL,
  tags TEXT[] NOT NULL DEFAULT '{}',
  topic TEXT NOT NULL DEFAULT '',
  year INTEGER NOT NULL DEFAULT 0,
  description TEXT NOT NULL DEFAULT '',
  language TEXT NOT NULL DEFAULT '',
  image_url TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_items_owner_id ON items(owner_id);
CREATE INDEX IF NOT EXISTS idx_items_owner_created_at
  ON items(owner_id, created_at DESC);
