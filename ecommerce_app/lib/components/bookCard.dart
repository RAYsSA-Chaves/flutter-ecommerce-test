import 'package:flutter/material.dart';


class BookCard extends StatelessWidget {

  Map<String, dynamic> book;

  BookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {

    final String title = book['title'] ?? 'Sem título';

    final String cover = book['cover'] ?? '';

    final double price = (book['price'] as num).toDouble();

    final bool promotion = book['promotion'] ?? false;

    final precoFormatado = "R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}";

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4), 
                  blurRadius: 8, 
                  offset:Offset(4, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.network(
                    cover,
                    width: 140,
                    height: 200,
                    fit: BoxFit.cover
                  ),
                  if (promotion)
                    Positioned(
                      top: 12,
                      left: -28,
                      child: Transform.rotate(
                        angle: -0.785,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 4,
                          ),
                          color: Colors.black,
                          child: Text(
                            'Promoção',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          Text(
            precoFormatado,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}