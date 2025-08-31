<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Log de todas as requisições
error_log("Debug Upload - Request received: " . json_encode([
    'method' => $_SERVER['REQUEST_METHOD'],
    'contentType' => $_SERVER['CONTENT_TYPE'] ?? 'not set',
    'contentLength' => $_SERVER['CONTENT_LENGTH'] ?? 'not set',
    'files' => isset($_FILES) ? array_keys($_FILES) : 'no files',
    'post' => array_keys($_POST)
]));

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método não permitido']);
    exit();
}

// Verificar se há arquivo
if (!isset($_FILES['image'])) {
    echo json_encode([
        'error' => 'Nenhum arquivo enviado',
        'debug' => [
            'files' => $_FILES,
            'post' => $_POST
        ]
    ]);
    exit();
}

$file = $_FILES['image'];

// Log detalhado do arquivo
error_log("Debug Upload - File Info: " . json_encode([
    'name' => $file['name'] ?? 'not set',
    'type' => $file['type'] ?? 'not set',
    'size' => $file['size'] ?? 'not set',
    'error' => $file['error'] ?? 'not set',
    'tmp_name' => $file['tmp_name'] ?? 'not set'
]));

// Verificar erro de upload
if ($file['error'] !== UPLOAD_ERR_OK) {
    $errorMessages = [
        UPLOAD_ERR_INI_SIZE => 'Arquivo excede upload_max_filesize',
        UPLOAD_ERR_FORM_SIZE => 'Arquivo excede MAX_FILE_SIZE',
        UPLOAD_ERR_PARTIAL => 'Upload parcial',
        UPLOAD_ERR_NO_FILE => 'Nenhum arquivo',
        UPLOAD_ERR_NO_TMP_DIR => 'Pasta temporária não encontrada',
        UPLOAD_ERR_CANT_WRITE => 'Erro ao escrever arquivo',
        UPLOAD_ERR_EXTENSION => 'Upload parado por extensão'
    ];
    
    echo json_encode([
        'error' => 'Erro no upload: ' . ($errorMessages[$file['error']] ?? 'Erro desconhecido'),
        'debug' => [
            'uploadError' => $file['error'],
            'fileInfo' => $file
        ]
    ]);
    exit();
}

$fileName = $file['name'];
$fileTmpName = $file['tmp_name'];
$fileSize = $file['size'];
$fileType = $file['type'];

// Verificar tipo MIME manualmente
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$detectedType = finfo_file($finfo, $fileTmpName);
finfo_close($finfo);

// Verificar extensão
$fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

// Tipos permitidos
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

echo json_encode([
    'success' => true,
    'message' => 'Análise de arquivo concluída',
    'debug' => [
        'fileName' => $fileName,
        'fileSize' => $fileSize,
        'fileType' => $fileType,
        'detectedType' => $detectedType,
        'fileExtension' => $fileExtension,
        'allowedTypes' => $allowedTypes,
        'allowedExtensions' => $allowedExtensions,
        'typeValid' => in_array($fileType, $allowedTypes),
        'detectedTypeValid' => in_array($detectedType, $allowedTypes),
        'extensionValid' => in_array($fileExtension, $allowedExtensions)
    ]
]);
?>
