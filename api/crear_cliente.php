<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['Correo']) || !isset($data['nombre']) || !isset($data['Usuario']) || !isset($data['Password'])) {
        throw new Exception('Faltan datos requeridos');
    }
    
    $conexion = new PDO(
        'mysql:host=localhost;dbname=jjlcars;charset=utf8mb4',
        'root',
        '',
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    
    // Verificar si el correo ya existe
    $stmt = $conexion->prepare('SELECT Id FROM clientes WHERE Correo = ?');
    $stmt->execute([$data['Correo']]);
    if ($stmt->fetch()) {
        throw new Exception('El correo electrónico ya está registrado');
    }
    
    // Verificar si el usuario ya existe
    $stmt = $conexion->prepare('SELECT Id FROM clientes WHERE Usuario = ?');
    $stmt->execute([$data['Usuario']]);
    if ($stmt->fetch()) {
        throw new Exception('El nombre de usuario ya está en uso');
    }
    
    // Crear el nuevo cliente
    $sql = "INSERT INTO clientes (Correo, nombre, Usuario, Password, tipoCliente) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conexion->prepare($sql);
    $stmt->execute([
        $data['Correo'],
        $data['nombre'],
        $data['Usuario'],
        $data['Password'],
        $data['tipoCliente'] ?? 'Cliente'
    ]);
    
    $nuevoId = $conexion->lastInsertId();
    
    // Obtener el cliente recién creado
    $stmt = $conexion->prepare('SELECT Id, Correo, nombre, Usuario, tipoCliente FROM clientes WHERE Id = ?');
    $stmt->execute([$nuevoId]);
    $cliente = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'mensaje' => 'Cliente creado exitosamente',
        'cliente' => $cliente
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 