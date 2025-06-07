<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!isset($data['id']) || empty($data['nombre']) || empty($data['correo'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'ID, nombre y correo son requeridos']);
        exit;
    }

    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    $sql = "UPDATE clientes SET nombre = :nombre, correo = :correo WHERE id = :id";

    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        ':id' => $data['id'],
        ':nombre' => $data['nombre'],
        ':correo' => $data['correo']
    ]);

    $stmt = $conexion->prepare("SELECT * FROM clientes WHERE id = ?");
    $stmt->execute([$data['id']]);
    $cliente = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($cliente) {
        $cliente['id'] = isset($cliente['id']) ? (string)$cliente['id'] : '';
        $cliente['nombre'] = $cliente['nombre'] ?? '';
        $cliente['correo'] = $cliente['correo'] ?? '';
        $cliente['mensaje'] = $cliente['mensaje'] ?? '';
    }

    echo json_encode([
        'success' => true,
        'mensaje' => 'Cliente actualizado correctamente',
        'cliente' => $cliente
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>