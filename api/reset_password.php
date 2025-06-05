<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'conexion.php';

try {
    $input = file_get_contents('php://input');
    $postData = json_decode($input, true);

    // Check for required fields: usuario, nombre, and new_password
    if (!$postData || !isset($postData['usuario']) || !isset($postData['nombre']) || !isset($postData['new_password'])) {
        throw new Exception('Datos JSON inválidos o usuario, nombre, o nueva contraseña no proporcionados');
    }

    $usuario = trim($postData['usuario']);
    $nombre = trim($postData['nombre']);
    $new_password = trim($postData['new_password']);

    if (empty($usuario) || empty($nombre) || empty($new_password)) {
        throw new Exception('Usuario, nombre y nueva contraseña son requeridos');
    }

    // Validate minimum password length
    if (strlen($new_password) < 6) {
         throw new Exception('La nueva contraseña debe tener al menos 6 caracteres');
    }


    $conn = Conexion::conectar();

    // Verify if the user exists with the provided username and full name
    $stmt = $conn->prepare("SELECT id FROM usuarios WHERE Usuario = :usuario AND Nombre = :nombre LIMIT 1");
    $stmt->execute([
        'usuario' => $usuario,
        'nombre' => $nombre
    ]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        // Use a generic message for security
        throw new Exception('Verificación fallida. Usuario o nombre incorrecto.');
    }

    $user_id = $user['id'];

    // Hash the new password
    $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

    // Update the user's password
    $stmt_update_password = $conn->prepare("UPDATE usuarios SET password = :password WHERE id = :user_id");
    $stmt_update_password->execute([
        'password' => $hashed_password,
        'user_id' => $user_id
    ]);

    // Note: No token to delete in this simplified flow

    echo json_encode([
        'success' => true,
        'message' => 'Contraseña restablecida con éxito.'
    ]);

} catch (Exception $e) {
    http_response_code(400); // Use 400 for client errors
    echo json_encode([
        'success' => false,
        'message' => 'Error al restablecer la contraseña: ' . $e->getMessage()
    ]);
}

$conn = null;

?> 