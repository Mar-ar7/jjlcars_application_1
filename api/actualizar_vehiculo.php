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
    $stmt = $conexion->prepare('SELECT * FROM vehiculos WHERE id = ?');
    $stmt->execute([$id]);
    $vehiculo = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$vehiculo) {
        throw new Exception('Vehículo no encontrado');
    }

    // Procesar imagen si se sube una nueva
    $nombreImagen = $vehiculo['imagen'];
    if (isset($_FILES['imagen']) && $_FILES['imagen']['error'] === UPLOAD_ERR_OK) {
        $imagen = $_FILES['imagen'];
        $tipoImagen = $imagen['type'];
        if (strpos($tipoImagen, 'image/') !== 0) {
            throw new Exception('Tipo de archivo no permitido. Solo se permiten imágenes.');
        }
        $extension = pathinfo($imagen['name'], PATHINFO_EXTENSION);
        $nombreUnico = uniqid() . '_' . $imagen['name'];
        $directorioDestino = '../Imagen/';
        if (!file_exists($directorioDestino)) {
            mkdir($directorioDestino, 0777, true);
        }
        $rutaDestino = $directorioDestino . $nombreUnico;
        if (!move_uploaded_file($imagen['tmp_name'], $rutaDestino)) {
            throw new Exception('Error al guardar la imagen');
        }
        $nombreImagen = $nombreUnico;
    }

    // Actualizar datos
    $sql = "UPDATE vehiculos SET marca = ?, modelo = ?, descripcion = ?, precio = ?, imagen = ?, inventario = ? WHERE id = ?";
    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        $_POST['marca'] ?? $vehiculo['marca'],
        $_POST['modelo'] ?? $vehiculo['modelo'],
        $_POST['descripcion'] ?? $vehiculo['descripcion'],
        $_POST['precio'] ?? $vehiculo['precio'],
        $nombreImagen,
        $_POST['inventario'] ?? $vehiculo['inventario'],
        $id
    ]);

    // Obtener datos actualizados
    $stmt = $conexion->prepare('SELECT * FROM vehiculos WHERE id = ?');
    $stmt->execute([$id]);
    $vehiculoActualizado = $stmt->fetch(PDO::FETCH_ASSOC);
    $vehiculoActualizado['imagen'] = '/Imagen/' . $vehiculoActualizado['imagen'];

    echo json_encode([
        'success' => true,
        'mensaje' => 'Vehículo actualizado correctamente',
        'vehiculo' => $vehiculoActualizado
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 