const bcrypt = require('bcrypt');
const pool   = require('../db/pool');

const BCRYPT_ROUNDS = 12;

// GET /api/users/profile
const getProfile = async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, name, email, role FROM users WHERE id = $1',
      [req.user.id],
    );
    if (!rows[0]) {
      return res.status(404).json({ message: 'Foydalanuvchi topilmadi' });
    }
    return res.json({ user: rows[0] });
  } catch (err) {
    console.error('getProfile:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// PUT /api/users/profile/update
const updateProfile = async (req, res) => {
  try {
    const { name, password } = req.body;

    if (!name && !password) {
      return res.status(400).json({ message: 'name yoki password kerak' });
    }

    if (password && password.length < 8) {
      return res
        .status(400)
        .json({ message: "Parol kamida 8 ta belgi bo'lishi shart" });
    }

    const setClauses = [];
    const values     = [];

    if (name) {
      values.push(name.trim());
      setClauses.push(`name = $${values.length}`);
    }

    if (password) {
      const hash = await bcrypt.hash(password, BCRYPT_ROUNDS);
      values.push(hash);
      setClauses.push(`password_hash = $${values.length}`);
    }

    values.push(req.user.id);

    const { rows } = await pool.query(
      `UPDATE users SET ${setClauses.join(', ')}
       WHERE id = $${values.length}
       RETURNING id, name, email, role`,
      values,
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Foydalanuvchi topilmadi' });
    }

    return res.json({ user: rows[0] });
  } catch (err) {
    console.error('updateProfile:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

module.exports = { getProfile, updateProfile };
