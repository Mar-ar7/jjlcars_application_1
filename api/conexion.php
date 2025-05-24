<?php
class Conexion {
    private static $host = 'localhost';
    private static $db   = 'jjlcars';
    private static $user = 'root';
    private static $pass = '';
    private static $charset = 'utf8mb4';
    private static $conexion = null;

    public static function conectar() {
        if (self::$conexion === null) {
            try {
                $dsn = "mysql:host=" . self::$host . ";dbname=" . self::$db . ";charset=" . self::$charset;
                $opciones = [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ];

                self::$conexion = new PDO($dsn, self::$user, self::$pass, $opciones);
            } catch (PDOException $e) {
                throw new Exception('Error de conexión: ' . $e->getMessage());
            }
        }
        return self::$conexion;
    }
}

// Para los nuevos archivos que necesitan la conexión directa
function obtenerConexion() {
    try {
        $conn = Conexion::conectar();
        return $conn;
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
        die();
    }
}
?> 