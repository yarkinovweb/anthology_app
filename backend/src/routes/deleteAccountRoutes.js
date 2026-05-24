const { Router } = require('express');
const bcrypt     = require('bcrypt');
const pool       = require('../db/pool');

const router = Router();

const PAGE_HTML = `<!DOCTYPE html>
<html lang="uz">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Hisobni o'chirish — Antologiya</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f5f5f5;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }

    .card {
      background: #fff;
      border-radius: 16px;
      box-shadow: 0 2px 16px rgba(0,0,0,.10);
      padding: 40px 36px;
      max-width: 420px;
      width: 100%;
    }

    .icon {
      width: 56px;
      height: 56px;
      background: #fff0f0;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 20px;
      font-size: 28px;
    }

    h1 {
      font-size: 22px;
      font-weight: 700;
      color: #1a1a1a;
      text-align: center;
      margin-bottom: 8px;
    }

    .subtitle {
      font-size: 14px;
      color: #666;
      text-align: center;
      margin-bottom: 28px;
      line-height: 1.5;
    }

    .warning-box {
      background: #fff8e1;
      border: 1px solid #ffe082;
      border-radius: 10px;
      padding: 14px 16px;
      margin-bottom: 24px;
      font-size: 13px;
      color: #5a4000;
      line-height: 1.6;
    }

    .warning-box strong { color: #c85000; }

    label {
      display: block;
      font-size: 13px;
      font-weight: 600;
      color: #333;
      margin-bottom: 6px;
    }

    input {
      width: 100%;
      padding: 12px 14px;
      border: 1.5px solid #ddd;
      border-radius: 10px;
      font-size: 15px;
      color: #1a1a1a;
      outline: none;
      transition: border-color .2s;
      margin-bottom: 16px;
    }

    input:focus { border-color: #e53935; }

    button {
      width: 100%;
      padding: 14px;
      background: #e53935;
      color: #fff;
      font-size: 15px;
      font-weight: 700;
      border: none;
      border-radius: 10px;
      cursor: pointer;
      transition: background .2s, opacity .2s;
      margin-top: 4px;
    }

    button:hover  { background: #c62828; }
    button:disabled { opacity: .6; cursor: not-allowed; }

    .msg {
      display: none;
      border-radius: 10px;
      padding: 14px 16px;
      font-size: 14px;
      margin-top: 18px;
      line-height: 1.5;
    }

    .msg.success {
      background: #e8f5e9;
      border: 1px solid #a5d6a7;
      color: #1b5e20;
    }

    .msg.error {
      background: #ffebee;
      border: 1px solid #ef9a9a;
      color: #b71c1c;
    }

    .footer {
      margin-top: 24px;
      font-size: 12px;
      color: #aaa;
      text-align: center;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">🗑️</div>
    <h1>Hisobni o'chirish</h1>
    <p class="subtitle">Antologiya ilovasidagi hisobingizni butunlay o'chirish uchun quyidagi ma'lumotlarni kiriting.</p>

    <div class="warning-box">
      <strong>Diqqat!</strong> Hisobingiz o'chirilgandan so'ng:<br>
      • Barcha shaxsiy ma'lumotlaringiz o'chiriladi<br>
      • Siz yuklagan asarlar bilan aloqangiz uziladi<br>
      • Bu amalni qaytarib bo'lmaydi
    </div>

    <form id="deleteForm">
      <label for="email">Email manzil</label>
      <input type="email" id="email" placeholder="example@mail.com" required autocomplete="email" />

      <label for="password">Parol</label>
      <input type="password" id="password" placeholder="Parolingizni kiriting" required autocomplete="current-password" />

      <button type="submit" id="submitBtn">Hisobni o'chirish</button>
    </form>

    <div class="msg" id="msg"></div>

    <p class="footer">Antologiya &copy; 2024</p>
  </div>

  <script>
    document.getElementById('deleteForm').addEventListener('submit', async (e) => {
      e.preventDefault();

      const email    = document.getElementById('email').value.trim();
      const password = document.getElementById('password').value;
      const btn      = document.getElementById('submitBtn');
      const msg      = document.getElementById('msg');

      btn.disabled    = true;
      btn.textContent = 'Yuklanmoqda...';
      msg.style.display = 'none';

      try {
        const res  = await fetch('/delete-account', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password }),
        });
        const data = await res.json();

        if (res.ok) {
          document.getElementById('deleteForm').style.display = 'none';
          msg.className     = 'msg success';
          msg.textContent   = data.message;
          msg.style.display = 'block';
        } else {
          msg.className     = 'msg error';
          msg.textContent   = data.message || 'Xatolik yuz berdi. Qaytadan urinib ko\'ring.';
          msg.style.display = 'block';
          btn.disabled      = false;
          btn.textContent   = 'Hisobni o\'chirish';
        }
      } catch {
        msg.className     = 'msg error';
        msg.textContent   = 'Tarmoq xatosi. Internet aloqangizni tekshiring.';
        msg.style.display = 'block';
        btn.disabled      = false;
        btn.textContent   = 'Hisobni o\'chirish';
      }
    });
  </script>
</body>
</html>`;

// GET /delete-account — HTML sahifa
router.get('/', (_req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(PAGE_HTML);
});

// POST /delete-account — hisobni o'chirish
router.post('/', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email va parol majburiy' });
  }

  try {
    const { rows } = await pool.query(
      'SELECT id, password_hash FROM users WHERE email = $1',
      [email.toLowerCase().trim()],
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Bu email bilan hisob topilmadi' });
    }

    const valid = await bcrypt.compare(password, rows[0].password_hash);
    if (!valid) {
      return res.status(401).json({ message: 'Parol noto\'g\'ri' });
    }

    await pool.query('DELETE FROM users WHERE id = $1', [rows[0].id]);

    return res.json({ message: 'Hisobingiz muvaffaqiyatli o\'chirildi. Ilovadan foydalanganingiz uchun rahmat.' });
  } catch (err) {
    console.error('deleteAccount:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
});

module.exports = router;
