require('dotenv').config();
const pool = require('./pool');

const COUNTRIES = [
  { name: 'O\'zbekiston',  code: 'UZ' },
  { name: 'Turkiya',       code: 'TR' },
  { name: 'Ozarbayjon',    code: 'AZ' },
  { name: "Qozog'iston",   code: 'KZ' },
  { name: "Qirg'iziston",  code: 'KG' },
];

const CATEGORIES = [
  'Adibalar',
  'Shoiralar',
  'Yozuvchilar',
  'Dramaturglar',
  'Mutafakkirlar',
];

// name → { born_year, died_year, country_code, category_name, bio }
const CREATORS = [
  {
    name: 'Mohlaroyim Nodira',
    born_year: 1792, died_year: 1842,
    country_code: 'UZ', category_name: 'Shoiralar',
    bio: "O'zbek adabiyotining buyuk shoirasi, Qo'qon xonligining malikasi. «Nodira» taxallusi bilan she'rlar yozgan.",
  },
  {
    name: "Zulfiya Isroilova",
    born_year: 1915, died_year: 1996,
    country_code: 'UZ', category_name: 'Shoiralar',
    bio: "O'zbek sovet adabiyotining taniqli shoirasi. Milliy she'riyatga katta hissa qo'shgan.",
  },
  {
    name: "Halima Xudoyberdiyeva",
    born_year: 1945, died_year: null,
    country_code: 'UZ', category_name: 'Shoiralar',
    bio: "Zamonaviy o'zbek she'riyatining yorqin vakili.",
  },
  {
    name: 'Mehribonu Hamidova',
    born_year: 1960, died_year: null,
    country_code: 'UZ', category_name: 'Adibalar',
    bio: "O'zbek nasrining taniqli vakili.",
  },
  {
    name: 'Foruğ Fərruxzad',
    born_year: 1935, died_year: 1967,
    country_code: 'AZ', category_name: 'Shoiralar',
    bio: "Zamonaviy forsiy she'riyatning eng ta'sirli shoiralaridan biri.",
  },
  {
    name: 'Nigar Rafibeyli',
    born_year: 1913, died_year: 1981,
    country_code: 'AZ', category_name: 'Shoiralar',
    bio: "Ozarbayjon sovet adabiyotining taniqli shoirasi.",
  },
  {
    name: 'Xalide Edib Adıvar',
    born_year: 1884, died_year: 1964,
    country_code: 'TR', category_name: 'Yozuvchilar',
    bio: "Turk adabiyotining birinchi zamonaviy ayol yozuvchisi va milliy qahramoni.",
  },
  {
    name: "Fatma Aliye Topuz",
    born_year: 1862, died_year: 1936,
    country_code: 'TR', category_name: 'Yozuvchilar',
    bio: "Turk adabiyotida birinchi ayol romanchisi.",
  },
  {
    name: "Maqpal Qunanbayeva",
    born_year: 1950, died_year: null,
    country_code: 'KZ', category_name: 'Adibalar',
    bio: "Qozog'iston adabiyotining taniqli vakilasi.",
  },
  {
    name: "Toktogul Qız Satılganova",
    born_year: 1864, died_year: 1933,
    country_code: 'KG', category_name: 'Shoiralar',
    bio: "Qirg'iz og'zaki she'riyatining mashhur ijodkorasi.",
  },
];

async function seed() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    for (const { name, code } of COUNTRIES) {
      await client.query(
        'INSERT INTO countries (name, code) VALUES ($1, $2) ON CONFLICT (code) DO NOTHING',
        [name, code],
      );
    }
    console.log(`Davlatlar: ${COUNTRIES.length} ta kiritildi (mavjudlari o'tkazildi)`);

    for (const name of CATEGORIES) {
      await client.query(
        'INSERT INTO categories (name) VALUES ($1) ON CONFLICT (name) DO NOTHING',
        [name],
      );
    }
    console.log(`Kategoriyalar: ${CATEGORIES.length} ta kiritildi (mavjudlari o'tkazildi)`);

    // Ijodkorlarni qo'shish
    let creatorCount = 0;
    for (const c of CREATORS) {
      const countryRes  = await client.query('SELECT id FROM countries  WHERE code = $1', [c.country_code]);
      const categoryRes = await client.query('SELECT id FROM categories WHERE name = $1', [c.category_name]);

      const countryId  = countryRes.rows[0]?.id  ?? null;
      const categoryId = categoryRes.rows[0]?.id ?? null;

      const existing = await client.query('SELECT id FROM creators WHERE name = $1', [c.name]);
      if (existing.rows.length > 0) continue;

      await client.query(
        `INSERT INTO creators (name, born_year, died_year, country_id, category_id, bio)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [c.name, c.born_year, c.died_year ?? null, countryId, categoryId, c.bio],
      );
      creatorCount++;
    }
    console.log(`Ijodkorlar: ${creatorCount} ta kiritildi (mavjudlari o'tkazildi)`);

    await client.query('COMMIT');
    console.log('Seed muvaffaqiyatli yakunlandi.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Seed xatosi:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
