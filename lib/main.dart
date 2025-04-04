import 'package:controle_estoque/entity/Produto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(EstoqueApp());
}

class EstoqueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Estoque',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Produto> produtos = [];
  String searchQuery = "";
  Produto produtoCustom = Produto();

  Future<void> _selecionarImagem(Function(String) onImageSelected) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      onImageSelected(pickedFile.path);
    }
  }

  void _adicionarProduto() {
    TextEditingController nomeController = TextEditingController();
    TextEditingController descricaoController = TextEditingController();
    TextEditingController quantidadeController = TextEditingController();
    String? imagemPath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(hintText: 'Nome do produto'),
              ),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(hintText: 'Descrição do produto'),
              ),
              TextField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Quantidade inicial'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selecionarImagem((path) {
                  setState(() {
                    imagemPath = path;
                  });
                }),
                child: Text('Selecionar Imagem'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
					produtoCustom.nome = nomeController.text;
					produtoCustom.quantidade = int.tryParse(quantidadeController.text) ?? 0;
					produtoCustom.descricao = descricaoController.text;
					produtoCustom.imagem = imagemPath;
					salvarProduto(produtoCustom);
				  	setState(() {
						produtos.add(produtoCustom);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> salvarProduto(Produto produto) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
    
        // Recupera a lista atual de produtos
        List<String> produtosJson = prefs.getStringList('produtos') ?? [];
    
        // Adiciona o novo produto à lista
        produtosJson.add(produto.toJsonString());
		print(produtosJson);
        // Salva a lista atualizada no SharedPreferences
        await prefs.setStringList('produtos', produtosJson);
	}

  void _editarProduto(int index) {
    TextEditingController nomeController = TextEditingController(text: produtos[index].nome);
    TextEditingController descricaoController = TextEditingController(text: produtos[index].descricao);
    TextEditingController quantidadeController = TextEditingController(text: produtos[index].quantidade.toString());
    String? imagemPath = produtos[index].imagem;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(hintText: 'Nome do produto'),
              ),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(hintText: 'Descrição do produto'),
              ),
              TextField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Quantidade inicial'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selecionarImagem((path) {
                  setState(() {
                    imagemPath = path;
                  });
                }),
                child: Text('Selecionar Imagem'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
                	produtoCustom.nome = nomeController.text;
					produtoCustom.quantidade = int.tryParse(quantidadeController.text) ?? 0;
					produtoCustom.descricao = descricaoController.text;
					produtoCustom.imagem = imagemPath;
					salvarProduto(produtoCustom);
				  	setState(() {
						produtos.add(produtoCustom);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _excluirProduto(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir Produto'),
          content: Text('Tem certeza que quer EXCLUIR este produto do estoque?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  produtos.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
		title: Text('Controle de Estoque'),
		bottom: PreferredSize(
			preferredSize: Size.fromHeight(50.0),
			child: Padding(
				padding: EdgeInsets.all(8.0),
				child: TextField(
				onChanged: (value) {
					setState(() {
						searchQuery = value.toLowerCase();
					});
				},
				decoration: InputDecoration(
					hintText: 'Pesquisar produto...',
					prefixIcon: Icon(Icons.search),
					border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(8.0),
					borderSide: BorderSide.none,
					),
					filled: true,
					fillColor: Colors.white,
				),
				),
			),
			),
		),
      body: ListView.builder(
        itemCount: produtos.length,
        itemBuilder: (context, index) {
			if (!produtos[index].nome!.toLowerCase().contains(searchQuery)) {
            return Container();
          }

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(produtos[index].imagem ?? ''),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/default.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            title: Text(produtos[index].nome!),
            subtitle: Text('Estoque: ${produtos[index].quantidade}\n${produtos[index].descricao}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarProduto(index);
                    } else if (value == 'excluir') {
                      _excluirProduto(index);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'editar',
                        child: Text('Editar Produto'),
                      ),
                      PopupMenuItem<String>(
                        value: 'excluir',
                        child: Text('Excluir Produto'),
                      ),
                    ];
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarProduto,
        child: Icon(Icons.add),
      ),
    );
  }
}
