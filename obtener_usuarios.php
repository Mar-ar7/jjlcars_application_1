<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

include 'conexion.php';

try {
    $sql = "SELECT id, Usuario, Nombre, TipoUsuario, avatar FROM usuarios";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode($usuarios);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}

$conn = null; 