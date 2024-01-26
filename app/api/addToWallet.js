const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function addToWallet(orgMspPath, userId) {
    // Crea una nueva instancia de un wallet en el directorio actual llamado 'wallet'
    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    // Construye las rutas a la clave privada y al certificado
    const privateKeyDirectoryPath = path.join(orgMspPath, 'keystore');
    const certPath = path.join(orgMspPath, 'signcerts', `cert.pem`);

    // La clave privada es el único archivo dentro de 'keystore'
    const privateKeyFileName = fs.readdirSync(privateKeyDirectoryPath)[0];
    const privateKeyPath = path.join(privateKeyDirectoryPath, privateKeyFileName);

    // Lee la clave privada y el certificado
    const privateKey = fs.readFileSync(privateKeyPath, 'utf8');
    const certificate = fs.readFileSync(certPath, 'utf8');

    // Importa la identidad al wallet
    const identityLabel = userId;
    const identity = {
        credentials: {
            certificate,
            privateKey,
        },
        mspId: 'FarmaceuticaMSP',
        type: 'X.509',
    };
    await wallet.put(identityLabel, identity);
}

// La ruta al directorio 'msp' del usuario que quieres añadir al wallet
const orgMspPath = path.join(__dirname, '..', '..', 'organizations', 'peerOrganizations', 'farmaceutica.farma.com', 'users', 'Admin@farmaceutica.farma.com', 'msp');
const userId = 'Admin@farmaceutica.farma.com';

addToWallet(orgMspPath, userId).then(() => {
    console.log(`Identity for ${userId} added to wallet`);
}).catch((error) => {
    console.error(`Error adding identity to wallet: ${error}`);
});
