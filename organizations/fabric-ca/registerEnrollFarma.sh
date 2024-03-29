#!/bin/bash

function createFarmaceutica() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/farmaceutica.farma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-farmaceutica --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmaceutica.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmaceutica.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmaceutica.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-farmaceutica.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-farmaceutica --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-farmaceutica --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-farmaceutica --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-farmaceutica --id.name farmaceuticaadmin --id.secret farmaceuticaadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-farmaceutica -M "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/msp" --csr.hosts peer0.farmaceutica.farma.com --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-farmaceutica -M "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls" --enrollment.profile tls --csr.hosts peer0.farmaceutica.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/tlsca/tlsca.farmaceutica.farma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/ca"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer0.farmaceutica.farma.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/ca/ca.farmaceutica.farma.com-cert.pem"


  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-farmaceutica -M "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/msp" --csr.hosts peer1.farmaceutica.farma.com --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-farmaceutica -M "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls" --enrollment.profile tls --csr.hosts peer1.farmaceutica.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/tlsca/tlsca.farmaceutica.farma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/ca"
  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/peers/peer1.farmaceutica.farma.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/ca/ca.farmaceutica.farma.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-farmaceutica -M "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/User1@farmaceutica.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/User1@farmaceutica.farma.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://farmaceuticaadmin:farmaceuticaadminpw@localhost:7054 --caname ca-farmaceutica -M "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/farmaceutica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/farmaceutica.farma.com/users/Admin@farmaceutica.farma.com/msp/config.yaml"
}

function createLogistica() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/logistica.farma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/logistica.farma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-logistica --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistica.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistica.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistica.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-logistica.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/logistica.farma.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-logistica --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-logistica --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-logistica --id.name logisticaadmin --id.secret logisticaadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-logistica -M "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/msp" --csr.hosts peer0.logistica.farma.com --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-logistica -M "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls" --enrollment.profile tls --csr.hosts peer0.logistica.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/logistica.farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/logistica.farma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/logistica.farma.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/logistica.farma.com/tlsca/tlsca.logistica.farma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/logistica.farma.com/ca"
  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/peers/peer0.logistica.farma.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/logistica.farma.com/ca/ca.logistica.farma.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-logistica -M "${PWD}/organizations/peerOrganizations/logistica.farma.com/users/User1@logistica.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/logistica.farma.com/users/User1@logistica.farma.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://logisticaadmin:logisticaadminpw@localhost:8054 --caname ca-logistica -M "${PWD}/organizations/peerOrganizations/logistica.farma.com/users/Admin@logistica.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/logistica/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logistica.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/logistica.farma.com/users/Admin@logistica.farma.com/msp/config.yaml"
}

function createDelivery() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/delivery.farma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/delivery.farma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-delivery --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-delivery.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-delivery.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-delivery.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-delivery.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/delivery.farma.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-delivery --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-delivery --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-delivery --id.name deliveryadmin --id.secret deliveryadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-delivery -M "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/msp" --csr.hosts peer0.delivery.farma.com --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-delivery -M "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls" --enrollment.profile tls --csr.hosts peer0.delivery.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/delivery.farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/delivery.farma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/delivery.farma.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/delivery.farma.com/tlsca/tlsca.delivery.farma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/delivery.farma.com/ca"
  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/peers/peer0.delivery.farma.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/delivery.farma.com/ca/ca.delivery.farma.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-delivery -M "${PWD}/organizations/peerOrganizations/delivery.farma.com/users/User1@delivery.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/delivery.farma.com/users/User1@delivery.farma.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://deliveryadmin:deliveryadminpw@localhost:10054 --caname ca-delivery -M "${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/delivery/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/delivery.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/delivery.farma.com/users/Admin@delivery.farma.com/msp/config.yaml"
}

function createCalidad() {
  infoln "Enrolling the CA admin for Calidad"
  mkdir -p organizations/peerOrganizations/calidad.farma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/calidad.farma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-calidad --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-calidad.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-calidad.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-calidad.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-calidad.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/calidad.farma.com/msp/config.yaml"

  infoln "Registering peer0 for Calidad"
  set -x
  fabric-ca-client register --caname ca-calidad --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user for Calidad"
  set -x
  fabric-ca-client register --caname ca-calidad --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin for Calidad"
  set -x
  fabric-ca-client register --caname ca-calidad --id.name calidadadmin --id.secret calidadadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp for Calidad"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-calidad -M "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/msp" --csr.hosts peer0.calidad.farma.com --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates for Calidad"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-calidad -M "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls" --enrollment.profile tls --csr.hosts peer0.calidad.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/calidad.farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/calidad.farma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/calidad.farma.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/calidad.farma.com/tlsca/tlsca.calidad.farma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/calidad.farma.com/ca"
  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/peers/peer0.calidad.farma.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/calidad.farma.com/ca/ca.calidad.farma.com-cert.pem"

  infoln "Generating the user msp for Calidad"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-calidad -M "${PWD}/organizations/peerOrganizations/calidad.farma.com/users/User1@calidad.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/calidad.farma.com/users/User1@calidad.farma.com/msp/config.yaml"

  infoln "Generating the org admin msp for Calidad"
  set -x
  fabric-ca-client enroll -u https://calidadadmin:calidadadminpw@localhost:11054 --caname ca-calidad -M "${PWD}/organizations/peerOrganizations/calidad.farma.com/users/Admin@calidad.farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/calidad/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/calidad.farma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/calidad.farma.com/users/Admin@calidad.farma.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/farma.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/farma.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/farma.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp" --csr.hosts orderer.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/farma.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls" --enrollment.profile tls --csr.hosts orderer.farma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/farma.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/farma.com/orderers/orderer.farma.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/farma.com/msp/tlscacerts/tlsca.farma.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/farma.com/users/Admin@farma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/farma.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/farma.com/users/Admin@farma.com/msp/config.yaml"
}


