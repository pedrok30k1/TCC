class CategoriaCard {
  final int? categoriaId;
  final String categoriaNome;
  final String? categoriaFotoUrl;
  final String? categoriaTemaCor;
  final List<CardItem> cards;

  CategoriaCard({
    this.categoriaId,
    required this.categoriaNome,
    this.categoriaFotoUrl,
    this.categoriaTemaCor,
    required this.cards,
  });

  // Converter de JSON
  factory CategoriaCard.fromJson(Map<String, dynamic> json) {
    var cardsJson = json['cards'] as List<dynamic>? ?? [];
    List<CardItem> cardList =
        cardsJson.map((c) => CardItem.fromJson(c, idCategoria: int.tryParse(json['id'].toString()) ?? 0)).toList();

    return CategoriaCard(
      categoriaId: int.tryParse(json['id'].toString()),
      categoriaNome: json['nome'] ?? '',
      categoriaFotoUrl: json['foto_url'],
      categoriaTemaCor: json['tema_cor'],
      cards: cardList,
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': categoriaId,
      'nome': categoriaNome,
      'foto_url': categoriaFotoUrl,
      'tema_cor': categoriaTemaCor,
      'cards': cards.map((c) => c.toJson()).toList(),
    };
  }
}

class CardItem {
  final int? id;
  final String titulo;
  final String descricao;
  final String? imagemUrl;
  final String? temaCor;
  final String? fonte;
  final int idCategoria;

  CardItem({
    this.id,
    required this.titulo,
    required this.descricao,
    this.imagemUrl,
    this.temaCor,
    this.fonte,
    required this.idCategoria,
  });

  factory CardItem.fromJson(Map<String, dynamic> json, {required int idCategoria}) {
    return CardItem(
      id: json['card_id'],
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      imagemUrl: json['imagem_url'],
      temaCor: json['tema_cor'],
      fonte: json['fonte'],
      idCategoria: idCategoria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': id,
      'titulo': titulo,
      'descricao': descricao,
      'imagem_url': imagemUrl,
      'tema_cor': temaCor,
      'fonte': fonte,
      'id_categoria': idCategoria,
    };
  }
}
