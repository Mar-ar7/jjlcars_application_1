<?php
class Database {
    // Configuración de la base de datos
    private static $host = 'localhost';
    private static $db_name = 'jjlcars';
    private static $username = 'root';
    private static $password = '';
    private static $charset = 'utf8mb4';
    private static $connection = null;

    // Obtener conexión PDO
    public static function getConnection() {
        if (self::$connection === null) {
            try {
                $dsn = "mysql:host=" . self::$host . 
                       ";dbname=" . self::$db_name . 
                       ";charset=" . self::$charset;
                
                $options = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ];

                self::$connection = new PDO($dsn, self::$username, self::$password, $options);
                
                // Verificar conexión con una consulta simple
                self::$connection->query("SELECT 1");
                
                return self::$connection;
            } catch (PDOException $e) {
                error_log("Error de conexión: " . $e->getMessage());
                throw new Exception("Error de conexión a la base de datos");
            }
        }
        return self::$connection;
    }

    // Método para ejecutar consultas preparadas
    public static function executeQuery($sql, $params = []) {
        try {
            $stmt = self::getConnection()->prepare($sql);
            $stmt->execute($params);
            return $stmt;
        } catch (PDOException $e) {
            error_log("Error en la consulta: " . $e->getMessage());
            throw new Exception("Error al ejecutar la consulta");
        }
    }

    // Método para obtener un solo registro
    public static function fetchOne($sql, $params = []) {
        return self::executeQuery($sql, $params)->fetch();
    }

    // Método para obtener múltiples registros
    public static function fetchAll($sql, $params = []) {
        return self::executeQuery($sql, $params)->fetchAll();
    }

    // Método para insertar y obtener el último ID
    public static function insert($sql, $params = []) {
        self::executeQuery($sql, $params);
        return self::getConnection()->lastInsertId();
    }
} 