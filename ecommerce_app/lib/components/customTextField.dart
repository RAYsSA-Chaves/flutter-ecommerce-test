import 'package:flutter/material.dart';


class CustomTextField extends StatelessWidget {

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType type;

  CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        cursorColor: Colors.black,
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
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
      ),
    );
  }
}