const { Router }     = require('express');
const { authenticate, authorize } = require('../middleware/auth');
const { validateParam } = require('../middleware/validate');
const {
  getDashboardStats,
  listUsers,
  promoteUser,
} = require('../controllers/adminController');

const router = Router();

// Dashboard statistika — faqat admin
router.get(
  '/dashboard-stats',
  authenticate,
  authorize('admin'),
  getDashboardStats,
);

// Foydalanuvchilar ro'yxati — faqat admin
router.get(
  '/users',
  authenticate,
  authorize('admin'),
  listUsers,
);

// Foydalanuvchini specialist ga ko'tarish — faqat admin
router.patch(
  '/users/:id/promote',
  authenticate,
  authorize('admin'),
  validateParam('id'),
  promoteUser,
);

module.exports = router;
