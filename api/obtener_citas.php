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
    
    $consulta = $conexion->query('SELECT * FROM citas ORDER BY fecha, hora');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }
    
    $citas = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Procesar los resultados
    $citasProcesadas = [];
    foreach ($citas as $cita) {
        $citaProcesada = [
            'id' => (int)$cita['id'],
            'tipoCita' => (string)$cita['tipoCita'],
            'tipoCompra' => (string)$cita['tipoCompra'],
            'precio' => (float)$cita['precio'],
            'nombre' => (string)$cita['nombre'],
            'correo' => (string)$cita['correo'],
            'fecha' => (string)$cita['fecha'],
            'hora' => (string)$cita['hora'],
            'status' => (string)$cita['status']
        ];
        
        $citasProcesadas[] = $citaProcesada;
    }
    
    echo json_encode([
        'success' => true,
        'citas' => $citasProcesadas
    ]);
    
} catch (Exception $e) {
    error_log("Error en obtener_citas.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 