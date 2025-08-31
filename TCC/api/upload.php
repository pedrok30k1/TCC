<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_POST["folder_name"]) && isset($_FILES["files"])) {
        $folder_name = preg_replace('/[^a-zA-Z0-9_-]/', '', $_POST["folder_name"]); // Remove caracteres especiais
        $files = $_FILES["files"];
        $upload_dir = "img/" . $folder_name . "/";
        
        // Cria o diretório se não existir
        if (!file_exists($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }

        $success_count = 0;
        $error_count = 0;
        $errors = [];

        // Processa cada arquivo
        for ($i = 0; $i < count($files["name"]); $i++) {
            $file_name = $files["name"][$i];
            $file_tmp = $files["tmp_name"][$i];
            $file_size = $files["size"][$i];
            $file_error = $files["error"][$i];

            // Verifica se houve erro no upload
            if ($file_error === 0) {
                // Verifica o tipo do arquivo
                $allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
                $file_type = mime_content_type($file_tmp);
                
                if (!in_array($file_type, $allowed_types)) {
                    $errors[] = "Arquivo '$file_name': Tipo não permitido";
                    $error_count++;
                    continue;
                }

                // Verifica o tamanho do arquivo (máximo 5MB)
                $max_size = 5 * 1024 * 1024; // 5MB em bytes
                if ($file_size > $max_size) {
                    $errors[] = "Arquivo '$file_name': Tamanho máximo excedido (5MB)";
                    $error_count++;
                    continue;
                }

                // Gera um nome único para o arquivo
                $file_extension = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));
                $new_file_name = uniqid() . '.' . $file_extension;
                $file_destination = $upload_dir . $new_file_name;

                // Move o arquivo para o destino
                if (move_uploaded_file($file_tmp, $file_destination)) {
                    $success_count++;
                } else {
                    $errors[] = "Erro ao mover o arquivo '$file_name'";
                    $error_count++;
                }
            } else {
                $errors[] = "Erro no upload do arquivo '$file_name'. Código: $file_error";
                $error_count++;
            }
        }

        // Retorna o resultado
        if ($success_count > 0) {
            echo json_encode([
                'success' => true,
                'message' => "Upload concluído: $success_count arquivo(s) enviado(s) com sucesso" . 
                            ($error_count > 0 ? ", $error_count erro(s)" : ""),
                'success_count' => $success_count,
                'error_count' => $error_count,
                'errors' => $errors
            ]);
        } else {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => "Nenhum arquivo foi enviado com sucesso",
                'error_count' => $error_count,
                'errors' => $errors
            ]);
        }
    } else {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Dados do formulário incompletos.'
        ]);
    }
} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Método não permitido.'
    ]);
}
?> 