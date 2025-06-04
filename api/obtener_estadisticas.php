<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
require_once 'conexion.php';

try {
    $conn = Conexion::conectar();
    
    // Obtener totales
    $totales = [];
    
    // Total usuarios
    $stmt = $conn->query("SELECT COUNT(*) as total FROM usuarios");
    $totales['total_usuarios'] = $stmt->fetch()['total'];
    
    // Total vehículos
    $stmt = $conn->query("SELECT COUNT(*) as total FROM vehiculos");
    $totales['total_vehiculos'] = $stmt->fetch()['total'];
    
    // Total citas
    $stmt = $conn->query("SELECT COUNT(*) as total FROM citas");
    $totales['total_citas'] = $stmt->fetch()['total'];
    
    // Total ventas
    $stmt = $conn->query("SELECT COUNT(*) as total FROM ventas");
    $totales['total_ventas'] = $stmt->fetch()['total'];
    
    // Ventas por mes (últimos 6 meses)
    $stmt = $conn->query("
        SELECT 
            DATE_FORMAT(fecha_venta, '%Y-%m') as mes,
            COUNT(*) as cantidad,
            SUM(monto) as total
        FROM ventas
        WHERE fecha_venta >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
        GROUP BY mes
        ORDER BY mes DESC
    ");
    $totales['ventas_por_mes'] = $stmt->fetchAll();
    
    // Inventario por marca
    $stmt = $conn->query("
        SELECT 
            marca,
            COUNT(*) as cantidad
        FROM vehiculos
        GROUP BY marca
        ORDER BY cantidad DESC
    ");
    $totales['inventario_por_marca'] = $stmt->fetchAll();
    
    // Citas por estado
    $stmt = $conn->query("
        SELECT 
            estado,
            COUNT(*) as cantidad
        FROM citas
        GROUP BY estado
    ");
    $totales['citas_por_estado'] = $stmt->fetchAll();
    
    echo json_encode($totales);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
} 