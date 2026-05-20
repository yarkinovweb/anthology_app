const { Router }              = require('express');
const { register, login, refresh } = require('../controllers/authController');

const router = Router();

router.post('/register', register);
router.post('/login',    login);
router.post('/refresh',  refresh);

module.exports = router;
