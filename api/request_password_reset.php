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

    if (!$postData || !isset($postData['usuario'])) {
        throw new Exception('Datos JSON inválidos o usuario no proporcionado');
    }

    $usuario = trim($postData['usuario']);

    if (empty($usuario)) {
        throw new Exception('El usuario es requerido');
    }

    $conn = Conexion::conectar();

    // Verificar si el usuario existe
    $stmt = $conn->prepare("SELECT id FROM usuarios WHERE Usuario = :usuario LIMIT 1");
    $stmt->execute(['usuario' => $usuario]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        // Devolver un mensaje genérico para evitar enumeración de usuarios
        echo json_encode([
            'success' => true,
            'message' => 'Si el usuario existe, se enviarán instrucciones.'
        ]);
        exit();
    }

    $user_id = $user['id'];
    // Generar un token único y con fecha de expiración (ej. 1 hora)
    $token = bin2hex(random_bytes(32)); // Token aleatorio
    $expires_at = date('Y-m-d H:i:s', strtotime('+1 hour'));

    // Eliminar tokens antiguos para este usuario
    $stmt_delete = $conn->prepare("DELETE FROM password_resets WHERE user_id = :user_id");
    $stmt_delete->execute(['user_id' => $user_id]);

    // Almacenar el nuevo token en una tabla 'password_resets'
    // NOTA: Necesitarás crear una tabla en tu base de datos llamada 'password_resets' con columnas: user_id (FK a usuarios), token (VARCHAR), expires_at (DATETIME)
    $stmt_insert = $conn->prepare("INSERT INTO password_resets (user_id, token, expires_at) VALUES (:user_id, :token, :expires_at)");
    $stmt_insert->execute([
        'user_id' => $user_id,
        'token' => $token,
        'expires_at' => $expires_at
    ]);

    // Aquí iría la lógica para enviar el correo electrónico al usuario
    // con un enlace que contenga el token. Por ahora, solo indicamos éxito.
    // Ejemplo de enlace (deberás adaptarlo a tu frontend):
    // $reset_link = 'TU_APP_URL/reset-password?token=' . $token;
    // mail($email_del_usuario, 'Restablecer Contraseña', 'Haz click en el siguiente enlace: ' . $reset_link);

    echo json_encode([
        'success' => true,
        'message' => 'Si el usuario existe, se enviarán instrucciones.'
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error al procesar la solicitud: ' . $e->getMessage()
    ]);
}

$conn = null;

?> 