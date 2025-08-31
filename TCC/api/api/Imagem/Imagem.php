<?php
// Endpoints: imagem/upload (POST, multipart), imagem/listar (GET), imagem/deletar (POST JSON)

if ($api === 'imagem') {
    $uploadsDir = __DIR__ . '/../../../../textIMg/uploads';
    $dbJsonPath = __DIR__ . '/../../../../textIMg/image_database.json';

    if (!file_exists($uploadsDir)) {
        @mkdir($uploadsDir, 0777, true);
    }
    if (!file_exists($dbJsonPath)) {
        @file_put_contents($dbJsonPath, json_encode([]));
    }

    if ($method === 'POST' && $acao === 'upload') {
        header('Content-Type: application/json');
        try {
            if (!isset($_FILES['image'])) {
                echo json_encode(['status' => 'error', 'message' => 'Arquivo não enviado']);
                exit;
            }

            $file = $_FILES['image'];
            if ($file['error'] !== UPLOAD_ERR_OK) {
                echo json_encode(['status' => 'error', 'message' => 'Erro no upload: ' . $file['error']]);
                exit;
            }

            $allowed = ['jpg','jpeg','png','gif','webp'];
            $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
            if (!in_array($ext, $allowed)) {
                echo json_encode(['status' => 'error', 'message' => 'Tipo de arquivo não permitido']);
                exit;
            }

            $unique = uniqid('', true) . '_' . time();
            $safeName = preg_replace('/[^a-zA-Z0-9-_\.]/', '_', basename($file['name']));
            $finalName = $unique . '_' . $safeName;
            $destPath = $uploadsDir . '/' . $finalName;

            if (!move_uploaded_file($file['tmp_name'], $destPath)) {
                echo json_encode(['status' => 'error', 'message' => 'Falha ao salvar arquivo']);
                exit;
            }

            $userId = isset($_POST['user_id']) ? $_POST['user_id'] : 'unknown';
            $description = isset($_POST['description']) ? $_POST['description'] : '';

            $size = filesize($destPath);
            $mime = mime_content_type($destPath);
            $uploadRelPath = 'textIMg/uploads/' . $finalName;

            $record = [
                'id' => $unique,
                'original_name' => $file['name'],
                'file_name' => $finalName,
                'file_size' => $size,
                'file_type' => $mime,
                'upload_path' => $uploadRelPath,
                'user_id' => $userId,
                'description' => $description,
                'upload_date' => date('Y-m-d H:i:s'),
                'url' => null,
            ];

            $db = json_decode(@file_get_contents($dbJsonPath), true);
            if (!is_array($db)) { $db = []; }
            $db[] = $record;
            file_put_contents($dbJsonPath, json_encode($db, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE));

            echo json_encode([
                'status' => 'success',
                'message' => 'Upload realizado com sucesso',
                'data' => $record,
            ]);
            exit;
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
            exit;
        }
    }

    if ($method === 'GET' && $acao === 'listar') {
        header('Content-Type: application/json');
        $db = json_decode(@file_get_contents($dbJsonPath), true);
        if (!is_array($db)) { $db = []; }
        echo json_encode(['status' => 'success', 'data' => $db]);
        exit;
    }

    if ($method === 'POST' && $acao === 'deletar') {
        header('Content-Type: application/json');
        $payload = json_decode(file_get_contents('php://input'), true);
        $imageId = isset($payload['image_id']) ? $payload['image_id'] : null;
        if (!$imageId) {
            echo json_encode(['status' => 'error', 'message' => 'image_id é obrigatório']);
            exit;
        }

        $db = json_decode(@file_get_contents($dbJsonPath), true);
        if (!is_array($db)) { $db = []; }
        $newDb = [];
        $found = null;
        foreach ($db as $item) {
            if (isset($item['id']) && $item['id'] == $imageId) {
                $found = $item;
                continue;
            }
            $newDb[] = $item;
        }

        if ($found) {
            @unlink(__DIR__ . '/../../../../' . $found['upload_path']);
            file_put_contents($dbJsonPath, json_encode($newDb, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE));
            echo json_encode(['status' => 'success', 'message' => 'Imagem deletada']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Imagem não encontrada']);
        }
        exit;
    }
}

?>


