<?php
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    // Intentar conexión directa
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    // Verificar las tablas existentes
    $tablas = $conexion->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
    
    $estructura = [];
    foreach ($tablas as $tabla) {
        $columnas = $conexion->query("DESCRIBE $tabla")->fetchAll(PDO::FETCH_ASSOC);
        $estructura[$tabla] = $columnas;
    }
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Conexión exitosa',
        'tablas' => $tablas,
        'estructura' => $estructura
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
} 