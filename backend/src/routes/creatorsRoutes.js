const { Router } = require('express');
const { authenticate, authorize }          = require('../middleware/auth');
const { validateParam, validateQueryUUID } = require('../middleware/validate');
const {
  listCreators, getCreator, createCreator, updateCreator, deleteCreator,
} = require('../controllers/creatorsController');

const router = Router();

router.get(
  '/',
  validateQueryUUID('country_id'),
  validateQueryUUID('category_id'),
  listCreators,
);

router.get(
  '/:id',
  validateParam('id'),
  getCreator,
);

router.post(
  '/',
  authenticate,
  authorize('admin', 'specialist'),
  createCreator,
);

router.put(
  '/:id',
  authenticate,
  authorize('admin', 'specialist'),
  validateParam('id'),
  updateCreator,
);

router.delete(
  '/:id',
  authenticate,
  authorize('admin', 'specialist'),
  validateParam('id'),
  deleteCreator,
);

module.exports = router;
