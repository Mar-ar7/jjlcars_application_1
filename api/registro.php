<?php
session_start();
include('conexion.php');

// Disable displaying errors and log them instead for API endpoints
ini_set('display_errors', 1); // Temporarily enabled for debugging. REMEMBER TO CHANGE BACK TO 0!
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/php-error.log');
error_reporting(E_ALL);

$mensaje = "";
$tipo = "";
$redirigir = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Read and decode JSON input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    // Check if JSON decoding was successful and data exists
    if ($data === null) {
        // Log and return error if JSON is invalid
        error_log("Invalid JSON received in registro.php: " . $input);
        http_response_code(400); // Bad Request
        echo json_encode([
            'success' => false,
            'message' => 'Datos recibidos inválidos (JSON no válido)'
        ]);
        exit();
    }

    // Get data from the decoded JSON
    $usuario = $data['usuario'] ?? null;
    $nombre = $data['nombre'] ?? null;
    $password = $data['password'] ?? null;
    $tipoUsuario = $data['tipoUsuario'] ?? null;

    // Validate required fields
    if (empty($usuario) || empty($nombre) || empty($password) || empty($tipoUsuario)) {
         // Log missing data and return error
        error_log("Missing data in registro.php. Received: " . print_r($data, true));
        http_response_code(400); // Bad Request
        echo json_encode([
            'success' => false,
            'message' => 'Faltan datos requeridos (usuario, nombre, contraseña, tipoUsuario)'
        ]);
        exit();
    }

    // $tipoUsuario = "Usuario"; // Tipo fijo - REMOVED (already handled by getting from JSON)

    // Get TipoUsuario from POST data and validate - Logic already updated to use $data
    $allowedUserTypes = ['Usuario', 'Vendedor', 'Gerente', 'Administrador'];
    // $tipoUsuario = $_POST['tipoUsuario'] ?? ''; // Get type from POST, default to empty - REMOVED

    if (!in_array($tipoUsuario, $allowedUserTypes)) {
        // Default to 'Usuario' if the provided type is invalid or missing
        $tipoUsuario = 'Usuario';
         error_log("Invalid TipoUsuario received during registration: " . $tipoUsuario . ". Defaulting to 'Usuario'.");
    }

    // Hash de la contraseña antes de almacenarla
    // Ensure password is a string before hashing
    $hashed_password = password_hash((string)$password, PASSWORD_DEFAULT);

    // Get database connection using obtenerConexion function
    try {
         $conn = obtenerConexion();
    } catch (Exception $e) {
         // If connection fails, log and return error (obtenerConexion already handles JSON output)
         // The exception will be caught by the outer try-catch if not handled in obtenerConexion
         error_log("Database connection failed in registro.php: " . $e->getMessage());
         http_response_code(500);
         echo json_encode([
             'success' => false,
             'message' => 'Error interno del servidor (conexión a BD fallida)'
         ]);
         exit();
    }

    // Validar si el nombre de usuario ya existe
    $verificar_sql = "SELECT * FROM Usuarios WHERE Usuario = ?";
    $stmt_verificar = $conn->prepare($verificar_sql);
    $stmt_verificar->execute([$usuario]);

    // Check if a row was returned (user exists)
    $user_exists = $stmt_verificar->fetch();

    if ($user_exists) {
        $mensaje = "❌ El nombre de usuario ya está registrado. Intenta con otro.";
        $tipo = "error";
        // No redirigir aquí, solo preparar la respuesta JSON
    } else {
        $sql = "INSERT INTO Usuarios (Usuario, Nombre, password, TipoUsuario) VALUES (?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        
        // Execute the insert query (PDO method: pass parameters in an array to execute())
        // With PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, this will throw an exception on failure
        $stmt->execute([$usuario, $nombre, $hashed_password, $tipoUsuario]);

        // If execution reaches here, the insert was successful (no exception was thrown)
        $mensaje = "¡Registro exitoso! Ahora puedes iniciar sesión.";
        $tipo = "success";

        // No need for the if/else block checking $stmt->execute() again or $stmt->error
        // The success/error handling is done by the outer try-catch block
    }

    // Prepare the JSON response based on the registration result
    $response = [
        'success' => ($tipo === "success"),
        'message' => $mensaje,
    ];

    // Output JSON and terminate script
    echo json_encode($response);
    exit(); // Stop further execution (prevents HTML output)
}

// Handle GET requests or other methods (optional - currently shows HTML form)
// The following HTML and script will only be processed if the request method is NOT POST (e.g., GET from a browser)
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
        window.location.href = '<?php echo $redirigir; ?>'; // This part is for direct access, not API
    });
</script>
<?php endif; ?>

</body>
</html>
