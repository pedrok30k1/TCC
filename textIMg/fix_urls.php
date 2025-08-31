<?php
// Script para corrigir URLs das imagens existentes
header('Content-Type: text/html; charset=UTF-8');

$databaseFile = 'image_database.json';

if (!file_exists($databaseFile)) {
    echo "Arquivo de banco de dados não encontrado!";
    exit();
}

$images = json_decode(file_get_contents($databaseFile), true) ?? [];
$fixed = false;

echo "<h1>Corrigindo URLs das Imagens</h1>";

foreach ($images as &$image) {
    $oldUrl = $image['url'];
    $newUrl = 'http://' . $_SERVER['HTTP_HOST'] . '/textImg/' . $image['upload_path'];
    
    if ($oldUrl !== $newUrl) {
        echo "<p>❌ URL incorreta: $oldUrl</p>";
        echo "<p>✅ URL corrigida: $newUrl</p>";
        echo "<hr>";
        
        $image['url'] = $newUrl;
        $fixed = true;
    }
}

if ($fixed) {
    file_put_contents($databaseFile, json_encode($images, JSON_PRETTY_PRINT));
    echo "<h2>✅ URLs corrigidas com sucesso!</h2>";
    echo "<p><a href='get_images.php'>Testar API</a></p>";
} else {
    echo "<h2>✅ Todas as URLs já estão corretas!</h2>";
}
?>
