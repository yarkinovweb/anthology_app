const pool = require('../db/pool');

// GET /api/categories
const listCategories = async (_req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, name FROM categories ORDER BY name ASC',
    );
    return res.json({ categories: rows });
  } catch (err) {
    console.error('listCategories:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

module.exports = { listCategories };
