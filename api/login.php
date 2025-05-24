<?php
require_once 'conexion.php';

// Configurar headers CORS y JSON
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// Manejar preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Verificar método HTTP
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
    exit();
}

try {
    // Obtener datos del body JSON
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(['error' => 'JSON inválido']);
        exit();
    }

    $usuario = $data['Usuario'] ?? null;
    $password = $data['password'] ?? null;

    // Validar datos
    if (!$usuario || !$password) {
        http_response_code(400);
        echo json_encode(['error' => 'Usuario y contraseña son requeridos']);
        exit();
    }

    // Conectar a la base de datos
    $conn = Conexion::conectar();
    
    // Preparar y ejecutar la consulta
    $sql = "SELECT id, Usuario, Nombre, TipoUsuario FROM usuarios WHERE Usuario = ? AND password = ?";
    $stmt = $conn->prepare($sql);
    $stmt->execute([$usuario, $password]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        echo json_encode([
            'success' => true,
            'user' => $user
        ]);
    } else {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Credenciales inválidas'
        ]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Error en el servidor: ' . $e->getMessage()]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Error inesperado: ' . $e->getMessage()]);
}
?> 