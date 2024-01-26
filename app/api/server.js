// En server.js
const express = require('express');
const app = express();
const { connectToNetwork } = require('./fabric');

app.use(express.json());

app.get('/', (req, res) => {
    res.status(200).send('API de Hyperledger Fabric está funcionando.');
});

app.post('/createTransaccion', async (req, res) => {
    const { network, contract, gateway } = await connectToNetwork();
    try {
        const { id, sapid, cantidad, precio } = req.body;
        const transactionResponse = await contract.submitTransaction('CreateTransaccion', id, sapid, cantidad.toString(), precio.toString());
        // Asegúrate de procesar la respuesta si es necesario
        res.status(200).json({ result: 'Transacción creada', txid: transactionResponse.transactionId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    } finally {
        gateway.disconnect();
    }
});

app.get('/transaccion/:id', async (req, res) => {
    const transaccionId = req.params.id;
    if (!transaccionId) {
        return res.status(400).json({ error: 'El ID de la transacción no puede estar vacío' });
    }

    try {
        const { contract, gateway } = await connectToNetwork();
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
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
