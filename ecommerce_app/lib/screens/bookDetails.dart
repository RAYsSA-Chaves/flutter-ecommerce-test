import 'dart:convert';
import 'package:ecommerce_app/components/cartBtn.dart';
import 'package:ecommerce_app/components/grayBtn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


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

  @override
  void initState() {
    super.initState();
    getBookById();
  }

  void getBookById() async {
      final result = await http.get(Uri.parse("http://192.168.1.6:3000/books/${widget.id}"));
      
      if (result.statusCode == 200) {
        setState(() {
          _book = jsonDecode(result.body);
        });
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

    final year = _book!['year']?.toString() ?? 'N/A';

    final String synopsis = _book!['synopsis'] ?? 'Sinopse não disponível.';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 209, 209, 209),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // parte cinza
            Padding(
              padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 32),
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
                    borderRadius: BorderRadius.circular(12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            onPressed: () {},
                          ),
                          SizedBox(width: 8),
                          GrayBtn(
                            iconPath: 'images/trash.png',
                            onPressed: () {},
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

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 209, 209, 209),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(author, style: TextStyle(fontSize: 14)),
                  ),

                  SizedBox(height: 16),

                  Row(
                    children: [
                      Text("Páginas", style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
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
                    synopsis,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),

                  SizedBox(height: 40),

                  // botão adicionar ao carrinho
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Adicionar ao carrinho",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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