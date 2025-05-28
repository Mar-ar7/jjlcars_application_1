<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'conexion.php';

try {
    // Probar la conexión
    $conexion = Conexion::conectar();
    
    // Probar consulta a la tabla citas
    $consultaCitas = $conexion->query('SELECT COUNT(*) as total FROM citas');
    $totalCitas = $consultaCitas->fetch()['total'];
    
    // Probar consulta a la tabla clientes
    $consultaClientes = $conexion->query('SELECT COUNT(*) as total FROM clientes');
    $totalClientes = $consultaClientes->fetch()['total'];
    
    // Probar consulta a la tabla vehiculos
    $consultaVehiculos = $conexion->query('SELECT COUNT(*) as total FROM vehiculos');
    $totalVehiculos = $consultaVehiculos->fetch()['total'];
    
    // Probar consulta a la tabla usuarios
    $consultaUsuarios = $conexion->query('SELECT COUNT(*) as total FROM usuarios');
    $totalUsuarios = $consultaUsuarios->fetch()['total'];
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Conexión y consultas exitosas',
        'totales' => [
            'citas' => $totalCitas,
            'clientes' => $totalClientes,
            'vehiculos' => $totalVehiculos,
            'usuarios' => $totalUsuarios
        ],
        'version_php' => PHP_VERSION,
        'version_mysql' => $conexion->getAttribute(PDO::ATTR_SERVER_VERSION)
    ]);
    
} catch (Exception $e) {
    error_log("Error en test_db.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
} 