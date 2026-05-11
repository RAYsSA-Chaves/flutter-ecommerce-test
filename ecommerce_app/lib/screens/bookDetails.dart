import 'package:flutter/material.dart';


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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}