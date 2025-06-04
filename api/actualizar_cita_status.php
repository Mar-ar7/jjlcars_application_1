<?php
header('Content-Type: application/json');
include 'conexion.php'; // Asegúrate de tener tu conexión aquí

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'] ?? null;
    $status = $_POST['status'] ?? null;

    if ($id && $status) {
        $stmt = $conn->prepare("UPDATE citas SET status = ? WHERE id = ?");
        $stmt->bind_param("si", $status, $id);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Status actualizado']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Error al actualizar']);
        }
        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Datos incompletos']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
}
$conn->close();
?>