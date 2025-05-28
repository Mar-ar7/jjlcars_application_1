<?php
define('DB_HOST', 'localhost');
define('DB_NAME', 'jjlcars');
define('DB_USER', 'root');
define('DB_PASS', '');

function getConnection() {
    try {
        $conexion = new PDO(
            'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
            DB_USER,
            DB_PASS,
            array(
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            )
        );
        return $conexion;
    } catch (PDOException $e) {
        error_log("Error de conexión: " . $e->getMessage());
        throw new Exception("Error de conexión a la base de datos");
    }
} 