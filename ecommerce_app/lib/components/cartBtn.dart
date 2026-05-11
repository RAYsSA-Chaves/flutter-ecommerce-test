import 'package:ecommerce_app/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CartBtn extends StatelessWidget {
  Color iconColor;

  CartBtn({
    super.key,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {

    String iconPath = 'images/blackCart.png';

    if (iconColor == Colors.white) {
      iconPath = 'images/whiteCart.png';
    }

    return IconButton(
      icon: Image.asset(
        iconPath,
        width: 32,
        height: 32,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Cart(),
          ),
        );
      },
    );
  }
}