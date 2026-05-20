const pool = require('../db/pool');

// GET /api/countries
const listCountries = async (_req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, name, code FROM countries ORDER BY name ASC',
    );
    return res.json({ countries: rows });
  } catch (err) {
    console.error('listCountries:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

module.exports = { listCountries };
