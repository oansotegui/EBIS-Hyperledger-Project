const { connectToNetwork } = require('../fabric');

const ventasController = {};

ventasController.createTransaction =  async (req, res) => {
    const { network, contract, gateway } = await connectToNetwork("ventaschannel", "ventas");
    try {
        const { id, sapid, cantidad, precio } = req.body;
        const transactionResponse = await contract.submitTransaction('CreateTransaccion', id, sapid, cantidad, precio);
        // Asegúrate de procesar la respuesta si es necesario
        res.status(200).json({ result: 'Transacción creada', txid: transactionResponse.transactionId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    } finally {
        gateway.disconnect();
    }
};

ventasController.getTransaction = async (req, res) => {
    const transaccionId = req.params.id;

    if (!transaccionId) {
        return res.status(400).json({ error: 'El ID de la transacción no puede estar vacío' });
    }
    const { network, contract, gateway } = await connectToNetwork("ventaschannel", "ventas");

    try {
        const transaccionResponse = await contract.evaluateTransaction('ReadTransaccion', transaccionId);
        const transaccion = JSON.parse(transaccionResponse.toString());

        res.json(transaccion);
    } catch (error) {
        console.error(`Error al leer la transacción: ${error}`);
        res.status(500).json({ error: `Error al leer la transacción: ${error.message}` });
    } finally {
        // Asegúrate de cerrar la conexión al gateway después de realizar la operación
        if (gateway) {
            gateway.disconnect();
        }
    }
};

module.exports = ventasController;