<?php
header('Content-Type: application/json');

require_once 'conexion.php';

// Disable display_errors and enable error_log for production
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/php-error.log');

$response = ['success' => false, 'message' => '', 'data' => []];

try {
    // Check if the database connection is established
    $conn = obtenerConexion();

    // Consulta para contar el total de clientes
    $sql = "SELECT COUNT(*) as totalClientes FROM clientes";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    $response['success'] = true;
    $response['data'] = [
        'totalClientes' => (int)($result['totalClientes'] ?? 0)
    ];

} catch (Exception $e) {
    $response['message'] = 'Error fetching client statistics: ' . $e->getMessage();
    error_log($response['message']);
}

echo json_encode($response);
exit();
?> 