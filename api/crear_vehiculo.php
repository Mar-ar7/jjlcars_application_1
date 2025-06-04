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

require_once 'conexion.php';

try {
    // Verificar si se recibió un archivo
    if (!isset($_FILES['imagen'])) {
        throw new Exception('No se recibió ninguna imagen');
    }

    // Verificar y procesar los datos del formulario
    if (!isset($_POST['marca']) || !isset($_POST['modelo']) || !isset($_POST['precio']) || !isset($_POST['inventario'])) {
        throw new Exception('Faltan datos requeridos');
    }

    // Procesar la imagen
    $imagen = $_FILES['imagen'];
    $nombreImagen = $imagen['name'];
    $tipoImagen = $imagen['type'];
    $rutaTemporal = $imagen['tmp_name'];
    $error = $imagen['error'];

    // Verificar errores en la subida
    if ($error !== UPLOAD_ERR_OK) {
        throw new Exception('Error al subir la imagen');
    }

    // Verificar tipo de archivo
    $tiposPermitidos = ['image/jpeg', 'image/png', 'image/jpg'];
    if (!in_array($tipoImagen, $tiposPermitidos)) {
        throw new Exception('Tipo de archivo no permitido. Solo se permiten JPG y PNG');
    }

    // Generar nombre único para la imagen
    $extension = pathinfo($nombreImagen, PATHINFO_EXTENSION);
    $nombreUnico = uniqid() . '_' . $nombreImagen;
    
    // Crear directorio si no existe
    $directorioDestino = '../Imagen/';
    if (!file_exists($directorioDestino)) {
        mkdir($directorioDestino, 0777, true);
    }

    // Mover el archivo
    $rutaDestino = $directorioDestino . $nombreUnico;
    if (!move_uploaded_file($rutaTemporal, $rutaDestino)) {
        throw new Exception('Error al guardar la imagen');
    }

    $conexion = Conexion::conectar();
    
    // Insertar el nuevo vehículo
    $sql = "INSERT INTO vehiculos (marca, modelo, descripcion, precio, imagen, inventario) VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        $_POST['marca'],
        $_POST['modelo'],
        $_POST['descripcion'] ?? '',
        $_POST['precio'],
        $nombreUnico,
        $_POST['inventario']
    ]);
    
    $nuevoId = $conexion->lastInsertId();
    
    // Obtener el vehículo recién creado
    $stmt = $conexion->prepare('SELECT * FROM vehiculos WHERE id = ?');
    $stmt->execute([$nuevoId]);
    $vehiculo = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Construir la URL completa de la imagen
    $vehiculo['imagen'] = '/Imagen/' . $vehiculo['imagen'];
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Vehículo creado exitosamente',
        'vehiculo' => $vehiculo
    ]);
    
} catch (Exception $e) {
    error_log("Error en crear_vehiculo.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 