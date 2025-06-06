<?php
header('Content-Type: application/json');
require_once 'conexion.php';

ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/php-error.log');

$response = ['success' => false, 'message' => '', 'data' => []];

try {
    $conn = obtenerConexion();

    // Consulta para contar vehículos por marca
    $sql = "SELECT marca, COUNT(*) as cantidad FROM vehiculos GROUP BY marca";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $marcas = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $marcas[] = [
            'marca' => $row['marca'],
            'cantidad' => (int)$row['cantidad']
        ];
    }

    $response['success'] = true;
    $response['data'] = $marcas;

} catch (Exception $e) {
    $response['message'] = 'Error fetching vehicle statistics: ' . $e->getMessage();
    error_log($response['message']);
}

echo json_encode($response);
exit();
?> 