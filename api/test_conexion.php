<?php
header('Content-Type: application/json; charset=UTF-8');
require_once 'conexion.php';

$resultado = Conexion::probarConexion();
echo json_encode($resultado); 