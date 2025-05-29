<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

ini_set('display_errors', 1);
error_reporting(E_ALL);

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

    $consulta = $conexion->query('SELECT id, nombre, correo, fecha, hora FROM citas');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }

    $citas = $consulta->fetchAll(PDO::FETCH_ASSOC);
    debug_log("Citas obtenidas: " . count($citas));

    // Procesar resultados si necesitas (ejemplo: formatear fecha)
    $citasProcesadas = [];
    foreach ($citas as $cita) {
        $citaProcesada = [
            'id' => isset($cita['id']) ? (int)$cita['id'] : 0,
            'nombre' => isset($cita['nombre']) ? (string)$cita['nombre'] : '',
            'correo' => isset($cita['correo']) ? (string)$cita['correo'] : '',
            'fecha' => isset($cita['fecha']) ? (string)$cita['fecha'] : '',
            'hora' => isset($cita['hora']) ? (string)$cita['hora'] : '',
        ];
        $citasProcesadas[] = $citaProcesada;
    }

    debug_log("Citas procesadas: " . count($citasProcesadas));

    $respuesta = [
        'success' => true,
        'citas' => $citasProcesadas,
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
