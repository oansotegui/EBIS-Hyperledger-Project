// En farmaController.js
const { connectToNetwork } = require('../fabric');

const farmaController = {};

farmaController.createFarmaco = async (req, res) => {
    const { network, contract, gateway } = await connectToNetwork("farmachannel", "trazabilidad");
    try {
        const { ph, temperature, user, geo, estado, extradata } = req.body;
        await contract.submitTransaction('CreateFarmaco', ph, temperature.toString(), user, geo, estado, extradata);
        res.status(200).json({ result: 'Fármaco creado con éxito' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    } finally {
        gateway.disconnect();
    }
};

farmaController.readFarmaco = async (req, res) => {
    const farmacoId = req.params.id;
    if (!farmacoId) {
        return res.status(400).json({ error: 'El ID del fármaco no puede estar vacío' });
    }
    const { network, contract, gateway } = await connectToNetwork("farmachannel", "trazabilidad");
    try {
        const farmacoResponse = await contract.evaluateTransaction('ReadFarmaco', farmacoId);
        const farmaco = JSON.parse(farmacoResponse.toString());

        res.json(farmaco);
    } catch (error) {
        console.error(`Error al leer el fármaco: ${error}`);
        res.status(500).json({ error: `Error al leer el fármaco: ${error.message}` });
    } finally {
        if (gateway) {
            gateway.disconnect();
        }
    }
};

farmaController.updateFarmaco = async (req, res) => {
    const farmacoId = req.params.id;
    const { ph, temperature, user, geo, estado, extradata } = req.body;
    const { network, contract, gateway } = await connectToNetwork("farmachannel", "trazabilidad");
    try {
        await contract.submitTransaction('UpdateFarmaco', farmacoId, ph, temperature.toString(), user, geo, estado, extradata);
        res.status(200).json({ result: 'Fármaco actualizado con éxito' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    } finally {
        gateway.disconnect();
    }
};

farmaController.deleteFarmaco = async (req, res) => {
    const farmacoId = req.params.id;
    const { network, contract, gateway } = await connectToNetwork("farmachannel", "trazabilidad");
    try {
        await contract.submitTransaction('DeleteFarmaco', farmacoId);
        res.status(200).json({ result: 'Fármaco eliminado con éxito' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    } finally {
        gateway.disconnect();
    }
};

farmaController.getAllFarmacos = async (req, res) => {
    const { network, contract, gateway } = await connectToNetwork("farmachannel", "trazabilidad");
    try {
        const allFarmacosResponse = await contract.evaluateTransaction('GetAllFarmacos');
        const allFarmacos = JSON.parse(allFarmacosResponse.toString());

        res.json(allFarmacos);
    } catch (error) {
        console.error(`Error al obtener todos los fármacos: ${error}`);
        res.status(500).json({ error: `Error al obtener todos los fármacos: ${error.message}` });
    } finally {
        if (gateway) {
            gateway.disconnect();
        }
    }
};

farmaController.getFarmacoHistory = async (req, res) => {
    const farmacoId = req.params.id;
    const { network, contract, gateway } = await connectToNetwork("farmachannel", "trazabilidad");
    try {
        const farmacoHistoryResponse = await contract.evaluateTransaction('GetFarmacoHistory', farmacoId);
        const farmacoHistory = JSON.parse(farmacoHistoryResponse.toString());

        res.json(farmacoHistory);
    } catch (error) {
        console.error(`Error al obtener el historial del fármaco: ${error}`);
        res.status(500).json({ error: `Error al obtener el historial del fármaco: ${error.message}` });
    } finally {
        if (gateway) {
            gateway.disconnect();
        }
    }
};

module.exports = farmaController;
