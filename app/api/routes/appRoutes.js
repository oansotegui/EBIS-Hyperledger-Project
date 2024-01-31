const express = require('express');
const router = express.Router();

const calidadController = require('../controllers/calidadController');
const farmaController = require('../controllers/farmaController');
const ventasController = require('../controllers/ventasController');

// Rutas para Ventas
router.post('/ventas/createTransaction', ventasController.createTransaction);
router.get('/ventas/getTransaction/:id', ventasController.getTransaction);

// Rutas para Trazabilidad
router.post('/trazabilidad/createFarmaco', farmaController.createFarmaco);
router.get('/trazabilidad/readFarmaco/:id', farmaController.readFarmaco);
router.put('/trazabilidad/updateFarmaco/:id', farmaController.updateFarmaco);
router.delete('/trazabilidad/deleteFarmaco/:id', farmaController.deleteFarmaco);
router.get('/trazabilidad/getAllFarmacos', farmaController.getAllFarmacos);
router.get('/trazabilidad/getFarmacoHistory/:id', farmaController.getFarmacoHistory);

// Rutas para Calidad
router.post('/calidad/registrarInspeccion', calidadController.registrarInspeccion);
router.get('/calidad/consultarInspeccion/:loteID', calidadController.consultarInspeccion);

module.exports = router;