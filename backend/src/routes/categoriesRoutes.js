const { Router } = require('express');
const { listCategories } = require('../controllers/categoriesController');

const router = Router();

router.get('/', listCategories);

module.exports = router;
