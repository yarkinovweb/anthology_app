-- Migration 009: works jadvaliga uploaded_by (kim yuklagan) ustuni qo'shish

ALTER TABLE works
  ADD COLUMN IF NOT EXISTS uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_works_uploaded_by ON works(uploaded_by);
