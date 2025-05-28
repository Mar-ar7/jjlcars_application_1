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

require_once 'config/database.php';

try {
    $sql = "SELECT * FROM vehiculos ORDER BY marca, modelo";
    $vehiculos = Database::fetchAll($sql);
    
    // Procesar los resultados
    foreach ($vehiculos as &$vehiculo) {
        // Asegurar que los tipos de datos sean correctos
        $vehiculo['id'] = (int)$vehiculo['id'];
        $vehiculo['precio'] = (float)$vehiculo['precio'];
        $vehiculo['inventario'] = (int)$vehiculo['inventario'];
        
        // Construir la URL completa de la imagen
        if (!empty($vehiculo['imagen'])) {
            $vehiculo['imagen'] = '/Imagen/' . $vehiculo['imagen'];
        }
    }
    
    echo json_encode([
        'success' => true,
        'vehiculos' => $vehiculos
    ]);
    
} catch (Exception $e) {
    error_log("Error en obtener_vehiculos.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 