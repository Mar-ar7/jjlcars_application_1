<?php
header('Content-Type: application/json');
require_once 'conexion.php';

try {
    $conn = obtenerConexion();
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['id'])) {
        throw new Exception('ID de cita requerido');
    }

    $sql = "DELETE FROM citas WHERE id = :id";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':id' => $data['id']]);

    echo json_encode(['success' => true, 'message' => 'Cita eliminada correctamente']);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>