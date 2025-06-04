<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');

// Habilitar todos los errores para depuración
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Incluir el archivo de conexión desde la ubicación correcta
require_once __DIR__ . '/conexion.php';

try {
    $conn = obtenerConexion();
    
    // Verificar la conexión
    if (!$conn) {
        throw new Exception('No se pudo establecer la conexión con la base de datos');
    }
    
    $sql = "SELECT id, Usuario, Nombre, TipoUsuario, estado, estado_mensaje, estado_hasta, avatar FROM usuarios";
    $stmt = $conn->prepare($sql);
    
    // Ejecutar la consulta y verificar si fue exitosa
    if (!$stmt->execute()) {
        throw new Exception('Error al ejecutar la consulta');
    }
    
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Verificar si hay usuarios y procesarlos
    if ($usuarios && count($usuarios) > 0) {
        foreach ($usuarios as &$usuario) {
            // Asegurarse de que el estado tenga un valor por defecto
            if (!isset($usuario['estado']) || empty($usuario['estado'])) {
                $usuario['estado'] = 'Disponible';
            }
            
            // Formatear la fecha si existe
            if (!empty($usuario['estado_hasta'])) {
                $fecha = new DateTime($usuario['estado_hasta']);
                $usuario['estado_hasta'] = $fecha->format('Y-m-d H:i:s');
            }
        }
        echo json_encode([
            'success' => true,
            'usuarios' => $usuarios
        ]);
    } else {
        // Si no hay usuarios, devolver un array vacío dentro de un objeto
        echo json_encode([
            'success' => true,
            'usuarios' => []
        ]);
    }
} catch (Exception $e) {
    error_log("Error en obtener_usuarios.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Error al obtener usuarios: ' . $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
}

$conn = null; 