import 'dart:convert';
import 'package:ecommerce_app/components/searchBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AddBook extends StatefulWidget {
   AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  // Controllers para os campos
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _releaseController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  bool _isPromotion = false;
  
  // Estado da pesquisa
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoadingSearch = false;
  bool _isSaving = false;

  // Função para buscar na Google Books API
  Future<void> searchGoogleBooks(String search) async {
    if (search.isEmpty) return;

    setState(() {
      _isLoadingSearch = true;
      _searchResults = [];
    });

    final Uri url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$search');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] == null || data['items'].isEmpty) {
          _showSnackBar('Nenhum livro encontrado. Preencha manualmente.');
          setState(() => _isLoadingSearch = false);
          return;
        }

        List<Map<String, dynamic>> books = [];

        for (int i = 0; i < data['items'].length; i++) {
          final volume = data['items'][i]['volumeInfo'];
          
          // Tratamento seguro para pegar o ano
          String yearStr = volume['publishedDate']?.toString() ?? '';
          int year = 0;
          if (yearStr.length >= 4) {
            year = int.tryParse(yearStr.substring(0, 4)) ?? 0;
          }

          books.add({
            'title': volume['title'] ?? '',
            'cover': volume['imageLinks']?['thumbnail'] ?? '',
            'author': (volume['authors'] != null && volume['authors'].isNotEmpty) ? volume['authors'][0] : '',
            'editor': volume['publisher'] ?? '',
            'synopsis': volume['description'] ?? '',
            'release': year,
            'pages': volume['pageCount'] ?? 0,
          });
        }

        setState(() {
          _searchResults = books;
        });

      } else {
        _showSnackBar('Erro ao buscar na API do Google.');
      }
    } catch (e) {
      _showSnackBar('Erro de conexão ao buscar livros.');
    } finally {
      setState(() => _isLoadingSearch = false);
    }
  }

  // Preenche os inputs quando clica em um item do carrossel
  void _fillFormWithBook(Map<String, dynamic> book) {
    _titleController.text = book['title'].toString();
    _authorController.text = book['author'].toString();
    _editorController.text = book['editor'].toString();
    _pagesController.text = book['pages'].toString();
    _releaseController.text = book['release'].toString();
    _synopsisController.text = book['synopsis'].toString();
    _coverController.text = book['cover'].toString();
    
    // Atualiza a tela para renderizar a capa dinamicamente
    setState(() {});
  }

  // Salvar no json-server
  Future<void> _cadastrarLivro() async {
    // Validação básica
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      _showSnackBar('Preencha pelo menos o título e o preço.');
      return;
    }

    setState(() => _isSaving = true);

    // Tratando a vírgula para ponto no preço
    String precoLimpo = _priceController.text.replaceAll(',', '.');
    double price = double.tryParse(precoLimpo) ?? 0.0;

    // Montando o Map com os dados
    final newBook = {
      "title": _titleController.text,
      "author": _authorController.text,
      "editor": _editorController.text,
      "pages": int.tryParse(_pagesController.text) ?? 0,
      "year": int.tryParse(_releaseController.text) ?? 0,
      "synopsis": _synopsisController.text,
      "cover": _coverController.text,
      "price": price,
      "promotion": _isPromotion
    };

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.5:3000/books"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newBook),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Livro cadastrado com sucesso!');
        Navigator.pop(context); // Retorna para a tela anterior
      } else {
        _showSnackBar('Erro ao cadastrar livro no servidor.');
      }
    } catch (e) {
      _showSnackBar('Erro de conexão com o servidor local.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Atalho para criar os campos de texto padronizados
  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // App Bar não fixa (Setinha e Título)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                 SizedBox(width: 8),
                 Text(
                    "Cadastrar Livro",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
             SizedBox(height: 24),

              // Barra de pesquisa para auto-preenchimento
               Text("Buscar dados na internet:", style: TextStyle(fontWeight: FontWeight.bold)),
               SizedBox(height: 8),
              
              // OBS: Descomente e use o seu componente. Para o código não quebrar aqui, 
              // deixei a estrutura do seu componente ou você pode substituí-lo.
              CustomSearchBar(
                onSearch: (query) => searchGoogleBooks(query),
              ),

              // Loading da pesquisa
              if (_isLoadingSearch)
                 Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Carrossel de resultados
              if (_searchResults.isNotEmpty)
                Container(
                  height: 220,
                  margin: EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final book = _searchResults[index];
                      return GestureDetector(
                        onTap: () => _fillFormWithBook(book),
                        child: Container(
                          width: 120,
                          margin: EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book['cover'].isNotEmpty ? book['cover'] : 'https://via.placeholder.com/150',
                                  height: 160,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 100),
                                ),
                              ),
                             SizedBox(height: 8),
                              Text(
                                book['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

             Divider(height: 40, thickness: 1),

              // Formulário
             Text("Detalhes do Livro:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
             SizedBox(height: 16),

              // Preview da Capa e Input da URL
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _coverController.text,
                          height: 180,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: 120,
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                   SizedBox(height: 16),
                    TextField(
                      controller: _coverController,
                      decoration: InputDecoration(
                        labelText: 'URL da capa',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setState(() {}); // Atualiza o preview da imagem
                      },
                    ),
                  ],
                ),
              ),
             SizedBox(height: 16),

              // Campos
              _buildTextField('Título', _titleController),
              _buildTextField('Autor', _authorController),
              _buildTextField('Editora', _editorController),
              
              Row(
                children: [
                  Expanded(child: _buildTextField('Páginas', _pagesController, type: TextInputType.number)),
                 SizedBox(width: 16),
                  Expanded(child: _buildTextField('Ano', _releaseController, type: TextInputType.number)),
                ],
              ),
              
              _buildTextField('Sinopse', _synopsisController, maxLines: 4),
              
             Divider(height: 32),
              
              // Preço e Promoção
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Preço (R\$)', _priceController, type: TextInputType.numberWithOptions(decimal: true)),
                  ),
                   SizedBox(width: 16),
                  Column(
                    children: [
                       Text("Promoção?"),
                      Switch(
                        value: _isPromotion,
                        activeColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            _isPromotion = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

               SizedBox(height: 32),

              // Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding:  EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Cancelar', style: TextStyle(color: Colors.black, fontSize: 16)),
                    ),
                  ),
                   SizedBox(width: 16),
                  Expanded(
                    flex: 2, // Faz o botão de cadastrar ser maior
                    child: InkWell(
                      onTap: _isSaving ? null : _cadastrarLivro,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isSaving ? Colors.grey : Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isSaving
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
             SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}