<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'config.php';

try {
    $conexion = getConnection();
    $resultado = $conexion->query("SELECT 1")->fetch();
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Conexión exitosa a la base de datos',
        'version_php' => PHP_VERSION,
        'version_mysql' => $conexion->getAttribute(PDO::ATTR_SERVER_VERSION)
    ]);
    
} catch (Exception $e) {
    error_log("Error en test_conexion.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'version_php' => PHP_VERSION
    ]);
} 