<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['nombre']) || !isset($data['correo'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Nombre y correo son requeridos']);
        exit;
    }

    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    $sql = "INSERT INTO clientes (nombre, correo, telefono, direccion, estado) 
            VALUES (:nombre, :correo, :telefono, :direccion, :estado)";

    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        ':nombre' => $data['nombre'],
        ':correo' => $data['correo'],
        ':telefono' => $data['telefono'],
        ':direccion' => $data['direccion'],
        ':estado' => $data['estado'] ?? 'Activo'
    ]);

    $id = $conexion->lastInsertId();
    $stmt = $conexion->prepare("SELECT * FROM clientes WHERE id = ?");
    $stmt->execute([$id]);
    $cliente = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
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