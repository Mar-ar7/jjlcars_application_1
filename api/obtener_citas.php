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
    $sql = "SELECT * FROM citas ORDER BY fecha DESC, hora DESC";
    $citas = Database::fetchAll($sql);
    
    // Procesar los resultados
    foreach ($citas as &$cita) {
        // Asegurar que los tipos de datos sean correctos
        $cita['id'] = (int)$cita['id'];
        $cita['precio'] = (float)$cita['precio'];
        
        // Formatear las fechas
        if (!empty($cita['fecha'])) {
            $fecha = new DateTime($cita['fecha']);
            $cita['fecha'] = $fecha->format('Y-m-d');
        }
        
        if (!empty($cita['fecha_registro'])) {
            $fecha = new DateTime($cita['fecha_registro']);
            $cita['fecha_registro'] = $fecha->format('Y-m-d H:i:s');
        }
    }
    
    echo json_encode([
        'success' => true,
        'citas' => $citas
    ]);
    
} catch (Exception $e) {
    error_log("Error en obtener_citas.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 