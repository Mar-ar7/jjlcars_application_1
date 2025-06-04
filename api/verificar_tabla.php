<?php
header('Content-Type: text/plain; charset=UTF-8');

require_once 'conexion.php';

try {
    $conn = obtenerConexion();
    
    // Verificar si las columnas existen
    $sql = "SHOW COLUMNS FROM usuarios WHERE Field IN ('estado', 'estado_mensaje', 'estado_hasta')";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $columnas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "Columnas encontradas:\n";
    print_r($columnas);
    
    echo "\n\nEstructura completa de la tabla:\n";
    $sql = "DESCRIBE usuarios";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $estructura = $stmt->fetchAll(PDO::FETCH_ASSOC);
    print_r($estructura);
    
} catch(PDOException $e) {
    echo "Error: " . $e->getMessage();
}

$conn = null; 