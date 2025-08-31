class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String cpf;
  final DateTime dataNasc;
  final String? sobre;
  final String? fotoUrl;
  final int? idPai;
  final String? tipo;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.cpf,
    required this.dataNasc,
    this.sobre,
    this.fotoUrl,
    this.idPai,
    this.tipo,
  });

  // Convert Usuario to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'cpf': cpf,
      'data_nasc': dataNasc.toIso8601String(),
      'sobre': sobre,
      'foto_url': fotoUrl,
      'id_pai': idPai,
      'tipo': tipo,
    };
  }

  // Create Usuario from JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
      cpf: json['cpf'],
      dataNasc: DateTime.parse(json['data_nasc']),
      sobre: json['sobre'],
      fotoUrl: json['foto_url'],
      idPai: json['id_pai'],
      tipo: json['tipo'],
    );
  }

  // Create a copy of Usuario with some fields changed
  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? senha,
    String? cpf,
    DateTime? dataNasc,
    String? sobre,
    String? fotoUrl,
    int? idPai,
    final String? tipo,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      cpf: cpf ?? this.cpf,
      dataNasc: dataNasc ?? this.dataNasc,
      sobre: sobre ?? this.sobre,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      idPai: idPai ?? this.idPai,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, email: $email, cpf: $cpf, tipo: $tipo)';
  }
} 