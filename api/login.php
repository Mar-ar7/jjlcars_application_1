<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
error_log("Inicio de solicitud de login");

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $input = file_get_contents('php://input');
    error_log("Datos recibidos: " . $input);
    
    $postData = json_decode($input, true);
    
    if (!$postData) {
        throw new Exception('Datos JSON inválidos');
    }

    $usuario = trim($postData['usuario'] ?? '');
    $password = trim($postData['password'] ?? '');

    if (empty($usuario) || empty($password)) {
        throw new Exception('Usuario y contraseña son requeridos');
    }

    require_once 'conexion.php';
    $conn = Conexion::conectar();
    
    // Consultar usuario
    $stmt = $conn->prepare("SELECT id, Usuario, password, Nombre, TipoUsuario FROM usuarios WHERE Usuario = :usuario");
    $stmt->execute(['usuario' => $usuario]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        error_log("Usuario no encontrado: " . $usuario);
        throw new Exception('Credenciales inválidas');
    }

    // En tu base de datos, la contraseña para Daniela es '123456'
    if ($user['password'] === $password) {
        unset($user['password']);
        echo json_encode([
            'success' => true,
            'usuario' => $user
        ]);
    } else {
        throw new Exception('Credenciales inválidas');
    }

} catch (Exception $e) {
    error_log("Error en login: " . $e->getMessage());
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}