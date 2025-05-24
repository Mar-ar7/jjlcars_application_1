<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

include 'api/conexion.php';

try {
    $conn = obtenerConexion();
    
    $sql = "SELECT id, Usuario, Nombre, TipoUsuario, estado, estado_mensaje, estado_hasta, avatar FROM usuarios";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if ($usuarios) {
        // Procesar las fechas para un formato más amigable
        foreach ($usuarios as &$usuario) {
            if (!empty($usuario['estado_hasta'])) {
                $fecha = new DateTime($usuario['estado_hasta']);
                $usuario['estado_hasta'] = $fecha->format('Y-m-d H:i:s');
            }
        }
        echo json_encode($usuarios);
    } else {
        echo json_encode([]);
    }
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Error al obtener usuarios: ' . $e->getMessage()]);
}

$conn = null; 