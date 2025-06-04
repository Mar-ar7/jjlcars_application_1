<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id'])) {
        throw new Exception('ID de cita requerido');
    }

    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    $sql = "UPDATE citas SET 
            nombre = :nombre,
            correo = :correo,
            tipoCita = :tipoCita,
            tipoCompra = :tipoCompra,
            precio = :precio,
            fecha = :fecha,
            hora = :hora,
            status = :status
            WHERE id = :id";

    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        ':id' => $data['id'],
        ':nombre' => $data['nombre'],
        ':correo' => $data['correo'],
        ':tipoCita' => $data['tipoCita'],
        ':tipoCompra' => $data['tipoCompra'],
        ':precio' => $data['precio'],
        ':fecha' => $data['fecha'],
        ':hora' => $data['hora'],
        ':status' => $data['status']
    ]);

    echo json_encode([
        'success' => true,
        'mensaje' => 'Cita actualizada correctamente'
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>