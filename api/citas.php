<?php
header('Content-Type: application/json');
require_once 'conexion.php'; // Asegúrate que la ruta sea correcta

try {
    $conn = obtenerConexion();

    $sql = "SELECT id, tipoCita, tipoCompra, precio, nombre, correo, fecha, hora, status FROM citas ORDER BY fecha DESC";

    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $citas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($citas);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Error en la consulta: ' . $e->getMessage()
    ]);
}
?>
