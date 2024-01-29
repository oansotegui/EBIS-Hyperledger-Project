document.addEventListener('DOMContentLoaded', function() {
    const sections = document.querySelectorAll('.content-section');
    const navLinks = document.querySelectorAll('#navBar a');

    // Función para cambiar la sección activa
    function changeActiveSection(sectionId) {
        sections.forEach(section => {
            section.style.display = section.id === sectionId ? 'block' : 'none';
        });
    }

    // Event listeners para los enlaces de navegación
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            const sectionId = this.getAttribute('data-section');
            changeActiveSection(sectionId);
        });
    });

    // Mostrar Trazabilidad por defecto
    changeActiveSection('trazabilidad');
});


document.addEventListener('DOMContentLoaded', function() {

    // Ventas
    document.getElementById('createTransactionForm').addEventListener('submit', handleCreateTransaction);
    document.getElementById('getTransactionForm').addEventListener('submit', handleGetTransaction);

    // Calidad
    document.getElementById('registrarInspeccionForm').addEventListener('submit', handleRegistrarInspeccion);
    document.getElementById('consultarInspeccionForm').addEventListener('submit', handleConsultarInspeccion);

    // Trazabilidad
    document.getElementById('createFarmacoForm').addEventListener('submit', handleCreateFarmaco);
    document.getElementById('readFarmacoForm').addEventListener('submit', handleReadFarmaco);

});


// Funciones de manejo para Ventas

async function handleCreateTransaction(e) {
    e.preventDefault();
    const transactionId = document.getElementById('createTransactionId').value;
    const transactionData = document.getElementById('transactionData').value;
    // Aquí deberías adaptar esta llamada a cómo espera recibir los datos tu API
    const data = { id: transactionId, data: transactionData };

    try {
        const response = await fetch('http://localhost:3000/routes/ventas/createTransaction', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const responseData = await response.json();
        document.getElementById('ventasResponse').textContent = `Transacción creada: ${JSON.stringify(responseData)}`;
    } catch (error) {
        console.error('Error al crear la transacción:', error);
        document.getElementById('ventasResponse').textContent = 'Error al crear la transacción';
    }
}

async function handleGetTransaction(e) {
    e.preventDefault();
    const transactionId = document.getElementById('getTransactionId').value;

    if (transactionId) {
        try {
            const response = await fetch(`http://localhost:3000/routes/ventas/getTransaction/${transactionId}`);
            const data = await response.json();
            document.getElementById('ventasResponse').textContent = JSON.stringify(data, null, 2);
        } catch (error) {
            console.error('Error al realizar la petición:', error);
            document.getElementById('ventasResponse').textContent = 'Error al leer la transacción';
        }
    } else {
        document.getElementById('ventasResponse').textContent = 'Por favor, ingrese un ID de transacción';
    }
}



// Funciones de manejo para Calidad

async function handleRegistrarInspeccion(e) {
    e.preventDefault();
    // Recopila los datos necesarios del formulario
    const loteID = document.getElementById('loteID').value;
    const fechaInspeccion = document.getElementById('fechaInspeccion').value;
    const resultado = document.getElementById('resultado').value;
    const comentarios = document.getElementById('comentarios').value;
    const inspector = document.getElementById('inspector').value;

    try {
        const response = await fetch('http://localhost:3000/routes/calidad/registrarInspeccion', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ loteID, fechaInspeccion, resultado, comentarios, inspector })
        });
        const responseData = await response.json();
        document.getElementById('calidadResponse').textContent = `Inspección registrada: ${JSON.stringify(responseData)}`;
    } catch (error) {
        console.error('Error al registrar inspección:', error);
        document.getElementById('calidadResponse').textContent = 'Error al registrar inspección';
    }
}

async function handleConsultarInspeccion(e) {
    e.preventDefault();
    const loteID = document.getElementById('consultarLoteID').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/calidad/consultarInspeccion/${loteID}`);
        const data = await response.json();
        document.getElementById('calidadResponse').textContent = JSON.stringify(data, null, 2);
    } catch (error) {
        console.error('Error al consultar inspección:', error);
        document.getElementById('calidadResponse').textContent = 'Error al consultar inspección';
    }
}



// Funciones de manejo para Trazabilidad

async function handleCreateFarmaco(e) {
    e.preventDefault();
    // Recopila los datos necesarios del formulario
    const ph = document.getElementById('ph').value;
    const temperature = document.getElementById('temperature').value;
    const user = document.getElementById('user').value;
    const geo = document.getElementById('geo').value;
    const estado = document.getElementById('estado').value;
    const extradata = document.getElementById('extradata').value;

    try {
        const response = await fetch('http://localhost:3000/routes/trazabilidad/createFarmaco', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ph, temperature, user, geo, estado, extradata })
        });
        const responseData = await response.json();
        document.getElementById('trazabilidadResponse').textContent = `Fármaco creado: ${JSON.stringify(responseData)}`;
    } catch (error) {
        console.error('Error al crear fármaco:', error);
        document.getElementById('trazabilidadResponse').textContent = 'Error al crear fármaco';
    }
}

async function handleReadFarmaco(e) {
    e.preventDefault();
    const farmacoId = document.getElementById('readFarmacoId').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/trazabilidad/readFarmaco/${farmacoId}`);
        const data = await response.json();
        document.getElementById('trazabilidadResponse').textContent = JSON.stringify(data, null, 2);
    } catch (error) {
        console.error('Error al leer fármaco:', error);
        document.getElementById('trazabilidadResponse').textContent = 'Error al leer fármaco';
    }
}
