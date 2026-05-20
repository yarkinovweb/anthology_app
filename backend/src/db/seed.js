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
