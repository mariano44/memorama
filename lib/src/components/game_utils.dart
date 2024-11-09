import 'package:flutter/material.dart';

class Game {
  final Color hiddenCard = Colors.red;
  List<Color>? gameColors;
  List<String>? gameImg;

  final String hiddenCardpath = "assets/img/frutas.jpg";
  List<String> cards_list = [
    "assets/img/image_0.png",
    "assets/img/image_1.png",
    "assets/img/image_2.png",
    "assets/img/image_3.png",
    "assets/img/image_4.png",
    "assets/img/image_5.png",
    "assets/img/image_6.png",
    "assets/img/image_7.png",
    "assets/img/image_0.png",
    "assets/img/image_1.png",
    "assets/img/image_2.png",
    "assets/img/image_3.png",
    "assets/img/image_4.png",
    "assets/img/image_5.png",
    "assets/img/image_6.png",
    "assets/img/image_7.png",
  ];
  final int cardCount = 16;
  List<Map<int, String>> matchCheck = [];

  //methods
  void initGame() {
    cards_list.shuffle(); // Aquí mezclamos las cartas
    gameImg = List.generate(cardCount, (index) => hiddenCardpath);
  }
}
