<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'config/database.php';

try {
    $conn = Database::obtenerConexion();
    $data = json_decode(file_get_contents('php://input'), true);

    // Valida los campos requeridos
    if (
        empty($data['tipoCita']) || empty($data['tipoCompra']) ||
        empty($data['precio']) || empty($data['nombre']) ||
        empty($data['correo']) || empty($data['fecha']) || empty($data['hora'])
    ) {
        throw new Exception('Faltan datos obligatorios');
    }

    $sql = "INSERT INTO citas (tipoCita, tipoCompra, precio, nombre, correo, fecha, hora, status, vehiculo_id)
            VALUES (:tipoCita, :tipoCompra, :precio, :nombre, :correo, :fecha, :hora, :status, :vehiculo_id)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':tipoCita' => $data['tipoCita'],
        ':tipoCompra' => $data['tipoCompra'],
        ':precio' => $data['precio'],
        ':nombre' => $data['nombre'],
        ':correo' => $data['correo'],
        ':fecha' => $data['fecha'],
        ':hora' => $data['hora'],
        ':status' => $data['status'] ?? 'Pendiente',
        ':vehiculo_id' => $data['vehiculo_id'] ?? 0
    ]);

    // Obtener la cita recién creada
    $sql = "SELECT * FROM citas WHERE id = ?";
    $cita = Database::fetchOne($sql, [$conn->lastInsertId()]);
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Cita creada exitosamente',
        'cita' => $cita
    ]);
    
} catch (Exception $e) {
    error_log("Error en crear_cita.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 