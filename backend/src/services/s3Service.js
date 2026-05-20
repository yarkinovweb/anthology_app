const { S3Client, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const config = require('../config');

// AWS kalitlari mavjudligini server start'da emas, birinchi ishlatilganda tekshir
const getS3Client = (() => {
  let client = null;
  return () => {
    if (!client) {
      const { accessKeyId, secretAccessKey, region, bucket } = config.aws;
      if (!accessKeyId || !secretAccessKey || !region || !bucket) {
        throw new Error(
          'AWS konfiguratsiyasi to\'liq emas. .env faylida AWS_ACCESS_KEY_ID, ' +
          'AWS_SECRET_ACCESS_KEY, AWS_REGION, AWS_S3_BUCKET_NAME ni to\'ldiring.',
        );
      }
      client = new S3Client({
        region,
        credentials: { accessKeyId, secretAccessKey },
      });
    }
    return client;
  };
})();

// Bucket'dan faylni o'chirish (upload validatsiya muvaffaqiyatsiz bo'lganda ishlatiladi)
const deleteFromS3 = async (key) => {
  const s3 = getS3Client();
  await s3.send(
    new DeleteObjectCommand({ Bucket: config.aws.bucket, Key: key }),
  );
};

module.exports = { getS3Client, deleteFromS3 };
