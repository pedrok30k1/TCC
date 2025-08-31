<?php
// Carregar dados do banco de dados
$databaseFile = 'image_database.json';
$images = [];

if (file_exists($databaseFile)) {
    $images = json_decode(file_get_contents($databaseFile), true) ?? [];
}

// Ordenar por data de upload (mais recente primeiro)
usort($images, function($a, $b) {
    return strtotime($b['upload_date']) - strtotime($a['upload_date']);
});
?>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visualizar Imagens</title>
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
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            text-align: center;
        }
        .stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
        }
        .stat {
            text-align: center;
        }
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #007bff;
        }
        .stat-label {
            color: #666;
        }
        .gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .image-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.3s;
        }
        .image-card:hover {
            transform: translateY(-5px);
        }
        .image-container {
            position: relative;
            height: 200px;
            overflow: hidden;
        }
        .image-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .image-info {
            padding: 15px;
        }
        .image-title {
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .image-details {
            font-size: 0.9em;
            color: #666;
            line-height: 1.4;
        }
        .image-actions {
            padding: 15px;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: space-between;
        }
        .btn {
            background-color: #007bff;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9em;
        }
        .btn:hover {
            background-color: #0056b3;
        }
        .btn-danger {
            background-color: #dc3545;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .empty-state img {
            width: 100px;
            opacity: 0.5;
            margin-bottom: 20px;
        }
        .refresh-btn {
            background-color: #28a745;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin: 10px;
        }
        .refresh-btn:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖼️ Galeria de Imagens</h1>
        <p>Visualize todas as imagens enviadas para o servidor</p>
        
        <div class="stats">
            <div class="stat">
                <div class="stat-number"><?php echo count($images); ?></div>
                <div class="stat-label">Total de Imagens</div>
            </div>
            <div class="stat">
                <div class="stat-number"><?php echo formatBytes(array_sum(array_column($images, 'file_size'))); ?></div>
                <div class="stat-label">Espaço Total</div>
            </div>
            <div class="stat">
                <div class="stat-number"><?php echo date('d/m/Y'); ?></div>
                <div class="stat-label">Data Atual</div>
            </div>
        </div>

        <button class="refresh-btn" onclick="location.reload()">🔄 Atualizar</button>
        <a href="test_upload.html" class="btn">📤 Enviar Nova Imagem</a>
    </div>

    <?php if (empty($images)): ?>
        <div class="empty-state">
            <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIiBmaWxsPSIjRjVGNUY1Ii8+CjxwYXRoIGQ9Ik0yNSAyNUg3NVY3NUgyNVoiIGZpbGw9IiNDQ0NDQ0MiLz4KPHBhdGggZD0iTTMwIDMwSDcwVjUwSDMwWiIgZmlsbD0iI0NDQ0NDQyIvPgo8Y2lyY2xlIGN4PSI0MCIgY3k9IjQwIiByPSI1IiBmaWxsPSIjQ0NDQ0NDIi8+Cjwvc3ZnPgo=" alt="No images">
            <h2>Nenhuma imagem encontrada</h2>
            <p>Envie sua primeira imagem usando o botão acima!</p>
        </div>
    <?php else: ?>
        <div class="gallery">
            <?php foreach ($images as $image): ?>
                <div class="image-card">
                    <div class="image-container">
                        <img src="<?php echo htmlspecialchars($image['url']); ?>" 
                             alt="<?php echo htmlspecialchars($image['original_name']); ?>"
                             onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDMwMCAyMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIzMDAiIGhlaWdodD0iMjAwIiBmaWxsPSIjRjVGNUY1Ii8+Cjx0ZXh0IHg9IjE1MCIgeT0iMTAwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBkeT0iLjNlbSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjE0IiBmaWxsPSIjOTk5OTk5Ij5JbWFnZW0gbsOjbyBlbmNvbnRyYWRhPC90ZXh0Pgo8L3N2Zz4K';">
                    </div>
                    <div class="image-info">
                        <div class="image-title"><?php echo htmlspecialchars($image['original_name']); ?></div>
                        <div class="image-details">
                            <strong>ID:</strong> <?php echo htmlspecialchars($image['id']); ?><br>
                            <strong>Tamanho:</strong> <?php echo formatBytes($image['file_size']); ?><br>
                            <strong>Formato:</strong> <?php echo htmlspecialchars($image['file_type']); ?><br>
                            <strong>Usuário:</strong> <?php echo htmlspecialchars($image['user_id']); ?><br>
                            <strong>Data:</strong> <?php echo date('d/m/Y H:i', strtotime($image['upload_date'])); ?><br>
                            <?php if (!empty($image['description'])): ?>
                                <strong>Descrição:</strong> <?php echo htmlspecialchars($image['description']); ?>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="image-actions">
                        <a href="<?php echo htmlspecialchars($image['url']); ?>" 
                           target="_blank" 
                           class="btn">👁️ Ver Original</a>
                        <button class="btn btn-danger" 
                                onclick="deleteImage('<?php echo htmlspecialchars($image['id']); ?>')">🗑️ Deletar</button>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>

    <script>
        function deleteImage(imageId) {
            if (confirm('Tem certeza que deseja deletar esta imagem?')) {
                // Aqui você pode implementar a lógica de deletar
                alert('Funcionalidade de deletar será implementada!');
            }
        }

        // Auto-refresh a cada 30 segundos
        setTimeout(() => {
            location.reload();
        }, 30000);
    </script>
</body>
</html>

<?php
function formatBytes($bytes, $precision = 2) {
    $units = array('B', 'KB', 'MB', 'GB', 'TB');
    
    for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
        $bytes /= 1024;
    }
    
    return round($bytes, $precision) . ' ' . $units[$i];
}
?>
