import 'dart:convert';
import 'package:ecommerce_app/components/customSnackBar.dart';
import 'package:ecommerce_app/components/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class EditBook extends StatefulWidget {
  final String id;

  EditBook({
    super.key, 
    required this.id
  });

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _releaseController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isPromotion = false;
  bool _isSaving = false;

  final String baseUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _fetchBookDetails(); // busca os dados assim que a tela abre
  }

  // busca os dados atuais do livro para preencher os campos
  void _fetchBookDetails() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/books/${widget.id}"));

      if (response.statusCode == 200) {
        final book = jsonDecode(response.body);

        setState(() {
          _titleController.text = book['title']?.toString() ?? '';
          _authorController.text = book['author']?.toString() ?? '';
          _editorController.text = book['editor']?.toString() ?? '';
          _pagesController.text = book['pages']?.toString() ?? '';
          _releaseController.text = book['release']?.toString() ?? '';
          _synopsisController.text = book['synopsis']?.toString() ?? '';
          _coverController.text = book['cover']?.toString() ?? '';
          _priceController.text = book['price']?.toStringAsFixed(2).replaceAll('.', ',') ?? '';
          _isPromotion = book['promotion'] ?? false;
        });
      } else {
        showCustomSnackBar(context, 'Erro ao carregar dados do livro.');
      }
    } catch (e) {
      showCustomSnackBar(context, 'Erro ao buscar dados do livro.');
    }
  }

  void _updateBook() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _authorController.text.isEmpty || _coverController.text.isEmpty || _editorController.text.isEmpty || _pagesController.text.isEmpty || _releaseController.text.isEmpty || _synopsisController.text.isEmpty) {
      showCustomSnackBar(context, 'Todas as informações do livro são obrigatórias!');
      return;
    }

    setState(() { _isSaving = true; });

    final updatedBook = {
      "title": _titleController.text,
      "author": _authorController.text,
      "editor": _editorController.text,
      "pages": int.tryParse(_pagesController.text) ?? 0,
      "release": int.tryParse(_releaseController.text) ?? 0,
      "synopsis": _synopsisController.text,
      "cover": _coverController.text,
      "price": double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      "promotion": _isPromotion
    };

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/books/${widget.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedBook),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'Livro atualizado com sucesso!', color: Colors.green);
        Navigator.pop(context, true); // Retorna true para a tela anterior recarregar
      } else {
        showCustomSnackBar(context, 'Erro ao salvar alterações.');
      }
    } catch (e) {
      showCustomSnackBar(context, 'Erro ao salvar alterações.');
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

            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
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
                      "Editar Livro",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            child: _coverController.text.isNotEmpty
                              ? Image.network(
                                  _coverController.text,
                                  width: 140, 
                                  height: 200, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 140, 
                                    height: 200, 
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                )
                              : Container(
                                  height: 200, 
                                  width: 140, 
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported),
                                ),
                          ),
                        ),

                        SizedBox(height: 30),

                        TextField(
                          cursorColor: Colors.black,
                          controller: _coverController,
                          decoration: InputDecoration(
                            labelText: 'URL da capa',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Color.fromARGB(255, 245, 245, 245),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.5),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          onPressed: _isSaving ? null : _updateBook,
                          child: _isSaving
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Salvar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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