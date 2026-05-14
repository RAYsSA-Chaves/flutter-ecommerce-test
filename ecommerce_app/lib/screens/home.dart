import 'dart:convert';
import 'package:ecommerce_app/components/bookCard.dart';
import 'package:ecommerce_app/components/cartBtn.dart';
import 'package:ecommerce_app/components/searchBar.dart';
import 'package:ecommerce_app/screens/addBook.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // listas que guardam os retornos da API
  List<dynamic> _allBooks = [];
  List<dynamic> _filteredBooks = [];

  final String baseUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    getBooks();  // puxa os livros assim que a tela abre
  }

  void getBooks() async {
      final result = await http.get(Uri.parse("$baseUrl/books")); 
      
      if (result.statusCode == 200) {
        final books = jsonDecode(result.body);
        
        setState(() {
           _allBooks = books;
           _filteredBooks = books;
        });
      }
  }

  // função de busca
  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks = _allBooks.where((book) {
          final title = book['title'].toString().toLowerCase();
          return title.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
    
        child: Column(
          children: [
            // appbar improvisada sem ficar fixa na tela
            Container(
              padding: EdgeInsets.only(
                top: 10,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'images/logo2.png',
                        height: 32,
                      ),
                      CartBtn(iconColor: Colors.white,),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomSearchBar(onSearch: _filterBooks),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // botão +
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: IconButton(
                      hoverColor: Colors.transparent,
                      icon: Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBook(),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24),
 
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 40,
                      alignment: WrapAlignment.spaceBetween,
                      children:
                        _filteredBooks.map((bookData) {
                          return BookCard(
                            book: bookData,
                          );
                        }).toList(),
                    ),
                  ),

                  SizedBox(height: 20,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}