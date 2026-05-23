const pool = require('../db/pool');
const { deleteFromS3 } = require('../services/s3Service');
const { isUUID } = require('../middleware/validate');
const { translateFields, parseLang } = require('../services/translationService');

const VALID_STATUSES    = ['pending', 'approved', 'rejected'];
const VALID_MEDIA_TYPES = ['image', 'audio', 'video', 'pdf', 'text'];

// POST /api/works/upload
const uploadWork = async (req, res) => {
  try {
    const file = req.file;
    if (!file) {
      return res.status(400).json({ message: 'Fayl yuklanmadi' });
    }

    const { creator_id, title, description, content_text } = req.body;

    if (!creator_id || !title) {
      await deleteFromS3(file.key).catch((e) =>
        console.error('S3 rollback xatosi:', e.message),
      );
      return res.status(400).json({ message: 'creator_id va title majburiy' });
    }

    if (!isUUID(creator_id)) {
      await deleteFromS3(file.key).catch((e) =>
        console.error('S3 rollback xatosi:', e.message),
      );
      return res.status(400).json({ message: 'creator_id UUID formatida bo\'lishi kerak' });
    }

    const creator = await pool.query('SELECT id FROM creators WHERE id = $1', [creator_id]);
    if (!creator.rows[0]) {
      await deleteFromS3(file.key).catch((e) =>
        console.error('S3 rollback xatosi:', e.message),
      );
      return res.status(404).json({ message: 'Ijodkor topilmadi' });
    }

    // Admin / specialist yuklaganda avtomat tasdiqlash
    const uploaderRole   = req.user?.role;
    const isPrivileged   = ['admin', 'specialist'].includes(uploaderRole);
    const initialStatus  = isPrivileged ? 'approved' : 'pending';
    const uploadedBy     = req.user?.id || null;

    const { rows } = await pool.query(
      `INSERT INTO works
         (creator_id, title, description, media_url, file_key, media_type,
          file_size, content_text, status, uploaded_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING id, creator_id, title, description, media_url, media_type,
                 file_size, content_text, status, created_at`,
      [
        creator_id,
        title.trim(),
        description   || null,
        file.location,
        file.key,
        file.mediaType,
        file.size,
        content_text  || null,
        initialStatus,
        uploadedBy,
      ],
    );

    return res.status(201).json({ work: rows[0] });
  } catch (err) {
    console.error('uploadWork:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// GET /api/works
// Query: search (title + content_text ILIKE), creator_id, media_type, status
const listWorks = async (req, res) => {
  try {
    const { search, creator_id, media_type, status } = req.query;

    const params = [];
    const where  = [];

    if (search) {
      params.push(`%${search}%`);
      const n = params.length;
      where.push(`(w.title ILIKE $${n} OR w.description ILIKE $${n} OR w.content_text ILIKE $${n})`);
    }

    if (creator_id) {
      params.push(creator_id);
      where.push(`w.creator_id = $${params.length}`);
    }

    if (media_type) {
      if (!VALID_MEDIA_TYPES.includes(media_type)) {
        return res.status(400).json({
          message: `media_type: ${VALID_MEDIA_TYPES.join(', ')} bo'lishi kerak`,
        });
      }
      params.push(media_type);
      where.push(`w.media_type = $${params.length}`);
    }

    // admin/specialist barcha statuslarni ko'ra oladi, boshqalar faqat approved
    const isPrivileged = req.user && ['admin', 'specialist'].includes(req.user.role);

    if (isPrivileged && status === 'all') {
      // status filtri qo'llanilmaydi — barcha statuslar qaytariladi
    } else {
      const filterStatus = (isPrivileged && status && VALID_STATUSES.includes(status))
        ? status
        : 'approved';
      params.push(filterStatus);
      where.push(`w.status = $${params.length}`);

      // Moderatsiya: specialist o'zi yuklagan asarlarni pending ro'yxatida ko'rmasin
      if (isPrivileged && filterStatus === 'pending' && req.user?.id) {
        params.push(req.user.id);
        where.push(`(w.uploaded_by IS NULL OR w.uploaded_by != $${params.length})`);
      }
    }

    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const { rows } = await pool.query(
      `SELECT w.id, w.title, w.description, w.media_url, w.media_type,
              w.file_size, w.content_text, w.status, w.created_at,
              c.id AS creator_id, c.name AS creator_name
       FROM works w
       JOIN creators c ON c.id = w.creator_id
       ${whereClause}
       ORDER BY w.created_at DESC`,
      params,
    );

    return res.json({ works: rows });
  } catch (err) {
    console.error('listWorks:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// GET /api/works/:id
const getWork = async (req, res) => {
  try {
    const { id } = req.params;

    const { rows } = await pool.query(
      `SELECT w.id, w.title, w.description, w.media_url, w.media_type,
              w.file_size, w.content_text, w.status, w.created_at, w.updated_at,
              c.id AS creator_id, c.name AS creator_name
       FROM works w
       JOIN creators c ON c.id = w.creator_id
       WHERE w.id = $1`,
      [id],
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Asar topilmadi' });
    }

    // Tavsif va matnni foydalanuvchi tiliga tarjima qilish
    const targetLang = parseLang(req.headers['accept-language']);
    const work       = await translateFields(
      rows[0],
      ['description', 'content_text'],
      targetLang,
    );

    return res.json({ work });
  } catch (err) {
    console.error('getWork:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// PATCH /api/works/:id/status  (specialist / admin)
const updateWorkStatus = async (req, res) => {
  try {
    const { id }     = req.params;
    const { status } = req.body;

    if (!status || !VALID_STATUSES.includes(status)) {
      return res.status(400).json({
        message: `status qiymati: ${VALID_STATUSES.join(', ')} bo'lishi kerak`,
      });
    }

    const { rows } = await pool.query(
      `UPDATE works SET status = $1 WHERE id = $2
       RETURNING id, title, status, updated_at`,
      [status, id],
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Asar topilmadi' });
    }

    return res.json({ work: rows[0] });
  } catch (err) {
    console.error('updateWorkStatus:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

// DELETE /api/works/:id  (admin only)
const deleteWork = async (req, res) => {
  try {
    const { id } = req.params;

    const { rows } = await pool.query(
      'DELETE FROM works WHERE id = $1 RETURNING file_key',
      [id],
    );

    if (!rows[0]) {
      return res.status(404).json({ message: 'Asar topilmadi' });
    }

    await deleteFromS3(rows[0].file_key).catch((e) =>
      console.error('S3 dan o\'chirishda xato:', e.message),
    );

    return res.status(204).send();
  } catch (err) {
    console.error('deleteWork:', err);
    return res.status(500).json({ message: 'Server xatosi' });
  }
};

module.exports = { uploadWork, listWorks, getWork, updateWorkStatus, deleteWork };
