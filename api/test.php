<?php
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    // Conexión directa sin usar clases
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    // Consulta simple
    $consulta = $conexion->query('SELECT * FROM usuarios');
    $usuarios = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Devolver resultados
    echo json_encode([
        'success' => true,
        'usuarios' => $usuarios
    ]);
    
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
} 