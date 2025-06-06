<?php
require_once 'conexion.php';
if ($conn) {
    echo "Conexión exitosa";
} else {
    echo "Fallo la conexión";
}
?>