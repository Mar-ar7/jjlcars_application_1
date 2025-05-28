<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'conexion.php';

try {
    $conexion = Conexion::conectar();
    
    $consulta = $conexion->query('SELECT * FROM vehiculos ORDER BY marca, modelo');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }
    
    $vehiculos = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Procesar los resultados
    $vehiculosProcesados = [];
    foreach ($vehiculos as $vehiculo) {
        // Construir la URL completa de la imagen
        $imagenUrl = $vehiculo['imagen'];
        if (!empty($imagenUrl) && !filter_var($imagenUrl, FILTER_VALIDATE_URL)) {
            // Si la imagen no es una URL completa, construir la ruta relativa
            $imagenUrl = '/Imagen/' . $imagenUrl;
        }
        
        $vehiculoProcesado = [
            'id' => (int)$vehiculo['id'],
            'marca' => (string)$vehiculo['marca'],
            'modelo' => (string)$vehiculo['modelo'],
            'descripcion' => (string)$vehiculo['descripcion'],
            'precio' => (float)$vehiculo['precio'],
            'imagen' => $imagenUrl,
            'inventario' => (int)$vehiculo['inventario']
        ];
        
        $vehiculosProcesados[] = $vehiculoProcesado;
    }
    
    echo json_encode([
        'success' => true,
        'vehiculos' => $vehiculosProcesados
    ]);
    
} catch (Exception $e) {
    error_log("Error en obtener_vehiculos.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 