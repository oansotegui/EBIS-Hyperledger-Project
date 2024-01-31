# EBIS-Hyperledger-Project: Proyecto de Trazabilidad de Medicamentos en una Supply Chain Farmacéutica

## Introducción
Este proyecto utiliza la tecnología de Hyperledger Fabric para crear un sistema de trazabilidad de medicamentos dentro de una cadena de suministro farmacéutica. Su objetivo es aumentar la transparencia y eficiencia en el seguimiento de los medicamentos desde su producción hasta la entrega al consumidor final, asegurando la autenticidad y la calidad del producto. De esta manera se consigue: 
* Seguimiento de los productos en toda la cadena
* Verificación y autenticación de los productos de la cadena
* Compartir la información de toda la cadena entre los agentes de la cadena de suministro 
* Mejorar la auditabilidad

## Requisitos Previos
Para implementar este proyecto se requiere:
* Docker y Docker Compose.
* Conocimientos de Hyperledger Fabric.
* Go para el desarrollo de chaincodes
* Familiaridad con el desarrollo de aplicaciones con Node.js (APIS y aplicaciones web).

## Arquitectura del Proyecto
La siguiente imagen muestra cómo estará organizada la red, incluyendo los nodos, organizaciones y roles dentro de la red de Hyperledger Fabric.

![image](https://github.com/oansotegui/EBIS-Hyperledger-Project/assets/93701150/d6fbe348-7c2a-4459-8625-fb92d80c10a2)

La arquitectura de este proyecto se compone de:

1. Organizaciones y sus CAs:
Cuatro organizaciones: Farmacéutica, Calidad, Logística y Delivery.
Cada organización tendría su propia Autoridad de Certificación (CA).
Las CAs estarían conectadas a sus respectivos peers.

2. Peers:
La distribución de peers de las organizaciones es la siguiente: 
* Farmacéutica tiene dos peers (peer0 y peer1, siendo peer0 el anchor peer).
* Calidad, Logística y Delivery tienen un peer cada uno (peer0).

4. Canales:
Tres canales: farmachannel, ventaschannel y calidadchannel.
* Peer0 y peer1 de Farmacéutica se unen a los tres canales.
* Peer0 de Logística y Delivery se unen a farmachannel y ventaschannel.
* Peer0 de Calidad se une solo a calidadchannel.

5. Chaincodes
* trazabilidad.go (en farmachannel)
* ventas.go (en ventaschannel)
* calidad.go (en calidadchannel)

6. Orderer:
Un nodo orderer estaría presente para el consenso y la formación de bloques.
Este nodo estaría conectado a todos los canales.

8. APIs
Conexión del frontend con la red de Hyperledger Fabric.
Las transacciones se ejecutan con las credenciales y certificados del Admin de la organización Farmacéutica.

9. Frontend
Interfaz de usuario para operar con la red de Hyperledger Fabric. En concreto está pensado como panel de control de la organización Farmacéutica.

## Especificación de los Chaincodes

#### Trazabilidad.go
* CreateFarmaco: Crea un nuevo registro de fármaco en el ledger con atributos únicos y lo identifica con un UUID generado.
* ReadFarmaco: Recupera los detalles de un fármaco específico del ledger usando su ID.
* UpdateFarmaco: Actualiza los atributos de un fármaco existente en el ledger.
* DeleteFarmaco: Elimina un fármaco del ledger basado en su ID.
* GetAllFarmacos: Devuelve una lista de todos los fármacos registrados en el ledger.
* GetFarmacoHistory: Proporciona el historial de transacciones para un fármaco específico, mostrando cómo han cambiado sus atributos a lo largo del tiempo.

#### Ventas.go
* CreateTransaccion: Registra una nueva transacción de venta en el ledger.
* ReadTransaccion: Obtiene los detalles de una transacción de venta específica del ledger.
* TransaccionExists: Comprueba si una transacción de venta específica existe en el ledger.
* GetAllTransaccions: Recupera todas las transacciones de venta del ledger.

#### Calidad.go
* RegistrarInspeccion: Agrega una nueva inspección de calidad al ledger con detalles como la fecha de inspección, el resultado, comentarios y el ID del inspector.
* ConsultarInspeccion: Obtiene los detalles de una inspección de calidad para un lote específico de fármacos.


## Configuración y Despliegue de la red
Las siguientes instrucciones y comandos muestran paso a paso como configurar y desplegar la red de Hyperledger Fabric.

1. **Clonar el repositorio y navegar al directorio del proyecto**
```bash
git clone https://github.com/oansotegui/EBIS-Hyperledger-Project.git
cd ~/EBIS-Hyperledger-Project
```

2. **Limpiar el entorno de Contenedores Docker anteriores**
```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
docker volume prune -f
docker network prune -f
```

3. **Eliminar directorios antiguos de configuraciones y crear nuevos.**
```bash
sudo rm -rf organizations/fabric-ca/farmaceutica/
sudo rm -rf organizations/fabric-ca/calidad/ 
sudo rm -rf organizations/fabric-ca/logistica/
sudo rm -rf organizations/fabric-ca/delivery/
sudo rm -rf organizations/fabric-ca/ordererOrg/
sudo rm -rf organizations/peerOrganizations
sudo rm -rf organizations/ordererOrganizations
sudo rm -rf channel-artifacts/
mkdir channel-artifacts
```

4. **Levantar los servicios definidos en el Docker Compose para la CA.**
```bash
docker-compose -f docker/docker-compose-farma-ca.yaml up -d
```

5. **Establecer las variables de entorno necesarias para los binarios de Fabric**
```bash
export PATH=${PWD}/fabric-samples/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
```

6. **Registrar y enrolar a las organizaciones**
```bash
. ./organizations/fabric-ca/registerEnrollFarma.sh && createFarmaceutica
. ./organizations/fabric-ca/registerEnrollFarma.sh && createCalidad
. ./organizations/fabric-ca/registerEnrollFarma.sh && createLogistica
. ./organizations/fabric-ca/registerEnrollFarma.sh && createDelivery
. ./organizations/fabric-ca/registerEnrollFarma.sh && createOrderer
```
7. **Copiar el archivo de configuración y generar bloques de génesis para canales.**
```bash
cp configtx/configtxFarma.yaml configtx/configtx.yaml  
configtxgen -profile FarmaApplicationGenesis -outputBlock ./channel-artifacts/farmachannel.block -channelID farmachannel
configtxgen -profile VentasGenesis -outputBlock ./channel-artifacts/ventaschannel.block -channelID ventaschannel
configtxgen -profile CalidadGenesis -outputBlock ./channel-artifacts/calidadchannel.block -channelID calidadchannel
export FABRIC_CFG_PATH=${PWD}/fabric-samples/config
```  
8. **Configurar el acceso a los certificados del ordenador.**
```bash
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/server.key
```

9. **Levantar los peers y servicios adicionales definidos en el segundo Docker Compose.**
```bash
docker-compose -f docker/docker-compose-farma.yaml  up -d
```

10. **Unir los ordenadores a los canales utilizando la herramienta osnadmin.**
```bash
osnadmin channel join --channelID farmachannel --config-block ./channel-artifacts/farmachannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel join --channelID ventaschannel --config-block ./channel-artifacts/ventaschannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel join --channelID calidadchannel --config-block ./channel-artifacts/calidadchannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
```

11. **Configurar TLS y variables de entorno para peer de Farmacéutica y unirse a los canales.**
```bash
export CORE_PEER_TLS_ENABLED=true
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

```bash
peer channel join -b ./channel-artifacts/farmachannel.block
peer channel join -b ./channel-artifacts/ventaschannel.block
peer channel join -b ./channel-artifacts/calidadchannel.block
```

12.  **Unir el peer1 de Farmacéutica a los canales.**
```bash
export PEER1_EMPRESA_CA=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_EMPRESA_CA
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_ADDRESS=localhost:3051
```

```bash
peer channel join -b ./channel-artifacts/farmachannel.block
peer channel join -b ./channel-artifacts/ventaschannel.block
peer channel join -b ./channel-artifacts/calidadchannel.block
```

 13. **Establecer el peer0 de Farmacéutica como Anchor Peer.**
```bash
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

```bash
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com -c farmachannel --tls --cafile "$ORDERER_CA"
```

14. **Unir Logística, Delivery y Calidad a sus respectivos canales.**
```bash
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="LogisticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/logistica.farma.com/users/Admin@logistica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

```bash
peer channel join -b ./channel-artifacts/farmachannel.block
```

```bash
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="DeliveryMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp
export CORE_PEER_ADDRESS=localhost:2051
```

```bash
peer channel join -b ./channel-artifacts/farmachannel.block
peer channel join -b ./channel-artifacts/ventaschannel.block
```

```bash
export PEER0_CALIDAD_CA=${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="CalidadMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CALIDAD_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/calidad.farma.com/users/Admin@calidad.farma.com/msp
export CORE_PEER_ADDRESS=localhost:11051
```

```bash
peer channel join -b ./channel-artifacts/calidadchannel.block
```

## Despliegue de Chaincodes
Ponemos el ejemplo del chaincode de Trazabilidad. Se debe repetir los pasos con los chaincodes de Ventas y Calidad.Están todas las instrucciones y comandos en el fichero **script.txt**
### CHAINCODE DE TRAZABILIDAD
1. **Navegar al directorio del chaincode e iniciar el módulo**
```bash
cd chaincode/trazabilidad/
go mod init trazabilidad
go mod tidy
go mod vendor
```
2. **Configurar el entorno**
```bash
cd ../..
export PATH=${PWD}/../fabric-samples/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../fabric-samples/config
```
3. **Empaqeutar el chaincode**
```bash
peer version
peer lifecycle chaincode package trazabilidad.tar.gz --path ./chaincode/trazabilidad --lang golang --label trazabilidad_1.0
```

4. **Configurar Variables para la Organización Farmaceutica**
```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="FarmaceuticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

5. **Instalar el Chaincode en el Peer de Farmaceutica**
```bash
peer lifecycle chaincode install trazabilidad.tar.gz
```

6. **Exportar el ID del Chaincode Instalado**
```bash
peer lifecycle chaincode queryinstalled
```

//copiar el ID del package, es una combinación del nombre del chaincode y el trazabilidad del contenido del código, tipo: trazabilidad_1.0:7fdf764d2a7c490eae64202f68294a6091ce7f87029b3d1df8cfa4ce689f189d 

```bash
export CC_PACKAGE_ID=<SUSTITUIR AQUI>
```

7. **Aprobar el Chaincode en el Peer de Farmaceutica**
```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
```

8. **Configurar Variables para la Organización Delivery**
```bash
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="DeliveryMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp
export CORE_PEER_ADDRESS=localhost:2051
```

9. **Instalar el Chaincode en el Peer de Delivery**
```bash
peer lifecycle chaincode install trazabilidad.tar.gz
```

10. **Aprobar el Chaincode en el Peer de Delivery**
```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
```

11. **Configurar Variables para la Organización Logistica**
```bash
export PEER0_EMPRESA_CA=${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="LogisticaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPRESA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/logistica.farma.com/users/Admin@logistica.farma.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

12. **Instalar el Chaincode en el Peer de Logistica**
```bash
peer lifecycle chaincode install trazabilidad.tar.gz
```

13. **Aprobar el Chaincode en el Peer de Logistica**
```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
```

14. **Verificar la Disponibilidad para el Commit**
```bash
peer lifecycle chaincode checkcommitreadiness --channelID farmachannel --name trazabilidad --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --output json
```

15. **Commit del Chaincode en el Canal**
```bash
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --channelID farmachannel --name trazabilidad --signature-policy "OR('FarmaceuticaMSP.member','DeliveryMSP.member','LogisticaMSP.member')" --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt --peerAddresses localhost:2051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt
```

16. **Consultar el Chaincode Comprometido**
```bash
peer lifecycle chaincode querycommitted --channelID farmachannel --name trazabilidad --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem
```

17. **Probar el Chaincode**
```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.farma.com --tls --cafile ${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem -C farmachannel -n trazabilidad --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt -c '{"function":"initLedger","Args":[""]}'
peer chaincode query -C farmachannel -n trazabilidad -c '{"Args":["GetAllFarmacos",""]}'
```

## Monitoreo
Se levanta un dashboard de Hyperledger Explorer para monitorear la red una vez esté en funcionamiento.
1. **Copiar la carpeta /organizations al directorio del explorer**
```bash
cd explorer
cp -r ../organizations .
```
2. **Arrancar los servicios y contenedores**
```bash
docker-compose up -d
```
3. **Acceder al dashboard del Explorer**

Se habrá levantado correctamente el servicio en [http://localhost:8080](http://localhost:8080)

4. **Autenticarse**

Por defecto al levantar el docker-compose se establece:
* User: exploreradmin
* Password: exploreradminpw
Puedes modificar el docker-compose si deseas cambiar los datos de autenticación.


## Despliegue de Frontend y APIs**
1. **Navegar al directorio
```bash
cd app/api
```
2. **Instalar dependencias y preparar entorno**
```bash
npm install
```
3. **Recopilar Credenciales de Acceso**
Para operar desde el frontend es necesario firmar las transacciones con las credenciales de alguno de los usuarios registrados y enrolados en la red. Como antes hemos creado usuarios Admin y User1 para cada una de las organizaciones, y dado que este es el frontend de Farmacéutica, vamos a usar las credenciales del Admin de Farmacéutica.
Para ello añadimos las credenciales al directorio /wallet mediante el siguiente script:

```bash
node addToWallet.js
```

4. **Arrancar el servidor**
Se ha configurado para que se monte el frontend sobre la API, por lo que basta con ejecutar el siguiente comando:
```bash
node server.js
```
5. **Accede al frontend**

Se habrá levantado correctamente el servicio en [http://localhost:3000](http://localhost:3000)

## Licencia
Licencia MIT [Detalles sobre la licencia del proyecto.](https://choosealicense.com/licenses/mit/)


## Contacto
Github user: @oansotegui
mail: oscaransotegui@gmail.com

