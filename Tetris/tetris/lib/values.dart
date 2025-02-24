import 'package:flutter/material.dart';

  //盤面のタテヨコ  
  int rowLength = 10;
  int colLength = 15;

enum Tetromino{ //テトリスの形を列挙
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

enum Direction{ //移動方向
  down,
  up, //upは多分いらない
  left,
  right, 
}

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Color(0xFFFFA500),
  Tetromino.J: Color.fromARGB(255, 0, 102, 255),
  Tetromino.I: Color.fromARGB(255, 242, 0, 255),
  Tetromino.O: Color(0xFFFFFF00),
  Tetromino.S: Color(0xFF008000),
  Tetromino.Z: Color(0xFFFF0000),
  Tetromino.T: Color.fromARGB(255, 144, 0, 255),
};