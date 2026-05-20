-- Migration 010: Keraksiz mamlakatlar va kategoriyalarni o'chirish
-- country_id va category_id ON DELETE SET NULL, shuning uchun creator bog'liqligi muammo bo'lmaydi

DELETE FROM countries
WHERE code NOT IN ('UZ', 'TR', 'AZ', 'KZ', 'KG');

DELETE FROM categories
WHERE name NOT IN ('Adibalar', 'Shoiralar', 'Yozuvchilar', 'Dramaturglar', 'Mutafakkirlar');

INSERT INTO categories (name) VALUES
  ('Adibalar'),
  ('Shoiralar'),
  ('Yozuvchilar'),
  ('Dramaturglar'),
  ('Mutafakkirlar')
ON CONFLICT (name) DO NOTHING;
