<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método não permitido']);
    exit();
}

if (!isset($_POST['image_id']) || empty($_POST['image_id'])) {
    http_response_code(400);
    echo json_encode(['error' => 'ID da imagem não fornecido']);
    exit();
}

$imageId = $_POST['image_id'];

try {
    $databaseFile = 'image_database.json';
    $images = [];

    if (file_exists($databaseFile)) {
        $images = json_decode(file_get_contents($databaseFile), true) ?? [];
    }

    // Encontrar a imagem pelo ID
    $imageToDelete = null;
    foreach ($images as $image) {
        if ($image['id'] === $imageId) {
            $imageToDelete = $image;
            break;
        }
    }

    if (!$imageToDelete) {
        http_response_code(404);
        echo json_encode(['error' => 'Imagem não encontrada']);
        exit();
    }

    // Deletar o arquivo físico
    $imagePath = $imageToDelete['upload_path'];
    if (file_exists($imagePath)) {
        if (!unlink($imagePath)) {
            http_response_code(500);
            echo json_encode(['error' => 'Erro ao deletar arquivo físico']);
            exit();
        }
    }

    // Remover do banco de dados
    $images = array_filter($images, function($image) use ($imageId) {
        return $image['id'] !== $imageId;
    });

    file_put_contents($databaseFile, json_encode(array_values($images), JSON_PRETTY_PRINT));

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Imagem deletada com sucesso',
        'deleted_image' => $imageToDelete
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erro interno do servidor: ' . $e->getMessage()
    ]);
}
?>
