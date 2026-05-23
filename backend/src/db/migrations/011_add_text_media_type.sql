-- Migration 011: media_type enum ga 'text' qo'shish (matn asarlari uchun)
ALTER TYPE media_type ADD VALUE IF NOT EXISTS 'text';
