<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Usar la función de conexión centralizada si existe
if (file_exists(__DIR__ . '/conexion.php')) {
    require_once __DIR__ . '/conexion.php';
    $conexion = obtenerConexion();
} else {
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
}

try {
    $consulta = $conexion->query('SELECT * FROM vehiculos');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }

    $vehiculos = $consulta->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'vehiculos' => $vehiculos
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
} 