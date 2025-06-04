<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
require_once 'conexion.php';

try {
    $conn = Conexion::conectar();
    
    // Consultar todos los usuarios
    $stmt = $conn->query("SELECT id, Usuario, Nombre, TipoUsuario, estado FROM usuarios");
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'usuarios' => $usuarios
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
} 