<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Método não permitido']);
    exit();
}

try {
    $searchTerm = $_GET['name'] ?? '';
    
    if (empty($searchTerm)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'Nome da imagem é obrigatório'
        ]);
        exit();
    }

    $databaseFile = 'image_database.json';
    $images = [];

    if (file_exists($databaseFile)) {
        $images = json_decode(file_get_contents($databaseFile), true) ?? [];
    }

    // Buscar imagem pelo nome (case insensitive)
    $foundImage = null;
    foreach ($images as $image) {
        $originalName = strtolower($image['original_name'] ?? '');
        $filename = strtolower($image['filename'] ?? '');
        $search = strtolower($searchTerm);
        
        if (strpos($originalName, $search) !== false || strpos($filename, $search) !== false) {
            // Verificar se a imagem ainda existe no servidor
            $imagePath = $image['upload_path'] ?? '';
            if (file_exists($imagePath)) {
                $foundImage = $image;
                break; // Para na primeira imagem encontrada
            }
        }
    }

    if ($foundImage) {
        // Construir URL completa da imagem
        $baseUrl = 'http://' . $_SERVER['HTTP_HOST'] . dirname($_SERVER['REQUEST_URI']);
        $foundImage['url'] = $baseUrl . '/' . $foundImage['upload_path'];
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Imagem encontrada',
            'data' => $foundImage
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Imagem não encontrada'
        ]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erro interno do servidor: ' . $e->getMessage()
    ]);
}
?>
