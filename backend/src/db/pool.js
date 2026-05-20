const { Pool } = require('pg');
const config = require('../config');

const pool = new Pool({
  ...config.db,
  max: 10,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 5_000,
});

pool.on('error', (err) => {
  console.error('PostgreSQL pool xatosi:', err);
});

module.exports = pool;
