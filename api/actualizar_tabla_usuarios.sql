-- Agregar las nuevas columnas a la tabla usuarios existente
ALTER TABLE usuarios
ADD COLUMN estado ENUM('Disponible', 'Atendiendo', 'Ausente', 'Fuera de oficina') NOT NULL DEFAULT 'Disponible' AFTER TipoUsuario,
ADD COLUMN estado_mensaje TEXT NULL AFTER estado,
ADD COLUMN estado_hasta DATETIME NULL AFTER estado_mensaje; 