// En server.js
const express = require('express');
const appRoutes = require('./routes/appRoutes');
const app = express();


app.use(express.json());

app.use(express.static('../frontend'));

// Ruta Básica
app.get('/', (req, res) => {
    res.status(200).send('API de Hyperledger Fabric está funcionando.');
});

// Resto de rutas
app.use('/routes', appRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
