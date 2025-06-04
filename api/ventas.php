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

$sql = "SELECT id, cliente_nombre, fecha, total FROM ventas ORDER BY fecha DESC";
$result = $conn->query($sql);

$ventas = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $ventas[] = $row;
    }
}

echo json_encode(['success' => true, 'ventas' => $ventas]);

$conn->close();
?>
