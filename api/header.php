<?php
// Configuración CORS
header('Access-Control-Allow-Origin: http://localhost:5500');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

// Manejar preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header('HTTP/1.1 200 OK');
    exit();
}

// Conexión a la base de datos
$host = 'localhost';
$db   = 'jjlcars';
$user = 'root';
$pass = '';
$charset = 'utf8mb4';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $conn->connect_error
    ]));
}

$conn->set_charset($charset);
?> 