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
    $databaseFile = 'image_database.json';
    $images = [];

    if (file_exists($databaseFile)) {
        $images = json_decode(file_get_contents($databaseFile), true) ?? [];
    }

    // Verificar se há parâmetro de busca
    $searchTerm = $_GET['search'] ?? '';
    
    // Filtrar imagens por nome se houver termo de busca
    if (!empty($searchTerm)) {
        $images = array_filter($images, function($image) use ($searchTerm) {
            $originalName = strtolower($image['original_name'] ?? '');
            $filename = strtolower($image['filename'] ?? '');
            $search = strtolower($searchTerm);
            
            return strpos($originalName, $search) !== false || 
                   strpos($filename, $search) !== false;
        });
        
        $images = array_values($images); // Reindexar array
    }

    // Ordenar por data de upload (mais recente primeiro)
    usort($images, function($a, $b) {
        return strtotime($b['upload_date']) - strtotime($a['upload_date']);
    });

    // Verificar se as imagens ainda existem no servidor
    $validImages = [];
    foreach ($images as $image) {
        $imagePath = $image['upload_path'] ?? '';
        if (file_exists($imagePath)) {
            $validImages[] = $image;
        } else {
            // Se a imagem não existe mais, remover do banco de dados
            $images = array_filter($images, function($img) use ($image) {
                return $img['id'] !== $image['id'];
            });
            file_put_contents($databaseFile, json_encode(array_values($images), JSON_PRETTY_PRINT));
        }
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Imagens carregadas com sucesso',
        'images' => $validImages,
        'total' => count($validImages)
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erro interno do servidor: ' . $e->getMessage()
    ]);
}
?>
