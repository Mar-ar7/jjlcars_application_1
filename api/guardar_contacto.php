<?php
$conexion = new mysqli("localhost", "root", "", "jjlcars");

if ($conexion->connect_error) {
    die("Error en la conexión: " . $conexion->connect_error);
}

$nombre = $_POST['nombre'] ?? '';
$correo = $_POST['correo'] ?? '';
$mensaje = $_POST['mensaje'] ?? '';

if ($nombre && $correo && $mensaje) {
    $stmt = $conexion->prepare("INSERT INTO contacto (nombre, correo, mensaje) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $nombre, $correo, $mensaje);
    if ($stmt->execute()) {
        echo "ok";
    } else {
        echo "Error al guardar";
    }
    $stmt->close();
} else {
    echo "Datos incompletos";
}

$conexion->close();
?>
