<?php
$conexion = new mysqli("localhost", "root", "", "jjlcars");

if ($conexion->connect_error) {
    die("Conexión fallida: " . $conexion->connect_error);
}

$tipoCita = $_POST['tipoCita'] ?? '';
$nombre = $_POST['nombre'] ?? '';
$correo = $_POST['correo'] ?? '';
$fecha = $_POST['fecha'] ?? '';
$hora = $_POST['hora'] ?? '';

// Asegúrate de que tu tabla 'citas' tenga una columna llamada 'tipoCita'
$sql = "INSERT INTO citas (tipoCita, nombre, correo, fecha, hora) VALUES (?, ?, ?, ?, ?)";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("sssss", $tipoCita, $nombre, $correo, $fecha, $hora);

if ($stmt->execute()) {
    echo "Cita agendada exitosamente.";
} else {
    echo "Error al agendar la cita: " . $stmt->error;
}

$stmt->close();
$conexion->close();
?>
