class Card {
  final int? id;
  final String titulo;
  final String descricao;
  final String? imagemUrl;
  final String? temaCor;
  final String? fonte; // Novo campo
  final int idCategoria;

  Card({
    this.id,
    required this.titulo,
    required this.descricao,
    this.imagemUrl,
    this.temaCor,
    this.fonte, // Novo campo
    required this.idCategoria,
  });

  // Convert Card to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'imagem_url': imagemUrl,
      'tema_cor': temaCor,
      'fonte': fonte, // Novo campo
      'id_categoria': idCategoria,
    };
  }

  // Create Card from JSON
  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      imagemUrl: json['imagem_url'],
      temaCor: json['tema_cor'],
      fonte: json['fonte'], // Novo campo
      idCategoria: json['id_categoria'],
    );
  }

  // Create a copy of Card with some fields changed
  Card copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? imagemUrl,
    String? temaCor,
    String? fonte, // Novo campo
    int? idCategoria,
  }) {
    return Card(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      temaCor: temaCor ?? this.temaCor,
      fonte: fonte ?? this.fonte, // Novo campo
      idCategoria: idCategoria ?? this.idCategoria,
    );
  }

  @override
  String toString() {
    return 'Card(id: $id, titulo: $titulo, descricao: $descricao, imagemUrl: $imagemUrl, temaCor: $temaCor, fonte: $fonte, idCategoria: $idCategoria)';
  }
}
