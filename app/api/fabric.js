const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function connectToNetwork(channelName, contractName) {
  const ccpPath = path.resolve(__dirname, 'test-network.json'); // Asegúrate de tener tu archivo de conexión
  const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

  // Configura un wallet para manejar las identidades
  const walletPath = path.join(process.cwd(), 'wallet');
  const wallet = await Wallets.newFileSystemWallet(walletPath);

  // Verifica que ya tenemos una identidad para interactuar con la red
  const identity = await wallet.get('Admin@farmaceutica.farma.com'); // Reemplaza 'tuIdentidad' con tu identidad real
  if (!identity) {
    console.log('No se encontró esa identidad en el wallet');
    return;
  }

  const gateway = new Gateway();
  await gateway.connect(ccp, { wallet, identity: 'Admin@farmaceutica.farma.com', discovery: { enabled: true, asLocalhost: true } });

  // Obtener el canal y el contrato
  const network = await gateway.getNetwork(channelName);
  const contract = network.getContract(contractName);

  console.log("Conexión a la red lista");

  return { network, contract, gateway };
}

module.exports.connectToNetwork = connectToNetwork;
