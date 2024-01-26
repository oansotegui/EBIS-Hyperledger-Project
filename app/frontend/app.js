function readTransaccion() {
    const id = document.getElementById('readTransaccionId').value;
    if (id) {
        fetch(`http://localhost:3000/api/transaccion/${id}`)
            .then(response => response.json())
            .then(data => {
                document.getElementById('readResult').textContent = JSON.stringify(data, null, 2);
            })
            .catch(error => {
                console.error('Error al realizar la petición:', error);
                document.getElementById('readResult').textContent = 'Error al leer la transacción';
            });
    } else {
        document.getElementById('readResult').textContent = 'Por favor, ingrese un ID de transacción';
    }
}
