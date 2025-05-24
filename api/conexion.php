<?php
class Conexion {
    private static $host = 'localhost';
    private static $db   = 'jjlcars';
    private static $user = 'root';
    private static $pass = '';  // Asegúrate de que esto coincida con tu configuración de MySQL
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
                
                // Verificar la conexión intentando una consulta simple
                self::$conexion->query("SELECT 1");
                
                return self::$conexion;
            } catch (PDOException $e) {
                error_log("Error de conexión a la base de datos: " . $e->getMessage());
                throw new Exception("Error de conexión a la base de datos: " . $e->getMessage());
            }
        }
        return self::$conexion;
    }

    // Método para probar la conexión
    public static function probarConexion() {
        try {
            $conexion = self::conectar();
            return [
                'status' => 'success',
                'message' => 'Conexión exitosa a la base de datos'
            ];
        } catch (Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
}

function obtenerConexion() {
    try {
        return Conexion::conectar();
    } catch (Exception $e) {
        error_log("Error en obtenerConexion(): " . $e->getMessage());
        throw new Exception("Error al establecer la conexión con la base de datos: " . $e->getMessage());
    }
}
?> 