const { verifyAccessToken } = require('../utils/tokenUtils');

// Bearer token tekshirish
const authenticate = (req, res, next) => {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Avtorizatsiya tokeni taqdim etilmagan' });
  }

  const token = header.slice(7);

  try {
    const payload = verifyAccessToken(token);
    req.user = { id: payload.sub, role: payload.role };
    next();
  } catch {
    return res.status(401).json({ message: 'Token yaroqsiz yoki muddati o\'tgan' });
  }
};

// Role-based access control
const authorize = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return res.status(403).json({ message: 'Bu amalni bajarishga ruxsat yo\'q' });
  }
  next();
};

// Token bo'lsa req.user ni to'ldiradi, bo'lmasa bloklamaydi (public routelar uchun)
const optionalAuth = (req, _res, next) => {
  const header = req.headers.authorization;
  if (header && header.startsWith('Bearer ')) {
    try {
      const payload = verifyAccessToken(header.slice(7));
      req.user = { id: payload.sub, role: payload.role };
    } catch {
      // yaroqsiz token — autentifikatsiyasiz davom etiladi
    }
  }
  next();
};

module.exports = { authenticate, authorize, optionalAuth };
