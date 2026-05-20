// Ishga tushirish: node src/db/migrate.js
const fs   = require('fs');
const path = require('path');
const pool = require('./pool');

async function migrate() {
  const client = await pool.connect();
  try {
    // Qaysi migratsiyalar bajarilganini saqlash uchun jadval
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        filename   VARCHAR(255) PRIMARY KEY,
        applied_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
      )
    `);

    const applied = await client.query('SELECT filename FROM schema_migrations');
    const appliedSet = new Set(applied.rows.map((r) => r.filename));

    const dir   = path.join(__dirname, 'migrations');
    const files = fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();

    let count = 0;
    for (const file of files) {
      if (appliedSet.has(file)) {
        console.log(`O'tkazildi (allaqachon bajarilgan): ${file}`);
        continue;
      }

      const sql = fs.readFileSync(path.join(dir, file), 'utf8');
      console.log(`Migratsiya: ${file}`);

      await client.query('BEGIN');
      await client.query(sql);
      await client.query(
        'INSERT INTO schema_migrations (filename) VALUES ($1)',
        [file],
      );
      await client.query('COMMIT');

      console.log(`  Bajarildi: ${file}`);
      count++;
    }

    if (count === 0) {
      console.log('Yangi migratsiya yo\'q.');
    } else {
      console.log(`Jami ${count} ta yangi migratsiya bajarildi.`);
    }
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    console.error('Migratsiya xatosi:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

migrate();
