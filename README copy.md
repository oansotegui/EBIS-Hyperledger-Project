# EBIS-Hyperledger-Project

## CASO PRÁCTICO II: CREACIÓN DE UN PROYECTO DE TRAZABILIDAD DE FÁRMACOS

### Configuración y Despliegue

#### Crear Archivos de Configuración


# Navegar al directorio del proyecto
cd ~/EBIS-Hyperledger-Project

# Detener todos los contenedores Docker, eliminarlos junto con volúmenes y redes.

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker volume prune -f
docker network prune -f

# Eliminar directorios antiguos de configuraciones y crear nuevos.
sudo rm -rf organizations/fabric-ca/farmaceutica/
sudo rm -rf organizations/fabric-ca/calidad/ 
sudo rm -rf organizations/fabric-ca/logistica/
sudo rm -rf organizations/fabric-ca/delivery/
sudo rm -rf organizations/fabric-ca/ordererOrg/
sudo rm -rf organizations/peerOrganizations
sudo rm -rf organizations/ordererOrganizations
sudo rm -rf channel-artifacts/
mkdir channel-artifacts

# Levantar los servicios definidos en el Docker Compose para la CA.
docker-compose -f docker/docker-compose-farma-ca.yaml up -d

# Establecer las variables de entorno necesarias para los binarios de Fabric.
export PATH=${PWD}/fabric-samples/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx

# Registrar y enrolar a las organizaciones utilizando el script proporcionado.
. ./organizations/fabric-ca/registerEnrollFarma.sh && createFarmaceutica
. ./organizations/fabric-ca/registerEnrollFarma.sh && createCalidad
. ./organizations/fabric-ca/registerEnrollFarma.sh && createLogistica
. ./organizations/fabric-ca/registerEnrollFarma.sh && createDelivery
. ./organizations/fabric-ca/registerEnrollFarma.sh && createOrderer

# Copiar el archivo de configuración y generar bloques de génesis para canales.
cp configtx/configtxFarma.yaml configtx/configtx.yaml  
configtxgen -profile FarmaApplicationGenesis -outputBlock ./channel-artifacts/farmachannel.block -channelID farmachannel
configtxgen -profile VentasGenesis -outputBlock ./channel-artifacts/ventaschannel.block -channelID ventaschannel
configtxgen -profile CalidadGenesis -outputBlock ./channel-artifacts/calidadchannel.block -channelID calidadchannel
export FABRIC_CFG_PATH=${PWD}/fabric-samples/config

# Configurar el acceso a los certificados del ordenador.
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/server.key

# Levantar los peers y servicios adicionales definidos en el segundo Docker Compose.
docker-compose -f docker/docker-compose-farma.yaml  up -d

# Unir los ordenadores a los canales utilizando la herramienta osnadmin.
osnadmin channel join --channelID farmachannel --config-block ./channel-artifacts/farmachannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel join --channelID ventaschannel --config-block ./channel-artifacts/ventaschannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel join --channelID calidadchannel --config-block ./channel-artifacts/calidadchannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"

# Configurar TLS y variables de entorno para peer de Farmacéutica y unirse a los canales.
export CORE_PEER_TLS_ENABLED=true
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel join -b ./channel-artifacts/farmachannel.block
peer channel join -b ./channel-artifacts/ventaschannel.block
peer channel join -b ./channel-artifacts/calidadchannel.block

# Unir el peer1 de Farmacéutica a los canales.
export PEER1_EMPRESA_CA=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_EMPRESA_CA
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_ADDRESS=localhost:3051
peer channel join -b ./channel-artifacts/farmachannel.block
peer channel join -b ./channel-artifacts/ventaschannel.block

# Establecer el peer0 de Farmacéutica como Anchor Peer.
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com -c farmachannel --tls --cafile "$ORDERER_CA"

# Unir Logística, Delivery y Calidad a sus respectivos canales.
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="LogisticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/logistica.farma.com/users/Admin@logistica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer channel join -b ./channel-artifacts/farmachannel.block

export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="DeliveryMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp
export CORE_PEER_ADDRESS=localhost:2051
peer channel join -b ./channel-artifacts/farmachannel.block
peer channel join -b ./channel-artifacts/ventaschannel.block

export PEER0_CALIDAD_CA=${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="CalidadMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CALIDAD_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/calidad.farma.com/users/Admin@calidad.farma.com/msp
export CORE_PEER_ADDRESS=localhost:11051
peer channel join -b ./channel-artifacts/calidadchannel.block



# CHAINCODES
# Ventas

cd chaincode/ventas/
go mod init ventas
go mod tidy
go mod vendor

cd ../..

# Establecer la Ruta de Acceso y la Configuración de Fabric
export PATH=${PWD}/fabric-samples/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/fabric-samples/config

peer version

# Empaquetar el Chaincode
peer lifecycle chaincode package ventas.tar.gz --path ./chaincode/ventas --lang golang --label ventas_1.0

# Configurar Variables para la Organización Farmaceutica
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Instalar el Chaincode en el Peer de Farmaceutica
peer lifecycle chaincode install ventas.tar.gz

# Configurar Variables para la Organización Delivery
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="DeliveryMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp
export CORE_PEER_ADDRESS=localhost:2051

# Instalar el Chaincode en el Peer de Farmaceutica
peer lifecycle chaincode install ventas.tar.gz

# peer lifecycle chaincode queryinstalled
peer lifecycle chaincode queryinstalled
//copiar el ID del package, es una combinación del nombre del chaincode y el ventas del contenido del código

# Exportar el ID del Chaincode Instalado
export CC_PACKAGE_ID=ventas_1.0:f1ecde508a982d40e8c9f46f2acbf8498703b05ce5614e2dcddd172fa50130f0

# Aprobar el Chaincode para DElivery (ya hemos configurado las variables de entorno)
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID ventaschannel --name ventas --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

# Configurar las variables de entorno para Farmaceutica
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051

# Aprobar el chaincode para Farmaceutica
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID ventaschannel  --name ventas --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

# Verificar la Disponibilidad para el Commit
peer lifecycle chaincode checkcommitreadiness --channelID ventaschannel --name ventas --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --output json

# Commit del Chaincode en el Canal
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID ventaschannel --name ventas --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt --peerAddresses localhost:2051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt

# Consultar el Chaincode Comprometido
peer lifecycle chaincode querycommitted --channelID ventaschannel --name ventas --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

# Probar el chaincode
# Invocar una Transacción en el Chaincode
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem -C ventaschannel -n ventas --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt --peerAddresses localhost:2051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt -c '{"function":"initLedger","Args":[""]}'

# Consultar el chaincode
peer chaincode query -C ventaschannel -n ventas -c '{"Args":["ReadTransaccion","T1"]}'

# Actualizar una transacción en el chaincode
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem -C ventaschannel -n ventas --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt --peerAddresses localhost:2051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt -c '{"function":"UpdateTransaccion","Args":["T1","23423","600","500"]}'

# Consultar transacción actualizada
peer chaincode query -C ventaschannel -n ventas -c '{"Args":["ReadTransaccion","T1"]}'



--> CHAINCODE DE TRAZABILIDAD

cd ~/curso/chaincodes/farma/trazabilidad/go/
go mod init trazabilidad.go 
go mod vendor

cd ~/curso
export PATH=${PWD}/../fabric-samples/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../fabric-samples/config

peer version
peer lifecycle chaincode package trazabilidad.tar.gz --path chaincodes/farma/trazabilidad/go --lang golang --label trazabilidad_1.0

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode install trazabilidad.tar.gz

peer lifecycle chaincode queryinstalled
//copiar el ID del package, es una combinación del nombre del chaincode y el trazabilidad del contenido del código
export CC_PACKAGE_ID=trazabilidad_1.0:011a2bb8c139dbf8ef3c5de4c07cca5a32210682e52049f36d32e5b080e6ab99
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem


export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="DeliveryMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp
export CORE_PEER_ADDRESS=localhost:2051
peer lifecycle chaincode install trazabilidad.tar.gz
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="LogisticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/logistica.farma.com/users/Admin@logistica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode install trazabilidad.tar.gz
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

peer lifecycle chaincode checkcommitreadiness --channelID farmachannel --name trazabilidad --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --output json

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt --peerAddresses localhost:2051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt

peer lifecycle chaincode querycommitted --channelID farmachannel --name trazabilidad --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

//probar el chaincode
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem -C farmachannel -n trazabilidad --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt -c '{"function":"initLedger","Args":[""]}'
peer chaincode query -C farmachannel -n trazabilidad -c '{"Args":["GetAllFarmacos",""]}'



---> CHAINCODE DE CALIDAD
# Navegar al directorio de los chaincodes de Calidad
cd ~/curso/chaincodes/farma/calidad/go/
go mod init calidad.go
go mod vendor

# Volver al directorio raíz del proyecto
cd ~/curso

# Empaquetar el Chaincode de Calidad
peer lifecycle chaincode package calidad.tar.gz --path chaincodes/farma/calidad/go --lang golang --label calidad_1.0

# Instalar el Chaincode de Calidad en los peers de Farmacéutica y Calidad
# Farmacéutica
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode install calidad.tar.gz

# Calidad
export PEER0_CALIDAD_CA=${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="CalidadMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CALIDAD_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/calidad.farma.com/users/Admin@calidad.farma.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode install calidad.tar.gz

# Consultar el ID del paquete del Chaincode instalado
peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID= //Rellenar

# Aprobar el Chaincode de Calidad para mi organización en el canal de Calidad
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID calidadchannel --name calidad --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem

# Comprobar la disposición del chaincode para ser comprometido
peer lifecycle chaincode checkcommitreadiness --channelID calidadchannel --name calidad --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --output json

# Comprometer el Chaincode de Calidad en el canal
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID calidadchannel --name calidad --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/ca.crt

# Consultar los chaincodes comprometidos en el canal de Calidad
peer lifecycle chaincode querycommitted --channelID calidadchannel --name calidad --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
