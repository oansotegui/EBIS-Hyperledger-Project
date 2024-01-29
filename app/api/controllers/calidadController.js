// En calidadController.js
const { connectToNetwork } = require('../fabric');

const calidadController = {};

calidadController.registrarInspeccion = async (req, res) => {
    const { network, contract, gateway } = await connectToNetwork("calidadChannel", "calidad");
    try {
        const { loteID, fechaInspeccion, resultado, comentarios, inspector } = req.body;
        await contract.submitTransaction('RegistrarInspeccion', loteID, fechaInspeccion, resultado, comentarios, inspector);
        res.status(200).json({ result: 'Inspección registrada con éxito' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    } finally {
        gateway.disconnect();
    }
};

calidadController.consultarInspeccion = async (req, res) => {
    const loteID = req.params.loteID;
    if (!loteID) {
        return res.status(400).json({ error: 'El ID del lote no puede estar vacío' });
    }

    try {
        const { contract, gateway } = await connectToNetwork("calidadChannel", "calidad");
        const inspeccionResponse = await contract.evaluateTransaction('ConsultarInspeccion', loteID);
        const inspeccion = JSON.parse(inspeccionResponse.toString());

        res.json(inspeccion);
    } catch (error) {
        console.error(`Error al consultar la inspección: ${error}`);
        res.status(500).json({ error: `Error al consultar la inspección: ${error.message}` });
    } finally {
        if (gateway) {
            gateway.disconnect();
        }
    }
};

module.exports = calidadController;
