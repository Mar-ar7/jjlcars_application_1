<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'conexion.php';

try {
    if (!isset($_POST['id'])) {
        throw new Exception('ID de vehículo no proporcionado');
    }
    $id = $_POST['id'];
    $conexion = Conexion::conectar();

    // Obtener datos actuales
    $stmt = $conexion->prepare('SELECT imagen FROM vehiculos WHERE id = ?');
    $stmt->execute([$id]);
    $vehiculo = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$vehiculo) {
        throw new Exception('Vehículo no encontrado');
    }
    $nombreImagen = $vehiculo['imagen'];

    // Eliminar registro
    $stmt = $conexion->prepare('DELETE FROM vehiculos WHERE id = ?');
    $stmt->execute([$id]);

    // Eliminar imagen física si existe
    $rutaImagen = '../Imagen/' . $nombreImagen;
    if (file_exists($rutaImagen)) {
        unlink($rutaImagen);
    }

    echo json_encode([
        'success' => true,
        'mensaje' => 'Vehículo eliminado correctamente'
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 