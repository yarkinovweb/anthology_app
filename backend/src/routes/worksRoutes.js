const { Router } = require('express');
const { authenticate, authorize, optionalAuth }         = require('../middleware/auth');
const { upload, validateFileSize, handleUploadError }  = require('../middleware/uploadMiddleware');
const { validateParam, validateQueryUUID }             = require('../middleware/validate');
const {
  uploadWork, listWorks, getWork, updateWorkStatus, deleteWork,
} = require('../controllers/worksController');

const router = Router();

router.get(
  '/',
  optionalAuth,
  validateQueryUUID('creator_id'),
  listWorks,
);

// /upload oldin bo'lishi kerak, aks holda /:id bilan to'qnashadi
router.post(
  '/upload',
  authenticate,
  authorize('researcher', 'specialist'),
  upload.single('file'),
  validateFileSize,
  handleUploadError,
  uploadWork,
);

router.get(
  '/:id',
  validateParam('id'),
  getWork,
);

router.patch(
  '/:id/status',
  authenticate,
  authorize('specialist'),
  validateParam('id'),
  updateWorkStatus,
);

router.delete(
  '/:id',
  authenticate,
  authorize('admin'),
  validateParam('id'),
  deleteWork,
);

module.exports = router;
