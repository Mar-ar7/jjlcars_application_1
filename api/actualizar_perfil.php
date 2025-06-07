<?php
require_once 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (strpos($_SERVER['CONTENT_TYPE'], 'application/json') !== false) {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        $id = $data['id'] ?? null;
        $nombre = $data['nombre'] ?? null;
    } else {
        $id = $_POST['id'] ?? null;
        $nombre = $_POST['nombre'] ?? null;
    }
    $avatar = null;
    if (!$id) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'ID de usuario requerido']);
        exit;
    }

    // Manejar subida de imagen si existe
    if (isset($_FILES['avatar']) && $_FILES['avatar']['error'] == 0) {
        $extensionesPermitidas = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        $extension = strtolower(pathinfo($_FILES['avatar']['name'], PATHINFO_EXTENSION));
        if (!in_array($extension, $extensionesPermitidas)) {
            echo json_encode(['success' => false, 'error' => 'Tipo de archivo no permitido. Solo se permiten imágenes (jpg, jpeg, png, gif, bmp, webp).']);
            exit;
        }
        $dir = 'avatars/';
        if (!is_dir($dir)) mkdir($dir, 0777, true);
        $filename = $dir . time() . '_' . basename($_FILES['avatar']['name']);
        if (move_uploaded_file($_FILES['avatar']['tmp_name'], $filename)) {
            $avatar = $filename;
        } else {
            echo json_encode(['success' => false, 'error' => 'Error al subir imagen']);
            exit;
        }
    }

    // Conexión PDO
    $conexion = null;
    try {
        $conexion = new PDO(
            'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
            'root',
            '',
            array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
        );
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => 'Error de conexión a la base de datos']);
        exit;
    }

    // Construir consulta dinámica
    $campos = [];
    $params = [];
    if ($nombre) {
        $campos[] = 'Nombre = ?';
        $params[] = $nombre;
    }
    if ($avatar) {
        $campos[] = 'avatar = ?';
        $params[] = $avatar;
    }
    if (empty($campos)) {
        echo json_encode(['success' => true, 'avatar' => $avatar, 'nombre' => $nombre]);
        exit;
    }
    $params[] = $id;
    $sql = 'UPDATE usuarios SET ' . implode(', ', $campos) . ' WHERE id = ?';
    $stmt = $conexion->prepare($sql);
    if ($stmt->execute($params)) {
        echo json_encode(['success' => true, 'avatar' => $avatar ? $avatar : null, 'nombre' => $nombre]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Error al actualizar usuario']);
    }
    exit;
}
?> 