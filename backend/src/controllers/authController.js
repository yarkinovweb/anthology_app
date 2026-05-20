const bcrypt = require('bcrypt');
const pool   = require('../db/pool');
const config = require('../config');
const {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
  hashToken,
} = require('../utils/tokenUtils');

const BCRYPT_ROUNDS = 12;

// POST /api/auth/register
const register = async (req, res) => {
  const { name, email, password, role } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'name, email va password majburiy' });
  }
  if (password.length < 8) {
    return res.status(400).json({ message: 'Password kamida 8 ta belgi bo\'lishi shart' });
  }

  const allowedRoles = ['user', 'researcher'];
  const userRole = allowedRoles.includes(role) ? role : 'user';

  try {
    const exists = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (exists.rows.length > 0) {
      return res.status(409).json({ message: 'Bu email allaqachon ro\'yxatdan o\'tgan' });
    }

    const password_hash = await bcrypt.hash(password, BCRYPT_ROUNDS);

    const { rows } = await pool.query(
      `INSERT INTO users (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role`,
      [name, email, password_hash, userRole],
    );
    const user = rows[0];

    const tokens = await issueTokens(user.id, user.role);

    return res.status(201).json({ user, ...tokens });
  } catch (err) {
    console.error('register:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'email va password majburiy' });
  }

  try {
    const { rows } = await pool.query(
      'SELECT id, name, email, password_hash, role FROM users WHERE email = $1',
      [email],
    );
    const user = rows[0];

    // Timing-safe: bcrypt.compare ham noto'g'ri emailda ishlaydi
    const dummyHash = '$2b$12$invalidhashfortimingreasons000000000000000000000000000';
    const isMatch = user
      ? await bcrypt.compare(password, user.password_hash)
      : await bcrypt.compare(password, dummyHash);

    if (!user || !isMatch) {
      return res.status(401).json({ message: 'Email yoki password noto\'g\'ri' });
    }

    const tokens = await issueTokens(user.id, user.role);

    return res.json({
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
      ...tokens,
    });
  } catch (err) {
    console.error('login:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// POST /api/auth/refresh
const refresh = async (req, res) => {
  const { refresh_token } = req.body;

  if (!refresh_token) {
    return res.status(400).json({ message: 'refresh_token majburiy' });
  }

  try {
    // 1. JWT imzosini tekshir
    let payload;
    try {
      payload = verifyRefreshToken(refresh_token);
    } catch {
      return res.status(401).json({ message: 'Refresh token yaroqsiz yoki muddati o\'tgan' });
    }

    // 2. DB'da heshni izla
    const tokenHash = hashToken(refresh_token);
    const { rows } = await pool.query(
      'SELECT id, user_id, expires_at FROM refresh_tokens WHERE token_hash = $1',
      [tokenHash],
    );
    const stored = rows[0];

    if (!stored) {
      // Token topilmadimi — ehtimol token o'g'irlangan va allaqachon aylantirilgan.
      // Foydalanuvchining barcha sessiyalarini bekor qil.
      await pool.query('DELETE FROM refresh_tokens WHERE user_id = $1', [payload.sub]);
      return res.status(401).json({ message: 'Refresh token qayta ishlatilgan yoki topilmadi' });
    }

    if (new Date(stored.expires_at) < new Date()) {
      await pool.query('DELETE FROM refresh_tokens WHERE id = $1', [stored.id]);
      return res.status(401).json({ message: 'Refresh token muddati o\'tgan' });
    }

    // 3. Token rotation: eskisini o'chir, yangi juft chiqar
    await pool.query('DELETE FROM refresh_tokens WHERE id = $1', [stored.id]);

    const userResult = await pool.query('SELECT id, role FROM users WHERE id = $1', [stored.user_id]);
    const user = userResult.rows[0];
    if (!user) {
      return res.status(401).json({ message: 'Foydalanuvchi topilmadi' });
    }

    const tokens = await issueTokens(user.id, user.role);

    return res.json(tokens);
  } catch (err) {
    console.error('refresh:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// Tokenlar chiqarish va refresh tokenni DB'ga saqlash
async function issueTokens(userId, role) {
  const payload       = { sub: userId, role };
  const access_token  = generateAccessToken(payload);
  const refresh_token = generateRefreshToken(payload);

  const tokenHash = hashToken(refresh_token);
  const expiresAt = new Date(Date.now() + config.jwt.refreshExpiresMs);

  await pool.query(
    'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)',
    [userId, tokenHash, expiresAt],
  );

  return { access_token, refresh_token };
}

module.exports = { register, login, refresh };
