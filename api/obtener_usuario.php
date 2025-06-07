<?php
require_once 'conexion.php';

// Agregar conexión a la base de datos
$conn = obtenerConexion();

$id = $_GET['id'] ?? null;
if (!$id) {
    echo json_encode(['success' => false, 'error' => 'ID requerido']);
    exit;
}

$sql = "SELECT id, Usuario, Nombre, TipoUsuario, estado, avatar FROM usuarios WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->execute([$id]);

if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo json_encode(['success' => true, 'usuario' => $row]);
} else {
    echo json_encode(['success' => false, 'error' => 'Usuario no encontrado']);
}
?> 