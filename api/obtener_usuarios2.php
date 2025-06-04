<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    $consulta = $conexion->query('SELECT id, Usuario, Nombre, TipoUsuario, estado, estado_mensaje, estado_hasta, avatar FROM usuarios');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }
    
    $usuarios = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Procesar los resultados
    foreach ($usuarios as &$usuario) {
        if (!isset($usuario['estado']) || empty($usuario['estado'])) {
            $usuario['estado'] = 'Disponible';
        }
        
        if (!empty($usuario['estado_hasta'])) {
            try {
                $fecha = new DateTime($usuario['estado_hasta']);
                $usuario['estado_hasta'] = $fecha->format('Y-m-d H:i:s');
            } catch (Exception $e) {
                $usuario['estado_hasta'] = null;
            }
        }
    }
    
    echo json_encode([
        'success' => true,
        'usuarios' => $usuarios
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
} 