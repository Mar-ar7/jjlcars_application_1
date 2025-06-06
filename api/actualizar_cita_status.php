<?php
header('Content-Type: application/json');
//die("<!-- DEBUG -->"); // PRUEBA: Comentar o eliminar después

include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Leer datos JSON del body
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $id = $data['id'] ?? null;
    $status = $data['status'] ?? null;

    if ($id && $status) {
        $conn = obtenerConexion();
        try {
            $stmt = $conn->prepare("UPDATE citas SET status = ? WHERE id = ?");
            $stmt->execute([$status, $id]);
            if ($stmt->rowCount() > 0) {
                echo json_encode(['success' => true, 'message' => 'Status actualizado']);
            } else {
                echo json_encode(['success' => false, 'message' => 'No se actualizó ningún registro']);
            }
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => 'Error al actualizar', 'error' => $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Datos incompletos']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
}