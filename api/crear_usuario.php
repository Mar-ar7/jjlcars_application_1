<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['Usuario']) || !isset($data['Nombre']) || !isset($data['Password']) || !isset($data['TipoUsuario'])) {
        throw new Exception('Faltan datos requeridos');
    }
    
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    // Verificar si el usuario ya existe
    $stmt = $conexion->prepare('SELECT id FROM usuarios WHERE Usuario = ?');
    $stmt->execute([$data['Usuario']]);
    if ($stmt->fetch()) {
        throw new Exception('El nombre de usuario ya existe');
    }
    
    // Crear el nuevo usuario
    $sql = "INSERT INTO usuarios (Usuario, Nombre, Password, TipoUsuario, estado) VALUES (?, ?, ?, ?, 'Disponible')";
    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        $data['Usuario'],
        $data['Nombre'],
        password_hash($data['Password'], PASSWORD_DEFAULT),
        $data['TipoUsuario']
    ]);
    
    $nuevoId = $conexion->lastInsertId();
    
    // Obtener el usuario recién creado
    $stmt = $conexion->prepare('SELECT id, Usuario, Nombre, TipoUsuario, estado FROM usuarios WHERE id = ?');
    $stmt->execute([$nuevoId]);
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Usuario creado exitosamente',
        'usuario' => $usuario
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 