const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const isUUID = (str) => UUID_RE.test(str);

// Route param UUID tekshiruvi: validateParam('id')
const validateParam = (param) => (req, res, next) => {
  if (!isUUID(req.params[param])) {
    return res.status(400).json({ message: `${param} UUID formatida bo'lishi kerak` });
  }
  next();
};

// Query param UUID tekshiruvi (ixtiyoriy): validateQueryUUID('country_id')
const validateQueryUUID = (param) => (req, res, next) => {
  if (req.query[param] && !isUUID(req.query[param])) {
    return res.status(400).json({ message: `${param} UUID formatida bo'lishi kerak` });
  }
  next();
};

// Body maydonlari mavjudligini tekshirish: requireBody('title', 'creator_id')
const requireBody = (...fields) => (req, res, next) => {
  const missing = fields.filter(
    (f) => req.body[f] === undefined || req.body[f] === null || req.body[f] === '',
  );
  if (missing.length) {
    return res.status(400).json({ message: `Majburiy maydonlar: ${missing.join(', ')}` });
  }
  next();
};

// Yil qiymatini tekshirish (1000–2100 oralig'i)
const isValidYear = (val) => {
  const n = Number(val);
  return Number.isInteger(n) && n >= 1000 && n <= 2100;
};

module.exports = { validateParam, validateQueryUUID, requireBody, isUUID, isValidYear };
