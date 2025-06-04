<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

require_once 'conexion.php';

try {
    // Intentar conectar a la base de datos
    $conn = Conexion::conectar();
    
    // Verificar si la tabla usuarios existe
    $stmt = $conn->query("SHOW TABLES LIKE 'usuarios'");
    $tablaExiste = $stmt->rowCount() > 0;
    
    if ($tablaExiste) {
        // Contar usuarios
        $stmt = $conn->query("SELECT COUNT(*) as total FROM usuarios");
        $totalUsuarios = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        
        echo json_encode([
            'success' => true,
            'message' => 'Conexión exitosa',
            'database' => 'jjlcars',
            'tabla_usuarios' => true,
            'total_usuarios' => $totalUsuarios
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'La tabla usuarios no existe',
            'database' => 'jjlcars',
            'tabla_usuarios' => false
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error de conexión: ' . $e->getMessage()
    ]);
} 