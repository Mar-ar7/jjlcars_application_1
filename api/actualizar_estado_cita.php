<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: PUT, POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'conexion.php';

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id']) || !isset($data['status'])) {
        throw new Exception('ID de cita y status son requeridos');
    }
    
    // Validar que el status sea válido
    $statusValidos = ['Pendiente', 'Aprobada', 'Cancelada'];
    if (!in_array($data['status'], $statusValidos)) {
        throw new Exception('Status no válido');
    }
    
    $conexion = Conexion::conectar();
    
    $sql = "UPDATE citas SET status = ? WHERE id = ?";
    $stmt = $conexion->prepare($sql);
    $stmt->execute([$data['status'], $data['id']]);
    
    if ($stmt->rowCount() === 0) {
        throw new Exception('No se encontró la cita o no hubo cambios');
    }
    
    // Obtener la cita actualizada
    $stmt = $conexion->prepare('SELECT * FROM citas WHERE id = ?');
    $stmt->execute([$data['id']]);
    $cita = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Estado de cita actualizado exitosamente',
        'cita' => $cita
    ]);
    
} catch (Exception $e) {
    error_log("Error en actualizar_estado_cita.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 