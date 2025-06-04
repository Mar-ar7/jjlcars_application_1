<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Agregar log para debugging
error_log("Iniciando obtener_citas.php");

try {
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    error_log("Conexión establecida");

    $consulta = $conexion->query('SELECT * FROM citas');
    if (!$consulta) {
        throw new Exception('Error al ejecutar la consulta');
    }

    $citas = $consulta->fetchAll(PDO::FETCH_ASSOC);
    
    // Log para ver los datos recuperados
    error_log("Citas encontradas: " . count($citas));
    error_log("Datos: " . json_encode($citas));

    // Asegurar que siempre devolvemos un array, incluso si está vacío
    $response = [
        'success' => true,
        'citas' => $citas ?: []
    ];

    echo json_encode($response, JSON_PRETTY_PRINT);
    error_log("Respuesta enviada exitosamente");

} catch (Exception $e) {
    error_log("Error en obtener_citas.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>