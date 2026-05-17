import 'dart:convert';
import 'package:ecommerce_app/components/cartBtn.dart';
import 'package:ecommerce_app/components/customSnackBar.dart';
import 'package:ecommerce_app/components/grayBtn.dart';
import 'package:ecommerce_app/screens/editBook.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BookDetails extends StatefulWidget {

  final String id;

  BookDetails({
    super.key, 
    required this.id
  });

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  Map<String, dynamic>? _book;
  
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    getBookById();
  }

  void getBookById() async {
      final result = await http.get(Uri.parse("$baseUrl/books/${widget.id}"));
      
      if (result.statusCode == 200) {
        setState(() {
          _book = jsonDecode(result.body);
        });
    }
  }

  void deleteBook() async {
    final response = await http.delete(Uri.parse("$baseUrl/books/${widget.id}"));

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (mounted) {
        Navigator.pop(context); // fecha o modal se ainda estiver aberto
        Navigator.pop(context); // volta para a home
      }
    } else {
      showCustomSnackBar(context, "Erro ao deletar o livro.");
    }
  }

  void showDeleteModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar exclusão", style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text("Tem certeza que deseja excluir este livro?"),
          actions: [
            // botão cancelar
            TextButton(
              onPressed: () => Navigator.pop(context), // só fecha o modal
              child: Text("Cancelar", style: TextStyle(color: Colors.black)),
              style: TextButton.styleFrom(
                overlayColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              ),
            ),

            // botão confirmar
            TextButton(
              onPressed: () {
                deleteBook(); // chama a função de delete
              },
              child: Text("Deletar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                overlayColor: Color.fromARGB(255, 255, 0, 0).withOpacity(0.3),
              ),
            ),
          ],
        );
      },
    );
  }

  void addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    
    // pega a lista atual ou cria uma vazia se não existir
    List<String> cartItems = prefs.getStringList('cart_items') ?? [];

    // evita duplicatas
    if (cartItems.contains(widget.id)) {
      showCustomSnackBar(context, "Este livro já está no seu carrinho!");
    } else {
      // adiciona o novo ID
      cartItems.add(widget.id);
      await prefs.setStringList('cart_items', cartItems);

      if (mounted) {
        showCustomSnackBar(context, "Livro adicionado ao seu carrinho!", color: Colors.green);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // tratando e tipando os dados que vieram da API
    final String title = _book!['title'] ?? 'Sem título';

    final String cover = _book!['cover'] ?? '';

    final double price = (_book!['price'] as num?)?.toDouble() ?? 0.0;
    final precoFormatado = "R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}";

    final String author = _book!['author'] ?? 'Autor';
    
    final pages = _book!['pages']?.toString() ?? 'N/A';

    final year = _book!['release']?.toString() ?? 'N/A';

    final String synopsis = _book!['synopsis'] ?? 'Sinopse não disponível.';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 209, 209, 209),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // parte cinza
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 16, 
                right: 16, 
                bottom: 60
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CartBtn(iconColor: Colors.black),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // capa do livro
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(2),
                      bottomLeft: Radius.circular(2)
                    ),
                    child: Image.network(
                      cover,
                      width: 180,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            // parte branca
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GrayBtn(
                            iconPath: 'images/edit.png',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBook(id: widget.id),
                                ),
                              );
                              // atualiza a página ao voltar da tela de edição
                              getBookById();
                            },
                          ),
                          SizedBox(width: 10),
                          GrayBtn(
                            iconPath: 'images/trash.png',
                            onPressed: () {
                              showDeleteModal();
                            },
                          ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 8),

                  Text(
                    precoFormatado,
                    style: TextStyle(fontSize: 22),
                  ),

                  SizedBox(height: 24),

                  Row(
                    children: [
                      Text("Autor(a): ", style: TextStyle(fontSize: 16)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 209, 209, 209),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(author, style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Text("Páginas: ", style: TextStyle(fontSize: 16)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 209, 209, 209),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(pages),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  
                  Text("Lançamento: $year", style: TextStyle(fontSize: 16)),

                  SizedBox(height: 32),

                  Text(
                    "Sinopse",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    textAlign: TextAlign.justify,
                    synopsis,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),

                  SizedBox(height: 50),

                  // botão adicionar ao carrinho
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        addToCart();
                      },
                      child: Text(
                        "Adicionar ao carrinho",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}