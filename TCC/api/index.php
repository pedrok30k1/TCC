<?php
header('Access-Control-Allow-Origin: *');
header('Content-type: application/json');

date_default_timezone_set("America/Sao_Paulo");

if (isset($_GET['path'])){$path = explode('/', $_GET['path']);} else { echo "caminho não informado"; exit;}
if(isset($path[0])){ $api = $path[0];} else { echo "caminho não informado"; exit;}
if(isset($path[1])){ $acao = $path[1];} else { $acao =  "";}
if(isset($path[2])){ $param = $path[2];} else { $param = null;}

$method = $_SERVER['REQUEST_METHOD'];
include_once "classes/db.class.php";
include_once "api/Usuario/Usuario.php";
include_once "api/Card/Card.php";
include_once "api/Mensagem/Mensagem.php";
include_once "api/Categoria/Categoria.php";
include_once "api/Imagem/Imagem.php";
