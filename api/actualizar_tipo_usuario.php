<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
require_once 'conexion.php';

try {
    $conn = Conexion::conectar();
    
    // Actualizar el tipo de usuario de waos777 a Vendedor
    $stmt = $conn->prepare("UPDATE usuarios SET TipoUsuario = 'Vendedor' WHERE Usuario = 'waos777'");
    $resultado = $stmt->execute();
    
    if ($resultado) {
        echo json_encode([
            'success' => true,
            'message' => 'Usuario actualizado correctamente'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'No se pudo actualizar el usuario'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
} 