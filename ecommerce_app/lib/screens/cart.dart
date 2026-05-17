import 'dart:convert';
import 'package:ecommerce_app/components/grayBtn.dart';
import 'package:ecommerce_app/screens/bookDetails.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class Cart extends StatefulWidget {
  Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  List<dynamic> _cartBooks = [];

  final String baseUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    getCartItems();
  }

  // busca os IDs locais e depois os dados na API
  void getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds = prefs.getStringList('cart_items') ?? [];

    List<Map<String, dynamic>> cartBooks = [];

    for (String id in savedIds) {
      final response = await http.get(Uri.parse("$baseUrl/books/$id"));
      if (response.statusCode == 200) {
        cartBooks.add(jsonDecode(response.body));
      }
    }

    setState(() {
      _cartBooks = cartBooks;
    });
  }

  // remover o ID do carrinho
  void deleteFromCart(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedIds = prefs.getStringList('cart_items') ?? [];

    savedIds.remove(id);
    await prefs.setStringList('cart_items', savedIds);

    // recarrega a lista
    getCartItems();
  }

  void showDeleteModal(String id, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remover item do carrinho", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Deseja remover '$title' do seu carrinho?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.black)),
              style: TextButton.styleFrom(
                overlayColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteFromCart(id);
              },
              child: Text("Remover", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                overlayColor: Color.fromARGB(255, 255, 0, 0).withOpacity(0.3),
              ),
            ),
          ],
        );
      },
    );
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
                      "Meu Carrinho",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 20),

                  if (_cartBooks.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 180),
                      child: Text("Seu carrinho está vazio", style: TextStyle(fontSize: 18),),
                    )

                  else
                    ..._cartBooks.map((book) {
                      final String id = book['id'].toString();
                      final String title = book['title'] ?? 'Sem título';
                      final String cover = book['cover'] ?? '';
                      final double price = (book['price'] as num?)?.toDouble() ?? 0.0;

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BookDetails(id: id)),
                          );
                          getCartItems(); // atualiza ao voltar
                        },
                        
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color.fromARGB(255, 225, 225, 225), width: 1.5),
                          ),

                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: Offset(3, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child: Image.network(cover, width: 80, height: 110, fit: BoxFit.cover),
                                ),
                              ),

                              SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                    ),

                                    SizedBox(height: 4),

                                    Text(
                                      "R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}",
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),

                              GrayBtn(
                                iconPath: 'images/x.png',
                                onPressed: () => showDeleteModal(id, title),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}