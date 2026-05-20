const pool = require('../db/pool');

// GET /api/admin/dashboard-stats  (admin only)
const getDashboardStats = async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT
        (SELECT COUNT(*)::int FROM users)                        AS total_users,
        (SELECT COUNT(*)::int FROM creators)                           AS approved_creators,
        (SELECT COUNT(*)::int FROM works)                        AS total_works,
        (SELECT COUNT(*)::int FROM works WHERE status = 'pending') AS pending_works
    `);

    return res.json({ stats: rows[0] });
  } catch (err) {
    console.error('getDashboardStats:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// GET /api/admin/users  (admin only)
const listUsers = async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT id, name, email, role, created_at
       FROM users
       ORDER BY created_at DESC`,
    );
    return res.json({ users: rows });
  } catch (err) {
    console.error('listUsers:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// PATCH /api/admin/users/:id/promote  (admin only)
// Faqat 'user' yoki 'researcher' rolini 'specialist' ga ko'taradi
const promoteUser = async (req, res) => {
  try {
    const { id } = req.params;

    const { rows: found } = await pool.query(
      'SELECT id, role FROM users WHERE id = $1',
      [id],
    );
    if (!found[0]) {
      return res.status(404).json({ message: 'Foydalanuvchi topilmadi' });
    }
    if (!['user', 'researcher'].includes(found[0].role)) {
      return res.status(400).json({
        message: 'Faqat user yoki researcher rolini specialist ga ko\'tarish mumkin',
      });
    }

    const { rows } = await pool.query(
      `UPDATE users SET role = 'specialist' WHERE id = $1
       RETURNING id, name, email, role`,
      [id],
    );
    return res.json({ user: rows[0] });
  } catch (err) {
    console.error('promoteUser:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

module.exports = { getDashboardStats, listUsers, promoteUser };
