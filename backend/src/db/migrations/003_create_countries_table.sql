-- Migration 003: countries jadvali

CREATE TABLE IF NOT EXISTS countries (
  id   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE,
  code CHAR(2)      NOT NULL UNIQUE   -- ISO 3166-1 alpha-2 (UZ, US, RU ...)
);
