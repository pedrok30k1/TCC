<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Permitir requisições OPTIONS para CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Verificar se é uma requisição POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método não permitido']);
    exit();
}

// Verificar se há um arquivo enviado
if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['error' => 'Nenhuma imagem foi enviada ou erro no upload']);
    exit();
}

// Obter informações do arquivo
$file = $_FILES['image'];
$fileName = $file['name'];
$fileTmpName = $file['tmp_name'];
$fileSize = $file['size'];
$fileError = $file['error'];
$fileType = $file['type'];

// Verificar se é realmente uma imagem
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
$fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

// Log para debug
error_log("Debug - File Info: " . json_encode([
    'fileName' => $fileName,
    'fileType' => $fileType,
    'fileExtension' => $fileExtension,
    'fileSize' => $fileSize
]));

// Verificar por extensão e tipo MIME (aceitar se extensão for válida)
if (!in_array($fileExtension, $allowedExtensions)) {
    http_response_code(400);
    echo json_encode([
        'error' => 'Tipo de arquivo não permitido. Apenas imagens são aceitas.',
        'debug' => [
            'receivedType' => $fileType,
            'receivedExtension' => $fileExtension,
            'allowedTypes' => $allowedTypes
        ]
    ]);
    exit();
}

// Verificar tamanho do arquivo (máximo 10MB)
$maxSize = 10 * 1024 * 1024; // 10MB em bytes
if ($fileSize > $maxSize) {
    http_response_code(400);
    echo json_encode(['error' => 'Arquivo muito grande. Máximo permitido: 10MB']);
    exit();
}

// Criar pasta de uploads se não existir
$uploadDir = 'uploads/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// Gerar nome único para o arquivo
$fileExtension = pathinfo($fileName, PATHINFO_EXTENSION);
$uniqueFileName = uniqid() . '_' . time() . '.' . $fileExtension;
$uploadPath = $uploadDir . $uniqueFileName;

// Mover arquivo para a pasta
if (move_uploaded_file($fileTmpName, $uploadPath)) {
    // Obter dados extras enviados
    $userId = $_POST['user_id'] ?? 'unknown';
    $description = $_POST['description'] ?? 'Sem descrição';
    
    // Criar registro no banco de dados (opcional)
    $imageData = [
        'id' => uniqid(),
        'filename' => $uniqueFileName,
        'original_name' => $fileName,
        'file_size' => $fileSize,
        'file_type' => $fileType,
        'upload_path' => $uploadPath,
        'user_id' => $userId,
        'description' => $description,
        'upload_date' => date('Y-m-d H:i:s'),
                 'url' => 'http://' . $_SERVER['HTTP_HOST'] . '/textImg/' . $uploadPath
    ];
    
    // Salvar informações em um arquivo JSON (simulando banco de dados)
    $databaseFile = 'image_database.json';
    $database = [];
    
    if (file_exists($databaseFile)) {
        $database = json_decode(file_get_contents($databaseFile), true) ?? [];
    }
    
    $database[] = $imageData;
    file_put_contents($databaseFile, json_encode($database, JSON_PRETTY_PRINT));
    
    // Retornar sucesso
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Imagem enviada com sucesso!',
        'data' => $imageData
    ]);
    
} else {
    // Erro ao mover arquivo
    http_response_code(500);
    echo json_encode(['error' => 'Erro ao salvar a imagem no servidor']);
}

// Função para limpar arquivos antigos (opcional)
function cleanOldFiles($uploadDir, $daysOld = 30) {
    if (!is_dir($uploadDir)) return;
    
    $files = glob($uploadDir . '*');
    $now = time();
    
    foreach ($files as $file) {
        if (is_file($file)) {
            if ($now - filemtime($file) >= $daysOld * 24 * 60 * 60) {
                unlink($file);
            }
        }
    }
}

// Executar limpeza de arquivos antigos (uma vez por dia)
$cleanupFile = 'last_cleanup.txt';
$lastCleanup = file_exists($cleanupFile) ? file_get_contents($cleanupFile) : 0;

if (time() - $lastCleanup > 24 * 60 * 60) { // 24 horas
    cleanOldFiles($uploadDir);
    file_put_contents($cleanupFile, time());
}
?>
