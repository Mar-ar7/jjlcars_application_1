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

    // Construir consulta dinámica
    $campos = [];
    if ($nombre) $campos[] = "Nombre = '" . $conn->real_escape_string($nombre) . "'";
    if ($avatar) $campos[] = "avatar = '" . $conn->real_escape_string($avatar) . "'";

    if (empty($campos)) {
        // No hay nada que actualizar, pero responde con éxito y los datos actuales
        echo json_encode(['success' => true, 'avatar' => $avatar, 'nombre' => $nombre]);
        exit;
    }

    $sql = "UPDATE usuarios SET " . implode(', ', $campos) . " WHERE id = $id";
    if ($conn->query($sql)) {
        echo json_encode(['success' => true, 'avatar' => $avatar, 'nombre' => $nombre]);
    } else {
        echo json_encode(['success' => false, 'error' => $conn->error]);
    }
}
?> 