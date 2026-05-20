-- Migration 004: creators jadvali

CREATE TABLE IF NOT EXISTS creators (
  id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name       VARCHAR(255) NOT NULL,
  country_id UUID         REFERENCES countries(id) ON DELETE SET NULL,
  bio        TEXT,
  born_year  SMALLINT,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TRIGGER creators_set_updated_at
  BEFORE UPDATE ON creators
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_creators_country ON creators(country_id);
