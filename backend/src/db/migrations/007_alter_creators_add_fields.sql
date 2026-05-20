-- Migration 007: creators jadvaliga category_id va died_year qo'shish

ALTER TABLE creators
  ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS died_year   SMALLINT;

CREATE INDEX IF NOT EXISTS idx_creators_category ON creators(category_id);
