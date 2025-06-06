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

    // Query to get count of citas by status
    $sql_counts = "SELECT status, COUNT(*) as count FROM citas GROUP BY status";
    $stmt_counts = $conn->prepare($sql_counts);
    $stmt_counts->execute();

    $stats = [];
    while ($row = $stmt_counts->fetch(PDO::FETCH_ASSOC)) {
        $stats[$row['status']] = (int)$row['count']; // Ensure count is integer
    }

    // Initialize counts to 0 if a status is not present in the results
    $estados = ['Aprobada', 'Pendiente', 'Cancelada']; // Usa los valores reales de tu base de datos
    foreach ($estados as $estado) {
        if (!isset($stats[$estado])) {
            $stats[$estado] = 0;
        }
    }

    // Query to get total revenue from approved citas
    // *** Asegúrate que exista la columna 'precio' en la tabla 'citas' ***
    $sql_revenue = "SELECT SUM(precio) as totalRevenue FROM citas WHERE status = 'Aprobada'";
    $stmt_revenue = $conn->prepare($sql_revenue);
    $stmt_revenue->execute();

    $revenue_result = $stmt_revenue->fetch(PDO::FETCH_ASSOC);
    $totalRevenue = (float)($revenue_result['totalRevenue'] ?? 0.0); // Ensure revenue is float

    $response['success'] = true;
    $response['data'] = [
        'counts' => $stats,
        'totalRevenue' => $totalRevenue,
    ];

} catch (Exception $e) {
    $response['message'] = 'Error fetching cita statistics: ' . $e->getMessage();
    error_log($response['message']);
}

echo json_encode($response);
exit();
?>