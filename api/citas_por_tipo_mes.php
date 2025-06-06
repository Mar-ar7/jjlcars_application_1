<?php
header('Content-Type: application/json');
require_once 'conexion.php';

ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/php-error.log');

$response = ['success' => false, 'message' => '', 'data' => []];

try {
    $conn = obtenerConexion();

    // Consulta para agrupar por mes y tipo de compra, sumando el precio
    $sql = "SELECT DATE_FORMAT(fecha, '%Y-%m') as mes, tipoCompra, SUM(precio) as total
            FROM citas
            GROUP BY mes, tipoCompra
            ORDER BY mes ASC";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $data = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $mes = $row['mes'];
        $tipo = $row['tipoCompra'];
        $total = (float)$row['total'];
        if (!isset($data[$mes])) {
            $data[$mes] = [];
        }
        $data[$mes][$tipo] = $total;
    }

    $response['success'] = true;
    $response['data'] = $data;

} catch (Exception $e) {
    $response['message'] = 'Error al obtener proyección de ventas: ' . $e->getMessage();
    error_log($response['message']);
}

echo json_encode($response);
exit(); 