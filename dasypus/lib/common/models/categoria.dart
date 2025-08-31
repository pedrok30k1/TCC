class Categoria {
  final int? id;
  final String nome;
  final String? fotoUrl;
  final int idUsuario;
  final String? temaCor;

  Categoria({
    this.id,
    required this.nome,
    this.fotoUrl,
    required this.idUsuario,
    this.temaCor,
  });

  // Convert Categoria to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'foto_url': fotoUrl,
      'id_usuario': idUsuario,
      'tema_cor': temaCor,
    };
  }

  // Create Categoria from JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nome: json['nome'],
      fotoUrl: json['foto_url'],
      idUsuario: json['id_usuario'],
      temaCor: json['tema_cor'],
    );
  }

  // Create a copy of Categoria with some fields changed
  Categoria copyWith({
    int? id,
    String? nome,
    String? fotoUrl,
    int? idUsuario,
    String? temaCor,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      idUsuario: idUsuario ?? this.idUsuario,
      temaCor: temaCor ?? this.temaCor,
    );
  }

  @override
  String toString() {
    return 'Categoria(id: $id, nome: $nome, idUsuario: $idUsuario, temaCor: $temaCor)';
  }
}
