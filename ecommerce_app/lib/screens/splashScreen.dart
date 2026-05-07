import 'package:ecommerce_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 2), 
      () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // captura o tamanho da tela
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              'images/wave1.svg',
              width: size.width * 0.5, 
            ),
          ),

          Positioned(
            top: size.height * 0.02,
            right: 0,
            child: SvgPicture.asset(
              'images/wave2.svg',
              width: size.width * 0.3, 
            ),
          ),

          Positioned(
            bottom: -10,
            left: 0,
            right: 0, // left e right = 0 faz a imagem querer esticar horizontalmente
            child: SvgPicture.asset(
              'images/wave3.svg',
              fit: BoxFit.fitWidth, 
            ),
          ),

          Positioned(
            bottom: size.height * 0.23,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'images/splashMan.png',
                height: size.height * 0.45, 
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            bottom: size.height * 0.19,
            left: size.width * 0.4,
            child: LinearPercentIndicator(
              width: size.width * 0.2,
              lineHeight: 8,
              percent: 1.0,
              animation: true,
              animationDuration: 2000,
              barRadius: Radius.circular(10),
              progressColor: Colors.black,
              backgroundColor: Colors.grey.shade300,
            ),
          ),

          Positioned(
            top: size.height * 0.18, 
            left: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'images/logo.png',
                  width: size.width * 0.35,
                ),
                SizedBox(height: 10),
                Text(
                  'Encontre os melhores livros!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}