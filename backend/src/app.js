require('dotenv').config();
const express   = require('express');
const helmet    = require('helmet');
const rateLimit = require('express-rate-limit');
const config    = require('./config');
const authRoutes       = require('./routes/authRoutes');
const worksRoutes      = require('./routes/worksRoutes');
const creatorsRoutes   = require('./routes/creatorsRoutes');
const countriesRoutes  = require('./routes/countriesRoutes');
const categoriesRoutes = require('./routes/categoriesRoutes');
const adminRoutes      = require('./routes/adminRoutes');
const userRoutes       = require('./routes/userRoutes');

const app = express();

// Xavfsizlik headerlari
app.use(helmet());
app.use(express.json());

const isDev = config.nodeEnv === 'development';

// Umumiy rate limit: 15 daqiqada 100 so'rov (dev muhitida o'chirilgan)
app.use('/api/', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  skip: () => isDev,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Juda ko\'p so\'rovlar, keyinroq urinib ko\'ring' },
}));

// Auth endpointlari uchun limit: 15 daqiqada 10 urinish (dev muhitida o'chirilgan)
app.use('/api/auth', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  skip: () => isDev,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Juda ko\'p urinishlar, 15 daqiqadan keyin qayta urinib ko\'ring' },
}));

app.use('/api/auth',       authRoutes);
app.use('/api/works',      worksRoutes);
app.use('/api/creators',   creatorsRoutes);
app.use('/api/countries',  countriesRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/admin',      adminRoutes);
app.use('/api/users',      userRoutes);

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

// 404
app.use((_req, res) => res.status(404).json({ message: 'Endpoint topilmadi' }));

// Global error handler
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ message: 'Server xatosi' });
});

// '0.0.0.0' — Railway va boshqa hosting platformalari uchun zarur
app.listen(config.port, '0.0.0.0', () => {
  console.log(`Server ${config.nodeEnv} rejimida ${config.port}-portda ishlamoqda`);
});

module.exports = app;
