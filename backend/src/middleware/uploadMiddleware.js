const path     = require('path');
const { v4: uuidv4 } = require('uuid');
const multer   = require('multer');
const multerS3 = require('multer-s3');
const config   = require('../config');
const { getS3Client, deleteFromS3 } = require('../services/s3Service');

// ─── Ruxsat etilgan MIME turlar ───────────────────────────────────────────────
const ALLOWED_MIME = {
  image: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
  audio: ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4', 'audio/aac'],
  video: ['video/mp4', 'video/mpeg', 'video/quicktime', 'video/webm'],
  pdf:   ['application/pdf'],
};

// ─── Har bir tur uchun maksimal hajm ─────────────────────────────────────────
const SIZE_LIMIT = {
  image:  5  * 1024 * 1024,  //   5 MB
  audio:  50 * 1024 * 1024,  //  50 MB
  video:  200 * 1024 * 1024, // 200 MB
  pdf:    20 * 1024 * 1024,  //  20 MB
};

// Barcha turlar uchun umumiy maksimal limit (multer uchun)
const MAX_FILE_SIZE = SIZE_LIMIT.video;

// MIME → kategoriya
const getMediaType = (mimetype) => {
  for (const [type, mimes] of Object.entries(ALLOWED_MIME)) {
    if (mimes.includes(mimetype)) return type;
  }
  return null;
};

// ─── Fayl turi filtri (MIME tekshiruvi) ──────────────────────────────────────
const fileFilter = (_req, file, cb) => {
  const mediaType = getMediaType(file.mimetype);
  if (!mediaType) {
    return cb(
      Object.assign(new Error(`Fayl turi qo'llab-quvvatlanmaydi: ${file.mimetype}`), {
        status: 400,
      }),
      false,
    );
  }
  cb(null, true);
};

// ─── Multer instance (lazy) ───────────────────────────────────────────────────
// S3 client va multer birinchi so'rovda yaratiladi — server start'da AWS kalitlari
// bo'lmasa ham crash bo'lmaydi.
let _upload = null;
const getUploader = () => {
  if (!_upload) {
    const storage = multerS3({
      s3: getS3Client(),
      bucket: config.aws.bucket,
      contentType: multerS3.AUTO_CONTENT_TYPE,
      metadata: (req, file, cb) => {
        cb(null, { uploadedBy: String(req.user?.id ?? 'anonymous') });
      },
      key: (_req, file, cb) => {
        const mediaType = getMediaType(file.mimetype);
        const ext       = path.extname(file.originalname).toLowerCase();
        const key       = `media/${mediaType}/${Date.now()}-${uuidv4()}${ext}`;
        cb(null, key);
      },
    });
    _upload = multer({ storage, fileFilter, limits: { fileSize: MAX_FILE_SIZE } });
  }
  return _upload;
};

// Route'larda ishlatish uchun: upload.single('file') o'rniga uploadSingle('file')
const upload = {
  single: (fieldName) => (req, res, next) => getUploader().single(fieldName)(req, res, next),
  array:  (fieldName, max) => (req, res, next) => getUploader().array(fieldName, max)(req, res, next),
};

// ─── Hajm validatsiyasi (upload'dan keyin, tur bo'yicha) ─────────────────────
// multer global limitni (200 MB) o'tkazib yuboradi, lekin har bir tur o'z chegarasiga ega.
// Fayl S3'ga yuklangandan so'ng hajmni tekshiramiz; oshsa — S3'dan o'chirib, 400 qaytaramiz.
const validateFileSize = async (req, res, next) => {
  const file = req.file;
  if (!file) return next();

  const mediaType  = getMediaType(file.mimetype);
  const limitBytes = SIZE_LIMIT[mediaType];

  if (file.size > limitBytes) {
    try {
      await deleteFromS3(file.key);
    } catch (err) {
      console.error('S3 dan fayl o\'chirishda xato:', err.message);
    }
    const limitMB = limitBytes / (1024 * 1024);
    return res.status(400).json({
      message: `${mediaType} fayl hajmi ${limitMB} MB dan oshmasligi kerak (yuklangan: ${(file.size / 1024 / 1024).toFixed(1)} MB)`,
    });
  }

  // Keyingi handlerlar uchun mediaType ni fayl ob'ektiga biriktir
  req.file.mediaType = mediaType;
  next();
};

// ─── Multer xatoliklarini ushlab, qulay javob qaytarish ──────────────────────
const handleUploadError = (err, _req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        message: `Fayl hajmi ${MAX_FILE_SIZE / (1024 * 1024)} MB dan oshmasligi kerak`,
      });
    }
    return res.status(400).json({ message: `Yuklash xatosi: ${err.message}` });
  }
  if (err?.status === 400) {
    return res.status(400).json({ message: err.message });
  }
  next(err);
};

module.exports = {
  upload,
  validateFileSize,
  handleUploadError,
  ALLOWED_MIME,
  SIZE_LIMIT,
  getMediaType,
};
