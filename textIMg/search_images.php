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

    // Parâmetros de busca
    $searchTerm = $_GET['search'] ?? '';
    $userId = $_GET['user_id'] ?? '';
    $fileType = $_GET['file_type'] ?? '';
    $dateFrom = $_GET['date_from'] ?? '';
    $dateTo = $_GET['date_to'] ?? '';
    $minSize = $_GET['min_size'] ?? 0;
    $maxSize = $_GET['max_size'] ?? PHP_INT_MAX;
    $limit = $_GET['limit'] ?? 50;
    $offset = $_GET['offset'] ?? 0;

    // Filtrar imagens baseado nos critérios
    $filteredImages = array_filter($images, function($image) use ($searchTerm, $userId, $fileType, $dateFrom, $dateTo, $minSize, $maxSize) {
        // Busca por nome
        if (!empty($searchTerm)) {
            $originalName = strtolower($image['original_name'] ?? '');
            $filename = strtolower($image['filename'] ?? '');
            $description = strtolower($image['description'] ?? '');
            $search = strtolower($searchTerm);
            
            if (strpos($originalName, $search) === false && 
                strpos($filename, $search) === false && 
                strpos($description, $search) === false) {
                return false;
            }
        }

        // Filtro por usuário
        if (!empty($userId) && ($image['user_id'] ?? '') !== $userId) {
            return false;
        }

        // Filtro por tipo de arquivo
        if (!empty($fileType) && ($image['file_type'] ?? '') !== $fileType) {
            return false;
        }

        // Filtro por data
        if (!empty($dateFrom) || !empty($dateTo)) {
            $uploadDate = strtotime($image['upload_date'] ?? '');
            
            if (!empty($dateFrom) && $uploadDate < strtotime($dateFrom)) {
                return false;
            }
            
            if (!empty($dateTo) && $uploadDate > strtotime($dateTo)) {
                return false;
            }
        }

        // Filtro por tamanho
        $fileSize = $image['file_size'] ?? 0;
        if ($fileSize < $minSize || $fileSize > $maxSize) {
            return false;
        }

        return true;
    });

    // Verificar se as imagens ainda existem no servidor
    $validImages = [];
    foreach ($filteredImages as $image) {
        $imagePath = $image['upload_path'] ?? '';
        if (file_exists($imagePath)) {
            $validImages[] = $image;
        }
    }

    // Ordenar por data de upload (mais recente primeiro)
    usort($validImages, function($a, $b) {
        return strtotime($b['upload_date']) - strtotime($a['upload_date']);
    });

    // Aplicar paginação
    $total = count($validImages);
    $validImages = array_slice($validImages, $offset, $limit);

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Busca realizada com sucesso',
        'data' => $validImages,
        'total' => $total,
        'limit' => $limit,
        'offset' => $offset,
        'has_more' => ($offset + $limit) < $total,
        'search_params' => [
            'search_term' => $searchTerm,
            'user_id' => $userId,
            'file_type' => $fileType,
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'min_size' => $minSize,
            'max_size' => $maxSize
        ]
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erro interno do servidor: ' . $e->getMessage()
    ]);
}
?>
