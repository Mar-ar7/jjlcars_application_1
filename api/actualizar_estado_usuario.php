<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

require_once 'conexion.php';

// Verificar que se recibió el ID y el estado
if (!isset($_POST['id']) || !isset($_POST['estado'])) {
    http_response_code(400);
    echo json_encode([
        'error' => 'Se requiere ID y estado'
    ]);
    exit;
}

$id = $_POST['id'];
$estado = $_POST['estado'];
$estado_mensaje = isset($_POST['estado_mensaje']) ? $_POST['estado_mensaje'] : null;
$estado_hasta = isset($_POST['estado_hasta']) ? $_POST['estado_hasta'] : null;

try {
    // Preparar la consulta SQL
    $sql = "UPDATE usuarios SET estado = ?, estado_mensaje = ?, estado_hasta = ? WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    
    // Ejecutar la consulta
    $stmt->execute([$estado, $estado_mensaje, $estado_hasta, $id]);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Estado actualizado correctamente'
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'error' => 'No se encontró el usuario o no se realizaron cambios'
        ]);
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Error al actualizar el estado: ' . $e->getMessage()
    ]);
}
?> 