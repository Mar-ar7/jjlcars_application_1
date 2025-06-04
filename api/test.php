<?php
require_once 'cors_config.php';
error_log('Test endpoint called');
echo json_encode(['status' => 'ok', 'message' => 'API funcionando correctamente']);
?>