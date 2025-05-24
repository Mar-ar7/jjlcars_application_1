<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

// Manejar la solicitud OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Habilitar todos los errores para depuración
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Función para registrar mensajes de depuración
function debug_log($message) {
    error_log(print_r($message, true));
}

try {
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    debug_log("Conexión establecida");
    
    $consulta = $conexion->query('SELECT id, Usuario, Nombre, TipoUsuario, estado, estado_mensaje, estado_hasta, avatar FROM usuarios');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }
    
    $usuarios = $consulta->fetchAll(PDO::FETCH_ASSOC);
    debug_log("Usuarios obtenidos: " . count($usuarios));
    
    // Procesar los resultados
    $usuariosProcesados = [];
    foreach ($usuarios as $usuario) {
        $usuarioProcesado = [
            'id' => isset($usuario['id']) ? (int)$usuario['id'] : 0,
            'Usuario' => isset($usuario['Usuario']) ? (string)$usuario['Usuario'] : '',
            'Nombre' => isset($usuario['Nombre']) ? (string)$usuario['Nombre'] : '',
            'TipoUsuario' => isset($usuario['TipoUsuario']) ? (string)$usuario['TipoUsuario'] : '',
            'estado' => isset($usuario['estado']) && !empty($usuario['estado']) ? (string)$usuario['estado'] : 'Disponible',
            'estado_mensaje' => isset($usuario['estado_mensaje']) ? (string)$usuario['estado_mensaje'] : null,
            'estado_hasta' => null,
            'avatar' => isset($usuario['avatar']) ? (string)$usuario['avatar'] : ''
        ];
        
        // Formatear fecha si existe
        if (!empty($usuario['estado_hasta'])) {
            try {
                $fecha = new DateTime($usuario['estado_hasta']);
                $usuarioProcesado['estado_hasta'] = $fecha->format('Y-m-d H:i:s');
            } catch (Exception $e) {
                $usuarioProcesado['estado_hasta'] = null;
            }
        }
        
        $usuariosProcesados[] = $usuarioProcesado;
    }
    
    debug_log("Usuarios procesados: " . count($usuariosProcesados));
    
    // Asegurar que la respuesta siempre tenga la estructura correcta
    $respuesta = [
        'success' => true,
        'usuarios' => $usuariosProcesados
    ];
    
    debug_log("Respuesta final: " . json_encode($respuesta));
    
    echo json_encode($respuesta, JSON_THROW_ON_ERROR);
    
} catch (Exception $e) {
    debug_log("Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ], JSON_THROW_ON_ERROR);
} 