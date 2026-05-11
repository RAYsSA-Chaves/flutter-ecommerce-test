import 'package:flutter/material.dart';


class GrayBtn extends StatelessWidget {

  final String iconPath;
  final VoidCallback onPressed; 

  GrayBtn({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      icon: Image.asset(
        iconPath,
        width: 32,
        height: 32,
      ),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}