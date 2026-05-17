import 'dart:convert';
import 'package:ecommerce_app/components/customSnackBar.dart';
import 'package:ecommerce_app/components/customTextField.dart';
import 'package:ecommerce_app/components/searchBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AddBook extends StatefulWidget {
  AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  // controllers para os inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _releaseController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isPromotion = false;

  // estado da pesquisa
  List<dynamic> _searchResults = [];

  // loading do salvamento na api
  bool _isSaving = false;

  final String apiKey = dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  // buscar livros na Google Books API
  void searchGoogleBooks(String search) async {
    if (search.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final Uri url = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      {
        'q': 'intitle:$search',
        'maxResults': '10',
        'key': apiKey,
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] == null || data['items'].isEmpty) {
          showCustomSnackBar(context, 'Nenhum livro encontrado. Preencha manualmente.');
          return;
        }

        List<dynamic> books = [];

        for (int i = 0; i < data['items'].length; i++) {
          final volume = data['items'][i]['volumeInfo'];

          String coverUrl = '';

          if (volume['imageLinks'] != null && volume['imageLinks']['thumbnail'] != null) {
            coverUrl = volume['imageLinks']['thumbnail'];
            coverUrl = coverUrl.replaceAll('zoom=1', 'zoom=2');
            coverUrl = coverUrl.replaceAll('http://', 'https://');
            coverUrl = coverUrl.replaceAll('&edge=curl', '');
            coverUrl = 'https://wsrv.nl/?url=${Uri.encodeComponent(coverUrl)}';
          }

          String yearStr = volume['publishedDate']?.toString() ?? '';
          int year = 0;
          if (yearStr.length >= 4) {
            year = int.tryParse(yearStr.substring(0, 4)) ?? 0;
          }

          books.add({
            'title': volume['title'] ?? '',
            'cover': coverUrl,
            'author': (volume['authors'] != null && volume['authors'].isNotEmpty)
                ? volume['authors'][0]
                : '',
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
        showCustomSnackBar(context, 'Erro ao buscar livro.');
      }

    } catch (e) {
      showCustomSnackBar(context, 'Erro ao buscar livro.');
    }
  }

  // preencher form com os valores do livro selecionado
  void _fillFormWithBook(dynamic book) {
    _titleController.text = book['title'].toString();
    _authorController.text = book['author'].toString();
    _editorController.text = book['editor'].toString();
    _pagesController.text = book['pages'].toString();
    _releaseController.text = book['release'].toString();
    _synopsisController.text = book['synopsis'].toString();
    _coverController.text = book['cover'].toString();
    setState(() {});
  }

  // não deixa cadastrar sem preencher todos os campos
  void _cadastrarLivro() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _authorController.text.isEmpty || _coverController.text.isEmpty || _editorController.text.isEmpty || _pagesController.text.isEmpty || _releaseController.text.isEmpty || _synopsisController.text.isEmpty) {
      showCustomSnackBar(context, 'É obrigatório preencher todas as informações do livro!');
      return;
    }

    setState(() { _isSaving = true; });

    String precoLimpo = _priceController.text.replaceAll(',', '.');
    double price = double.tryParse(precoLimpo) ?? 0.0;

    final newBook = {
      "title": _titleController.text,
      "author": _authorController.text,
      "editor": _editorController.text,
      "pages": int.tryParse(_pagesController.text) ?? 0,
      "release": int.tryParse(_releaseController.text) ?? 0,
      "synopsis": _synopsisController.text,
      "cover": _coverController.text,
      "price": price,
      "promotion": _isPromotion
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/books"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newBook),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        showCustomSnackBar(context, 'Livro cadastrado com sucesso!', color: Colors.green);
        if (mounted) Navigator.pop(context);

      } else {
        showCustomSnackBar(context, 'Erro ao cadastrar livro.');
      }

    } catch (e) {
      showCustomSnackBar(context, 'Erro ao cadastrar livro.');

    } finally {
      setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // appbar
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20, // respeita a status bar
                bottom: 30,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Cadastrar Livro",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            SizedBox(height: 20,),

            // parte branca
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Buscar dados na internet:", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),

                  SizedBox(height: 20),
                  
                  // sombra na barra de pesquisa
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: CustomSearchBar(onSearch: searchGoogleBooks),
                  ),

                  // carrossel de resultados da busca
                  if (_searchResults.isNotEmpty)
                  Column( 
                    children: [
                      Container(
                        height: 230,
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final book = _searchResults[index];
                            return GestureDetector(
                              onTap: () => _fillFormWithBook(book),
                              child: Container(
                                width: 130,
                                margin: EdgeInsets.only(right: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 180,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: Offset(4, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          book['cover'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey[300],
                                            child: Icon(Icons.image_not_supported),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // titiulo máximo 2 linas
                                    SizedBox(
                                      height: 35,
                                      child: Text(
                                        book['title'],
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),

                  SizedBox(height: 20),

                  Text("Detalhes do Livro:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                  SizedBox(height: 16),
                  
                  Center(
                    child: Column(
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child:
                              _coverController.text.isNotEmpty
                              ? Image.network(
                                  _coverController.text,
                                  width: 140,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 140,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  height: 200,
                                  width: 140,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                          ),
                        ),

                        SizedBox(height: 16),

                        TextField(
                          cursorColor: Colors.black,
                          controller: _coverController,
                          decoration: InputDecoration(
                            labelText: 'URL da capa',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Color.fromARGB(255, 245, 245, 245),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:  Color.fromARGB(255, 0, 0, 0), 
                                width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                            ),
                            floatingLabelStyle: TextStyle(color: Colors.black),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  
                  CustomTextField(label: 'Título', controller: _titleController),

                  CustomTextField(label: 'Autor', controller: _authorController),

                  CustomTextField(label: 'Editora', controller: _editorController),

                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Páginas', controller: _pagesController, type: TextInputType.number)),

                      SizedBox(width: 16),

                      Expanded(child: CustomTextField(label: 'Ano', controller: _releaseController, type: TextInputType.number)),
                    ],
                  ),

                  CustomTextField(label: 'Sinopse', controller: _synopsisController, maxLines: 4),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Preço (R\$)',
                          controller: _priceController,
                          type: TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),

                      SizedBox(width: 16),

                      Column(
                        children: [
                          Text("Promoção?"),
                          Switch(
                            value: _isPromotion,
                            activeColor: Colors.black,
                            onChanged: (value) => setState(() { _isPromotion = value; }),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 6,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar', style: TextStyle(fontSize: 16)),
                        ),
                      ),

                      SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.black, 
                            disabledForegroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: _isSaving ? null : _cadastrarLivro,
                          child: _isSaving
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Cadastrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}