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

require_once 'config.php';

try {
    $conexion = getConnection();
    
    $consulta = $conexion->query('SELECT * FROM clientes ORDER BY nombre');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }
    
    $clientes = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Procesar los resultados
    $clientesProcesados = [];
    foreach ($clientes as $cliente) {
        $clienteProcesado = [
            'Id' => (int)$cliente['Id'],
            'Correo' => (string)$cliente['Correo'],
            'nombre' => (string)$cliente['nombre'],
            'Usuario' => (string)$cliente['Usuario'],
            'tipoCliente' => (string)$cliente['tipoCliente']
        ];
        
        $clientesProcesados[] = $clienteProcesado;
    }
    
    echo json_encode([
        'success' => true,
        'clientes' => $clientesProcesados
    ]);
    
} catch (Exception $e) {
    error_log("Error en obtener_clientes.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 