<?php
header('Content-Type: application/json; charset=utf-8');
//die("<!-- DEBUG -->"); // PRUEBA: Comentar o eliminar después

include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Leer datos JSON del body
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    $id = $data['id'] ?? null;
    $status = $data['status'] ?? null;

    if ($id && $status) {
        try {
            $conn = obtenerConexion();
            if (!$conn) {
                http_response_code(500);
                die(json_encode(['success' => false, 'message' => 'Error de conexión a la base de datos']));
            }

            $stmt = $conn->prepare("UPDATE citas SET status = :status WHERE id = :id");
            $stmt->bindParam(':status', $status, PDO::PARAM_STR);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            
            if ($stmt->execute()) {
                die(json_encode(['success' => true, 'message' => 'Status actualizado correctamente']));
            } else {
                http_response_code(400);
                die(json_encode(['success' => false, 'message' => 'No se pudo actualizar el status']));
            }
        } catch (Exception $e) {
            http_response_code(500);
            die(json_encode(['success' => false, 'message' => 'Error al actualizar el status']));
        }
    } else {
        http_response_code(400);
        die(json_encode(['success' => false, 'message' => 'Datos incompletos']));
    }
} else {
    http_response_code(405);
    die(json_encode(['success' => false, 'message' => 'Método no permitido']));
}