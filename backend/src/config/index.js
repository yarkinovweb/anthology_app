require('dotenv').config();

const required = (key) => {
  const val = process.env[key];
  if (!val) throw new Error(`Muhit o'zgaruvchisi topilmadi: ${key}`);
  return val;
};

module.exports = {
  port: parseInt(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',

  db: {
    host:     required('DB_HOST'),
    port:     parseInt(process.env.DB_PORT) || 5432,
    database: required('DB_NAME'),
    user:     required('DB_USER'),
    password: required('DB_PASSWORD'),
  },

  jwt: {
    accessSecret:      required('JWT_ACCESS_SECRET'),
    refreshSecret:     required('JWT_REFRESH_SECRET'),
    accessExpiresIn:   process.env.JWT_ACCESS_EXPIRES_IN  || '15m',
    refreshExpiresIn:  process.env.JWT_REFRESH_EXPIRES_IN || '7d',
    refreshExpiresMs:  7 * 24 * 60 * 60 * 1000,
  },

  // AWS kalitlari faqat media upload ishlatilganda tekshiriladi (s3Service.js ichida)
  aws: {
    accessKeyId:     process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region:          process.env.AWS_REGION,
    bucket:          process.env.AWS_S3_BUCKET_NAME,
  },
};
