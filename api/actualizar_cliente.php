<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!isset($data['id'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'ID de cliente requerido']);
        exit;
    }

    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    $sql = "UPDATE clientes SET 
            nombre = :nombre,
            correo = :correo,
            telefono = :telefono,
            direccion = :direccion,
            estado = :estado
            WHERE id = :id";

    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        ':id' => $data['id'],
        ':nombre' => $data['nombre'],
        ':correo' => $data['correo'],
        ':telefono' => $data['telefono'],
        ':direccion' => $data['direccion'],
        ':estado' => $data['estado']
    ]);

    $stmt = $conexion->prepare("SELECT * FROM clientes WHERE id = ?");
    $stmt->execute([$data['id']]);
    $cliente = $stmt->fetch(PDO::FETCH_ASSOC);

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