<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Add logging
error_log("Iniciando obtener_clientes.php");

try {
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    error_log("Conexión establecida");

    // Verify table exists
    $checkTable = $conexion->query("SHOW TABLES LIKE 'clientes'");
    if ($checkTable->rowCount() == 0) {
        throw new Exception('La tabla clientes no existe');
    }

    $consulta = $conexion->query('SELECT * FROM clientes');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }

    $clientes = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Log results
    error_log("Clientes encontrados: " . count($clientes));
    error_log("Datos: " . json_encode($clientes));

    // Ensure all required fields are present
    foreach ($clientes as &$cliente) {
        $cliente['id'] = isset($cliente['id']) ? (string)$cliente['id'] : '';
        $cliente['nombre'] = $cliente['nombre'] ?? '';
        $cliente['correo'] = $cliente['correo'] ?? '';
    }

    $response = [
        'success' => true,
        'clientes' => $clientes
    ];

    echo json_encode($response, JSON_PRETTY_PRINT);
    error_log("Respuesta enviada exitosamente");

} catch (Exception $e) {
    error_log("Error en obtener_clientes.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>