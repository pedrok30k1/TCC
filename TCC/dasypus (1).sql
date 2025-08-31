CREATE DATABASE dasypus DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE dasypus;

-- Tabela: usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_nasc DATE NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL, 
    id_pai int,
    foto_url VARCHAR(300),
    email VARCHAR(100) NOT NULL UNIQUE,
    legenda VARCHAR(100) NULL,
    ativo BOOLEAN DEFAULT false
);

-- Tabela: categorias
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    foto_url VARCHAR(300),
    id_usuario INT NOT NULL,
    tema_cor varchar(100),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) 
);

-- Tabela: cards
CREATE TABLE cards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao VARCHAR(100),
    imagem_url VARCHAR(300),
    tema_cor varchar(100),
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id) 
    );

-- Tabela: mensagens
CREATE TABLE mensagens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    texto TEXT,
    data_envio datetime,
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) 
);

-- Tabela: telefones_usuario
CREATE TABLE telefones_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    telefone VARCHAR(20) NOT NULL,
    nome_contato VARCHAR(50),
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) 
);

-- Tabela: enderecos_usuario
CREATE TABLE enderecos_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cep VARCHAR(9),
    estado VARCHAR(2),
    cidade VARCHAR(50),
    rua VARCHAR(150),
    numero VARCHAR(10),
    complemento VARCHAR(50),
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) 
);