<?php
header('Content-Type: text/html; charset=UTF-8');
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Debug - Imagens Salvas</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .header {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .debug-info {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .image-list {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .image-item {
            border: 1px solid #ddd;
            margin: 10px 0;
            padding: 15px;
            border-radius: 4px;
        }
        .image-preview {
            max-width: 200px;
            max-height: 200px;
            border: 1px solid #ddd;
            margin: 10px 0;
        }
        .error {
            color: red;
            background: #ffe6e6;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .success {
            color: green;
            background: #e6ffe6;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        pre {
            background: #f8f8f8;
            padding: 10px;
            border-radius: 4px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 Debug - Imagens Salvas</h1>
        <p>Verificando as imagens salvas no sistema</p>
    </div>

    <?php
    // Verificar se o arquivo de banco de dados existe
    $databaseFile = 'image_database.json';
    $uploadDir = 'uploads/';
    
    echo '<div class="debug-info">';
    echo '<h2>Informações do Sistema</h2>';
    echo '<p><strong>Arquivo de banco:</strong> ' . ($databaseFile) . ' - ' . (file_exists($databaseFile) ? '✅ Existe' : '❌ Não existe') . '</p>';
    echo '<p><strong>Pasta de uploads:</strong> ' . ($uploadDir) . ' - ' . (file_exists($uploadDir) ? '✅ Existe' : '❌ Não existe') . '</p>';
    echo '<p><strong>Servidor:</strong> ' . $_SERVER['HTTP_HOST'] . '</p>';
    echo '<p><strong>Caminho:</strong> ' . $_SERVER['REQUEST_URI'] . '</p>';
    echo '</div>';

    if (file_exists($databaseFile)) {
        $images = json_decode(file_get_contents($databaseFile), true) ?? [];
        
        echo '<div class="debug-info">';
        echo '<h2>Banco de Dados JSON</h2>';
        echo '<pre>' . json_encode($images, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . '</pre>';
        echo '</div>';

        echo '<div class="image-list">';
        echo '<h2>Lista de Imagens (' . count($images) . ')</h2>';
        
        if (empty($images)) {
            echo '<div class="error">Nenhuma imagem encontrada no banco de dados</div>';
        } else {
            foreach ($images as $index => $image) {
                echo '<div class="image-item">';
                echo '<h3>Imagem ' . ($index + 1) . '</h3>';
                echo '<p><strong>ID:</strong> ' . ($image['id'] ?? 'N/A') . '</p>';
                echo '<p><strong>Nome Original:</strong> ' . ($image['original_name'] ?? 'N/A') . '</p>';
                echo '<p><strong>Arquivo:</strong> ' . ($image['filename'] ?? 'N/A') . '</p>';
                echo '<p><strong>Caminho:</strong> ' . ($image['upload_path'] ?? 'N/A') . '</p>';
                echo '<p><strong>URL:</strong> ' . ($image['url'] ?? 'N/A') . '</p>';
                echo '<p><strong>Tamanho:</strong> ' . number_format($image['file_size'] ?? 0) . ' bytes</p>';
                echo '<p><strong>Data:</strong> ' . ($image['upload_date'] ?? 'N/A') . '</p>';
                
                // Verificar se o arquivo físico existe
                $filePath = $image['upload_path'] ?? '';
                $fileExists = file_exists($filePath);
                echo '<p><strong>Arquivo físico:</strong> ' . ($fileExists ? '✅ Existe' : '❌ Não existe') . '</p>';
                
                if ($fileExists) {
                    echo '<p><strong>Tamanho real:</strong> ' . number_format(filesize($filePath)) . ' bytes</p>';
                    echo '<p><strong>Última modificação:</strong> ' . date('Y-m-d H:i:s', filemtime($filePath)) . '</p>';
                }
                
                // Tentar mostrar preview da imagem
                if ($fileExists) {
                    $imageUrl = 'http://' . $_SERVER['HTTP_HOST'] . '/textImg/' . $filePath;
                    echo '<p><strong>URL de teste:</strong> <a href="' . $imageUrl . '" target="_blank">' . $imageUrl . '</a></p>';
                    echo '<img src="' . $imageUrl . '" alt="Preview" class="image-preview" onerror="this.style.display=\'none\'; this.nextElementSibling.style.display=\'block\';" onload="this.nextElementSibling.style.display=\'none\';">';
                    echo '<div style="display:none; color:red;">❌ Erro ao carregar imagem</div>';
                }
                
                echo '</div>';
            }
        }
        echo '</div>';
    } else {
        echo '<div class="error">Arquivo de banco de dados não encontrado: ' . $databaseFile . '</div>';
    }

    // Verificar arquivos na pasta uploads
    if (file_exists($uploadDir)) {
        echo '<div class="debug-info">';
        echo '<h2>Arquivos na Pasta Uploads</h2>';
        $files = glob($uploadDir . '*');
        if (empty($files)) {
            echo '<div class="error">Nenhum arquivo encontrado na pasta uploads</div>';
        } else {
            echo '<ul>';
            foreach ($files as $file) {
                $fileInfo = pathinfo($file);
                $fileSize = filesize($file);
                $fileDate = date('Y-m-d H:i:s', filemtime($file));
                echo '<li>';
                echo '<strong>' . $fileInfo['basename'] . '</strong><br>';
                echo 'Tamanho: ' . number_format($fileSize) . ' bytes<br>';
                echo 'Data: ' . $fileDate;
                echo '</li>';
            }
            echo '</ul>';
        }
        echo '</div>';
    }
    ?>
</body>
</html>
