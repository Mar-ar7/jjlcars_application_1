<?php
header('Content-Type: application/json');

$host = 'localhost';
$dbname = 'jjlcars';
$user = 'root';
$pass = ''; // Pon tu contraseña si la tienes

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    echo json_encode(['success' => false, 'error' => 'Conexión fallida']);
    exit;
}

$sql = "SELECT id, nombre, correo FROM clientes";
$result = $conn->query($sql);

$clientes = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $clientes[] = $row;
    }
}

echo json_encode(['success' => true, 'clientes' => $clientes]);

$conn->close();
?>
