import 'dart:convert';
import 'package:ecommerce_app/components/bookCard.dart';
import 'package:ecommerce_app/components/cartBtn.dart';
import 'package:ecommerce_app/components/searchBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // são listas  que guardam os retornos da API
  List<dynamic> _allBooks = [];
  List<dynamic> _filteredBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getBooks(); // puxa os livros assim que a tela abre
  }

  void getBooks() async {
    try {
      final result = await http.get(Uri.parse("http://192.168.1.5:3000/books")); 
      
      if (result.statusCode == 200) {
        final books = jsonDecode(result.body);
        
        setState(() {
           _allBooks = books;
           _filteredBooks = books;
           _isLoading = false;
        });

      } else {
        setState(() => _isLoading = false);
      }

    } catch (e) {
      setState(() => _isLoading = false);
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

    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              children: [

                // APP BAR
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),

                  decoration: const BoxDecoration(
                    color: Colors.black,

                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),

                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          Image.asset(
                            'images/logo2.png',
                            height: 32,
                          ),

                           CartBtn(
                            iconColor: Colors.white,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      CustomSearchBar(
                        onSearch: _filterBooks,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,

                    children: [

                      // BOTÃO +
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black,
                          ),

                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,

                        child: Wrap(
                          spacing: 16,
                          runSpacing: 24,
                          alignment:
                              WrapAlignment.spaceEvenly,

                          children:
                              _filteredBooks.map((bookData) {

                            return BookCard(
                              book: bookData,
                            );

                          }).toList(),
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