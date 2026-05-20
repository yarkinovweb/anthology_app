-- Migration 005: works jadvali

CREATE TYPE media_type AS ENUM ('image', 'audio', 'video', 'pdf');

CREATE TABLE IF NOT EXISTS works (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id  UUID        NOT NULL REFERENCES creators(id) ON DELETE CASCADE,
  title       VARCHAR(255) NOT NULL,
  description TEXT,
  media_url   TEXT        NOT NULL,   -- S3 public URL
  file_key    TEXT        NOT NULL,   -- S3 object key (o'chirish uchun)
  media_type  media_type  NOT NULL,
  file_size   BIGINT      NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER works_set_updated_at
  BEFORE UPDATE ON works
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_works_creator ON works(creator_id);
CREATE INDEX idx_works_media_type ON works(media_type);
