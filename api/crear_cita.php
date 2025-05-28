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
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['nombre']) || !isset($data['correo']) || !isset($data['fecha']) || !isset($data['hora'])) {
        throw new Exception('Faltan datos requeridos');
    }
    
    $sql = "INSERT INTO citas (tipoCita, tipoCompra, precio, nombre, correo, fecha, hora, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'Pendiente')";
    $params = [
        $data['tipoCita'] ?? '',
        $data['tipoCompra'] ?? '',
        $data['precio'] ?? 0,
        $data['nombre'],
        $data['correo'],
        $data['fecha'],
        $data['hora']
    ];
    
    $nuevoId = Database::insert($sql, $params);
    
    // Obtener la cita recién creada
    $sql = "SELECT * FROM citas WHERE id = ?";
    $cita = Database::fetchOne($sql, [$nuevoId]);
    
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