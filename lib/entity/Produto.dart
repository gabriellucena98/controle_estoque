class Produto {
	int? id;
	String? nome;
	String? descricao;
	int? quantidade;
	String? imagem;

	Produto({
		this.id,
		this.nome,
		this.descricao,
		this.quantidade,
		this.imagem
	});

	Produto copyWith({
		int? id,
		String? nome,
		String? descricao,
		int? quantidade,
		String? imagem,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      quantidade: quantidade ?? this.quantidade,
      imagem: imagem ?? this.imagem,
    );
  }

  String toJsonString() {
    return '{"id": $id, "nome": "${nome!}", "descricao": "${descricao ?? ''}", "quantidade": $quantidade, "imagem": "${imagem ?? ''}"}';
  }

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      quantidade: json['quantidade'],
      imagem: json['imagem'],
    );
  }
}