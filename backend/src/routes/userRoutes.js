const { Router }    = require('express');
const { authenticate } = require('../middleware/auth');
const { getProfile, updateProfile } = require('../controllers/usersController');

const router = Router();

router.get('/profile',        authenticate, getProfile);
router.put('/profile/update', authenticate, updateProfile);

module.exports = router;
