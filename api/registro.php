<?php
session_start();
include('conexion.php');

$mensaje = "";
$tipo = "";
$redirigir = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $usuario = $_POST['usuario'];
    $nombre = $_POST['nombre'];
    $password = $_POST['password'];
    $tipoUsuario = "Usuario"; // Tipo fijo

    // Validar si el nombre de usuario ya existe
    $verificar_sql = "SELECT * FROM Usuarios WHERE Usuario = ?";
    $stmt_verificar = $conn->prepare($verificar_sql);
    $stmt_verificar->bind_param("s", $usuario);
    $stmt_verificar->execute();
    $resultado = $stmt_verificar->get_result();

    if ($resultado->num_rows > 0) {
        $mensaje = "❌ El nombre de usuario ya está registrado. Intenta con otro.";
        $tipo = "error";
        $redirigir = "registro.php";
    } else {
        $sql = "INSERT INTO Usuarios (Usuario, Nombre, password, TipoUsuario) VALUES (?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssss", $usuario, $nombre, $password, $tipoUsuario);

        if ($stmt->execute()) {
            $mensaje = "¡Registro exitoso! Ahora puedes iniciar sesión.";
            $tipo = "success";
            $redirigir = "login.php";
        } else {
            $mensaje = "Error al registrar: " . $stmt->error;
            $tipo = "error";
            $redirigir = "registro.php";
        }

        $stmt->close();
    }

    $stmt_verificar->close();
    $conn->close();
}
?>



<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registrarse</title>
    <link rel="stylesheet" href="css/login.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- Video de fondo -->
<video autoplay muted loop class="background-video">
    <source src="imagen/RegistroFondo.mp4" type="video/mp4">
</video>

<section class="login-container">
    <h2>Crear Cuenta</h2>
    <form method="post" class="login-form">
    <div class="form-group">
        <label for="usuario">Correo:</label>
        <input type="text" name="usuario" required>
    </div>

    <div class="form-group">
        <label for="nombre">Id Usuario:</label>
        <input type="text" name="nombre" required>
    </div>

    <div class="form-group">
        <label for="password">Contraseña:</label>
        <input type="password" name="password" required>
    </div>

    <button type="submit" class="login-button">Registrarse</button>

    <div class="registro-link">
        ¿Ya tienes cuenta? <a href="login.php">Inicia sesión</a>
    </div>
</form>

</section>

<script>
function mostrarClaveAdmin() {
    const tipo = document.getElementById('tipo_usuario').value;
    const adminField = document.getElementById('clave_admin_group');
    adminField.style.display = (tipo === 'Administrador') ? 'block' : 'none';
}
</script>

<?php if (!empty($mensaje)): ?>
<script>
    Swal.fire({
        title: '<?php echo ($tipo === "success") ? "Éxito" : "Error"; ?>',
        text: '<?php echo $mensaje; ?>',
        icon: '<?php echo $tipo; ?>',
        confirmButtonText: 'Aceptar'
    }).then(() => {
        window.location.href = '<?php echo $redirigir; ?>';
    });
</script>
<?php endif; ?>

</body>
</html>
