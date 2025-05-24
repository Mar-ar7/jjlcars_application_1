<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: DELETE, POST');
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
    
    // Verificar si el usuario existe antes de eliminarlo
    $stmt = $conexion->prepare('SELECT TipoUsuario FROM usuarios WHERE id = ?');
    $stmt->execute([$data['id']]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$usuario) {
        throw new Exception('Usuario no encontrado');
    }
    
    // No permitir eliminar al último administrador
    if ($usuario['TipoUsuario'] === 'Administrador') {
        $stmt = $conexion->prepare('SELECT COUNT(*) as count FROM usuarios WHERE TipoUsuario = "Administrador"');
        $stmt->execute();
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        
        if ($count <= 1) {
            throw new Exception('No se puede eliminar al último administrador');
        }
    }
    
    // Eliminar el usuario
    $stmt = $conexion->prepare('DELETE FROM usuarios WHERE id = ?');
    $stmt->execute([$data['id']]);
    
    if ($stmt->rowCount() === 0) {
        throw new Exception('No se pudo eliminar el usuario');
    }
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Usuario eliminado exitosamente'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 