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


## Configuración y Despliegue
Instrucciones paso a paso para configurar y desplegar la red de Hyperledger Fabric.

1. **Crear Archivos de Configuración**
   Detalles sobre la creación y estructura de los archivos de configuración necesarios.

2. **Gestión de Contenedores Docker**
   Comandos para detener, eliminar y preparar el entorno Docker para el proyecto.

3. **Levantar Servicios con Docker Compose**
   Instrucciones para levantar los servicios de CA y demás servicios utilizando Docker Compose.

4. **Establecer Variables de Entorno y Generar Bloques de Génesis**
   Guía sobre cómo establecer las variables de entorno necesarias y generar los bloques de génesis para los diferentes canales.

5. **Registrar y Enrolar Organizaciones**
   Procedimientos para registrar y enrolar las diferentes organizaciones en la red utilizando scripts.

6. **Unir Peers a Canales y Configurar Anchor Peers**
   Instrucciones para unir los peers a los canales correspondientes y configurar los anchor peers.

### Desarrollo y Despliegue de Chaincodes
#### Desarrollar los Chaincodes
Explicación sobre cómo desarrollar los chaincodes específicos para ventas, trazabilidad y calidad, incluyendo la estructura de directorios y archivos.

#### Empaquetar, Instalar y Comprometer Chaincodes
Instrucciones detalladas para empaquetar, instalar y comprometer los chaincodes en la red, asegurando su correcta ejecución.

#### Probar los Chaincodes
Guía para realizar pruebas de invocación y consulta de los chaincodes para verificar su correcto funcionamiento.

### Mantenimiento y Monitoreo
Consejos sobre cómo mantener y monitorear la red una vez esté en funcionamiento.

### Solución de Problemas
Sección de preguntas frecuentes o problemas comunes y sus soluciones.

### Contribuir
Instrucciones para aquellos interesados en contribuir al proyecto.

### Licencia
Detalles sobre la licencia del proyecto.

### Contacto
Información de contacto para soporte o colaboraciones.

