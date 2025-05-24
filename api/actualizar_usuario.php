<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: PUT, POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id'])) {
        throw new Exception('ID de usuario requerido');
    }
    
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    // Construir la consulta de actualización dinámicamente
    $updateFields = [];
    $params = [];
    
    if (isset($data['Nombre'])) {
        $updateFields[] = 'Nombre = ?';
        $params[] = $data['Nombre'];
    }
    
    if (isset($data['Usuario'])) {
        // Verificar si el nuevo nombre de usuario ya existe
        if ($data['Usuario']) {
            $stmt = $conexion->prepare('SELECT id FROM usuarios WHERE Usuario = ? AND id != ?');
            $stmt->execute([$data['Usuario'], $data['id']]);
            if ($stmt->fetch()) {
                throw new Exception('El nombre de usuario ya existe');
            }
        }
        $updateFields[] = 'Usuario = ?';
        $params[] = $data['Usuario'];
    }
    
    if (isset($data['Password']) && !empty($data['Password'])) {
        $updateFields[] = 'Password = ?';
        $params[] = password_hash($data['Password'], PASSWORD_DEFAULT);
    }
    
    if (isset($data['TipoUsuario'])) {
        $updateFields[] = 'TipoUsuario = ?';
        $params[] = $data['TipoUsuario'];
    }
    
    if (empty($updateFields)) {
        throw new Exception('No hay campos para actualizar');
    }
    
    // Agregar el ID al final de los parámetros
    $params[] = $data['id'];
    
    $sql = "UPDATE usuarios SET " . implode(', ', $updateFields) . " WHERE id = ?";
    $stmt = $conexion->prepare($sql);
    $stmt->execute($params);
    
    if ($stmt->rowCount() === 0) {
        throw new Exception('No se encontró el usuario o no hubo cambios');
    }
    
    // Obtener el usuario actualizado
    $stmt = $conexion->prepare('SELECT id, Usuario, Nombre, TipoUsuario, estado FROM usuarios WHERE id = ?');
    $stmt->execute([$data['id']]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Usuario actualizado exitosamente',
        'usuario' => $usuario
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 