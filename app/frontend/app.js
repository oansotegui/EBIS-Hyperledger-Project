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
    document.getElementById('updateFarmacoForm').addEventListener('submit', handleUpdateFarmaco);
    document.getElementById('deleteFarmacoForm').addEventListener('submit', handleDeleteFarmaco);
    document.getElementById('getAllFarmacosButton').addEventListener('click', handleGetAllFarmacos);
    document.getElementById('getFarmacoHistoryForm').addEventListener('submit', handleGetFarmacoHistory);

});

// Función para formatear respuestas

function formatGenericResponse(data) {
    if (Array.isArray(data)) {
        return `<div class="response-array">${data.map(item => 
            `<div class="array-item">${formatGenericResponse(item)}</div>`
        ).join('')}</div>`;
    } else if (typeof data === 'object' && data !== null) {
        return `<div class="response-object">${Object.entries(data).map(([key, value]) => 
            `<p><strong>${key}:</strong> ${formatGenericResponse(value)}</p>`
        ).join('')}</div>`;
    } else {
        return `<p class="response-primitive">${data}</p>`;
    }
}


// Funciones de manejo para Ventas

async function handleCreateTransaction(e) {
    e.preventDefault();
    const transactionId = document.getElementById('transactionId').value;
    const sap = document.getElementById('sap').value;
    const cantidad = document.getElementById('cantidad').value;
    const precio = document.getElementById('precio').value;
    // Aquí deberías adaptar esta llamada a cómo espera recibir los datos tu API
    const data = { id: transactionId, sap: sap, cantdad: cantidad, precio:precio };

    try {
        const response = await fetch('http://localhost:3000/routes/ventas/createTransaction', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const responseData = await response.json();
        document.getElementById('ventasResponse').innerHTML = `Transacción creada: ${formatGenericResponse(responseData)}`;
    } catch (error) {
        console.error('Error al crear la transacción:', error);
        document.getElementById('ventasResponse').innerHTML = 'Error al crear la transacción';
    }
}

async function handleGetTransaction(e) {
    e.preventDefault();
    const transactionId = document.getElementById('getTransactionId').value;

    if (transactionId) {
        try {
            const response = await fetch(`http://localhost:3000/routes/ventas/getTransaction/${transactionId}`);
            const data = await response.json();
            document.getElementById('ventasResponse').innerHTML = `Transacción consultada: ${formatGenericResponse(data)}`;
        } catch (error) {
            console.error('Error al realizar la petición:', error);
            document.getElementById('ventasResponse').innerHTML = 'Error al leer la transacción';
        }
    } else {
        document.getElementById('ventasResponse').innerHTML = 'Por favor, ingrese un ID de transacción';
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
        document.getElementById('calidadResponse').innerHTML = `Inspección registrada: ${formatGenericResponse(responseData)}`;
    } catch (error) {
        console.error('Error al registrar inspección:', error);
        document.getElementById('calidadResponse').innerHTML = 'Error al registrar inspección';
    }
}

async function handleConsultarInspeccion(e) {
    e.preventDefault();
    const loteID = document.getElementById('inspeccionId').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/calidad/consultarInspeccion/${loteID}`);
        const data = await response.json();
        document.getElementById('calidadResponse').innerHTML = `Inspección consultada: ${formatGenericResponse(data)}`;
    } catch (error) {
        console.error('Error al consultar inspección:', error);
        document.getElementById('calidadResponse').innerHTML = 'Error al consultar inspección';
    }
}



// Funciones de manejo para Trazabilidad

async function handleCreateFarmaco(e) {
    e.preventDefault();
    // Recopila los datos necesarios del formulario
    var formulario = document.getElementById('createFarmacoForm');
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
        document.getElementById('trazabilidadResponse').innerHTML = `${formatGenericResponse(responseData)}`;
        formulario.reset();
    } catch (error) {
        console.error('Error al crear fármaco:', error);
        document.getElementById('trazabilidadResponse').innerHTML = 'Error al crear fármaco';
        formulario.reset();
    }
}

async function handleReadFarmaco(e) {
    e.preventDefault();
    var formulario = document.getElementById('readFarmacoForm');
    const farmacoId = document.getElementById('readFarmacoId').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/trazabilidad/readFarmaco/${farmacoId}`);
        const data = await response.json();
        document.getElementById('trazabilidadResponse').innerHTML = `Lectura de Fármaco: ${formatGenericResponse(data)}`;
    } catch (error) {
        console.error('Error al leer fármaco:', error);
        document.getElementById('trazabilidadResponse').innerHTML = 'Error al leer fármaco';
    }
    formulario.reset();
}

// Función para actualizar un fármaco
async function handleUpdateFarmaco(e) {
    e.preventDefault();
    var formulario = document.getElementById('updateFarmacoForm');
    const farmacoId = document.getElementById('updateFarmacoId').value;
    const ph = document.getElementById('ph').value;
    const temperature = document.getElementById('temperature').value;
    const user = document.getElementById('user').value;
    const geo = document.getElementById('geo').value;
    const estado = document.getElementById('estado').value;
    const extradata = document.getElementById('extradata').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/trazabilidad/updateFarmaco/${farmacoId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ph, temperature, user, geo, estado, extradata })
        });
        const responseData = await response.json();
        document.getElementById('trazabilidadResponse').innerHTML = `Fármaco actualizado: ${formatGenericResponse(responseData)}`;
    } catch (error) {
        console.error('Error al actualizar el fármaco:', error);
        document.getElementById('trazabilidadResponse').innerHTML = 'Error al actualizar el fármaco';
    }
    formulario.reset();
}

// Función para eliminar un fármaco
async function handleDeleteFarmaco(e) {
    e.preventDefault();
    var formulario = document.getElementById('deleteFarmacoForm');
    const farmacoId = document.getElementById('deleteFarmacoId').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/trazabilidad/deleteFarmaco/${farmacoId}`, {
            method: 'DELETE'
        });
        const responseData = await response.json();
        document.getElementById('trazabilidadResponse').innerHTML = `Fármaco eliminado: ${formatGenericResponse(responseData)}`;
    } catch (error) {
        console.error('Error al eliminar el fármaco:', error);
        document.getElementById('trazabilidadResponse').innerHTML = 'Error al eliminar el fármaco';
    }
    formulario.reset();
}

// Función para obtener todos los fármacos
async function handleGetAllFarmacos() {
    try {
        const response = await fetch('http://localhost:3000/routes/trazabilidad/getAllFarmacos');
        const farmacos = await response.json();
        document.getElementById('trazabilidadResponse').innerHTML = `Todos los fármacos: ${formatGenericResponse(farmacos)}`;
    } catch (error) {
        console.error('Error al obtener todos los fármacos:', error);
        document.getElementById('trazabilidadResponse').innerHTML = 'Error al obtener todos los fármacos';
    }
}

// Función para obtener el historial de un fármaco
async function handleGetFarmacoHistory(e) {
    e.preventDefault();
    var formulario = document.getElementById('getFarmacoHistoryForm');
    const farmacoId = document.getElementById('historyFarmacoId').value;

    try {
        const response = await fetch(`http://localhost:3000/routes/trazabilidad/getFarmacoHistory/${farmacoId}`);
        const history = await response.json();
        document.getElementById('trazabilidadResponse').innerHTML = `Historial del fármaco: ${formatGenericResponse(history)}`;
        formulario.reset();
    } catch (error) {
        console.error('Error al obtener el historial del fármaco:', error);
        document.getElementById('trazabilidadResponse').innerHTML = 'Error al obtener el historial del fármaco';
        formulario.reset();
    }

}
