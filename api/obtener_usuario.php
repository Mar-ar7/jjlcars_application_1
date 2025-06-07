<?php
require_once 'conexion.php';

$id = $_GET['id'] ?? null;
if (!$id) {
    echo json_encode(['success' => false, 'error' => 'ID requerido']);
    exit;
}

$sql = "SELECT id, Usuario, Nombre, TipoUsuario, estado, avatar FROM usuarios WHERE id = $id";
$result = $conn->query($sql);

if ($result && $row = $result->fetch_assoc()) {
    echo json_encode(['success' => true, 'usuario' => $row]);
} else {
    echo json_encode(['success' => false, 'error' => 'Usuario no encontrado']);
}
?> 