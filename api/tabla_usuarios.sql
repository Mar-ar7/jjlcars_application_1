-- Crear la tabla usuarios si no existe
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    TipoUsuario ENUM('Administrador', 'Gerente', 'Vendedor') NOT NULL DEFAULT 'Vendedor',
    estado ENUM('Disponible', 'Atendiendo', 'Ausente', 'Fuera de oficina') NOT NULL DEFAULT 'Disponible',
    estado_mensaje TEXT,
    estado_hasta DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insertar un usuario administrador por defecto (contraseña: admin123)
INSERT INTO usuarios (Nombre, Email, Password, TipoUsuario) 
VALUES ('Administrador', 'admin@jjlcars.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador')
ON DUPLICATE KEY UPDATE id=id; 