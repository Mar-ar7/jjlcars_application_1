<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'conexion.php';

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (empty($data['id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'ID de cita requerido']);
    exit;
}

try {
    $conn = obtenerConexion();
    $sql = "UPDATE citas SET tipoCita = :tipoCita, tipoCompra = :tipoCompra, precio = :precio, nombre = :nombre, correo = :correo, fecha = :fecha, hora = :hora, status = :status, vehiculo_id = :vehiculo_id WHERE id = :id";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':tipoCita' => $data['tipoCita'],
        ':tipoCompra' => $data['tipoCompra'],
        ':precio' => $data['precio'],
        ':nombre' => $data['nombre'],
        ':correo' => $data['correo'],
        ':fecha' => $data['fecha'],
        ':hora' => $data['hora'],
        ':status' => $data['status'],
        ':vehiculo_id' => $data['vehiculo_id'],
        ':id' => $data['id']
    ]);
    echo json_encode(['success' => true, 'message' => 'Cita actualizada correctamente']);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>