-- Migration 008: works jadvaliga status va content_text qo'shish

DO $$ BEGIN
  CREATE TYPE work_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE works
  ADD COLUMN IF NOT EXISTS status       work_status NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS content_text TEXT;

CREATE INDEX IF NOT EXISTS idx_works_status ON works(status);
