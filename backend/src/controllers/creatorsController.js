const pool = require('../db/pool');
const { isValidYear } = require('../middleware/validate');
const { translateFields, parseLang } = require('../services/translationService');

// GET /api/creators
// Query: search, country_id, category_id, period (e.g. "1800-1900")
const listCreators = async (req, res) => {
  try {
    const { search, country_id, category_id, period } = req.query;

    const params = [];
    const where  = [];

    if (search) {
      params.push(`%${search}%`);
      where.push(`c.name ILIKE $${params.length}`);
    }

    if (country_id) {
      params.push(country_id);
      where.push(`c.country_id = $${params.length}`);
    }

    if (category_id) {
      params.push(category_id);
      where.push(`c.category_id = $${params.length}`);
    }

    if (period) {
      const parts = period.split('-').map(Number);
      if (parts.length === 2 && isValidYear(parts[0]) && isValidYear(parts[1])) {
        params.push(parts[0], parts[1]);
        where.push(`c.born_year BETWEEN $${params.length - 1} AND $${params.length}`);
      } else {
        return res.status(400).json({ message: 'period formati: "1800-1900" bo\'lishi kerak' });
      }
    }

    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const { rows } = await pool.query(
      `SELECT c.id, c.name, c.bio, c.born_year, c.died_year, c.created_at,
              co.id   AS country_id,  co.name  AS country_name,  co.code AS country_code,
              cat.id  AS category_id, cat.name AS category_name
       FROM creators c
       LEFT JOIN countries   co  ON co.id  = c.country_id
       LEFT JOIN categories  cat ON cat.id = c.category_id
       ${whereClause}
       ORDER BY c.name ASC`,
      params,
    );

    return res.json({ creators: rows });
  } catch (err) {
    console.error('listCreators:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// GET /api/creators/:id
const getCreator = async (req, res) => {
  try {
    const { id } = req.params;

    const { rows } = await pool.query(
      `SELECT c.id, c.name, c.bio, c.born_year, c.died_year, c.created_at, c.updated_at,
              co.id   AS country_id,  co.name  AS country_name,  co.code AS country_code,
              cat.id  AS category_id, cat.name AS category_name
       FROM creators c
       LEFT JOIN countries   co  ON co.id  = c.country_id
       LEFT JOIN categories  cat ON cat.id = c.category_id
       WHERE c.id = $1`,
      [id],
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Ijodkor topilmadi' });
    }

    const { rows: works } = await pool.query(
      `SELECT id, title, description, media_url, media_type, file_size, content_text, created_at
       FROM works
       WHERE creator_id = $1 AND status = 'approved'
       ORDER BY created_at DESC`,
      [id],
    );

    // Bio'ni foydalanuvchi tiliga tarjima qilish
    const targetLang = parseLang(req.headers['accept-language']);
    const creator    = await translateFields(rows[0], ['bio'], targetLang);

    return res.json({ creator: { ...creator, works } });
  } catch (err) {
    console.error('getCreator:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// POST /api/creators  (admin / specialist)
const createCreator = async (req, res) => {
  try {
    const { name, country_id, category_id, bio, born_year, died_year } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({ message: 'name majburiy' });
    }
    if (born_year !== undefined && !isValidYear(born_year)) {
      return res.status(400).json({ message: 'born_year 1000–2100 oralig\'ida bo\'lishi kerak' });
    }
    if (died_year !== undefined && !isValidYear(died_year)) {
      return res.status(400).json({ message: 'died_year 1000–2100 oralig\'ida bo\'lishi kerak' });
    }

    const { rows } = await pool.query(
      `INSERT INTO creators (name, country_id, category_id, bio, born_year, died_year)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, name, country_id, category_id, bio, born_year, died_year, created_at`,
      [
        name.trim(),
        country_id  || null,
        category_id || null,
        bio         || null,
        born_year   || null,
        died_year   || null,
      ],
    );

    return res.status(201).json({ creator: rows[0] });
  } catch (err) {
    console.error('createCreator:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// PUT /api/creators/:id  (admin / specialist)
const updateCreator = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, country_id, category_id, bio, born_year, died_year } = req.body;

    if (name !== undefined && !name.trim()) {
      return res.status(400).json({ message: 'name bo\'sh bo\'lishi mumkin emas' });
    }
    if (born_year !== undefined && !isValidYear(born_year)) {
      return res.status(400).json({ message: 'born_year 1000–2100 oralig\'ida bo\'lishi kerak' });
    }
    if (died_year !== undefined && !isValidYear(died_year)) {
      return res.status(400).json({ message: 'died_year 1000–2100 oralig\'ida bo\'lishi kerak' });
    }

    const { rows } = await pool.query(
      `UPDATE creators SET
         name        = COALESCE($1, name),
         country_id  = COALESCE($2, country_id),
         category_id = COALESCE($3, category_id),
         bio         = COALESCE($4, bio),
         born_year   = COALESCE($5, born_year),
         died_year   = COALESCE($6, died_year)
       WHERE id = $7
       RETURNING id, name, country_id, category_id, bio, born_year, died_year, updated_at`,
      [
        name        ? name.trim() : null,
        country_id  || null,
        category_id || null,
        bio         || null,
        born_year   || null,
        died_year   || null,
        id,
      ],
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Ijodkor topilmadi' });
    }

    return res.json({ creator: rows[0] });
  } catch (err) {
    console.error('updateCreator:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// DELETE /api/creators/:id  (admin only)
const deleteCreator = async (req, res) => {
  try {
    const { id } = req.params;

    const { rowCount } = await pool.query(
      'DELETE FROM creators WHERE id = $1',
      [id],
    );

    if (!rowCount) {
      return res.status(404).json({ message: 'Ijodkor topilmadi' });
    }

    return res.status(204).send();
  } catch (err) {
    console.error('deleteCreator:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

module.exports = { listCreators, getCreator, createCreator, updateCreator, deleteCreator };
