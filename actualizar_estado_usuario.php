<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include 'api/conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id = isset($data['id']) ? $data['id'] : null;
    $estado = isset($data['estado']) ? $data['estado'] : null;
    $estado_mensaje = isset($data['estado_mensaje']) ? $data['estado_mensaje'] : null;
    $estado_hasta = isset($data['estado_hasta']) ? $data['estado_hasta'] : null;
    $usuario_id = isset($data['usuario_id']) ? $data['usuario_id'] : null;
    $tipo_usuario = isset($data['tipo_usuario']) ? $data['tipo_usuario'] : null;

    if (!$id || !$estado) {
        http_response_code(400);
        echo json_encode(['error' => 'Datos incompletos']);
        exit();
    }

    // Verificar permisos
    if ($tipo_usuario !== 'administrador' && $usuario_id != $id) {
        http_response_code(403);
        echo json_encode(['error' => 'No tienes permiso para modificar el estado de otros usuarios']);
        exit();
    }

    try {
        $conn = obtenerConexion();
        
        $sql = "UPDATE usuarios SET estado = :estado, estado_mensaje = :estado_mensaje, estado_hasta = :estado_hasta WHERE id = :id";
        $stmt = $conn->prepare($sql);
        
        $stmt->bindParam(':estado', $estado);
        $stmt->bindParam(':estado_mensaje', $estado_mensaje);
        $stmt->bindParam(':estado_hasta', $estado_hasta);
        $stmt->bindParam(':id', $id);
        
        if ($stmt->execute()) {
            // Obtener los datos actualizados del usuario
            $sql = "SELECT id, Usuario, Nombre, TipoUsuario, estado, estado_mensaje, estado_hasta, avatar FROM usuarios WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            $usuario_actualizado = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($usuario_actualizado && !empty($usuario_actualizado['estado_hasta'])) {
                $fecha = new DateTime($usuario_actualizado['estado_hasta']);
                $usuario_actualizado['estado_hasta'] = $fecha->format('Y-m-d H:i:s');
            }
            
            echo json_encode([
                'mensaje' => 'Estado actualizado correctamente',
                'usuario' => $usuario_actualizado
            ]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar el estado']);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error en la base de datos: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

$conn = null; 