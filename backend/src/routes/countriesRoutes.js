const { Router } = require('express');
const { listCountries } = require('../controllers/countriesController');

const router = Router();

router.get('/', listCountries);

module.exports = router;
