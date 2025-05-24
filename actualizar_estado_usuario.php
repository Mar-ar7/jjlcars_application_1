<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'conexion.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($_POST['id']) ? $_POST['id'] : null;
    $estado = isset($_POST['estado']) ? $_POST['estado'] : null;
    $estado_mensaje = isset($_POST['estado_mensaje']) ? $_POST['estado_mensaje'] : null;
    $estado_hasta = isset($_POST['estado_hasta']) ? $_POST['estado_hasta'] : null;

    if ($id && $estado) {
        try {
            $sql = "UPDATE usuarios SET estado = :estado, estado_mensaje = :estado_mensaje, estado_hasta = :estado_hasta WHERE id = :id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':estado', $estado);
            $stmt->bindParam(':estado_mensaje', $estado_mensaje);
            $stmt->bindParam(':estado_hasta', $estado_hasta);
            $stmt->bindParam(':id', $id);
            
            if ($stmt->execute()) {
                echo json_encode(['mensaje' => 'Estado actualizado correctamente']);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Error al actualizar el estado']);
            }
        } catch(PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Datos incompletos']);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
}

$conn = null; 