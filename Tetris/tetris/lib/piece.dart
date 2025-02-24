import 'values.dart';
import 'package:flutter/material.dart';

class Piece {
  //テトリスの形
  Tetromino type;

  Piece({required this.type});

  //ピースは整数のリストで表す
  List<int> position = [];

  Color get color{
    return tetrominoColors[type] ?? const Color(0xFFFFFFFF);
  }

  void initialaizePiece() {
    //最初のピース
    switch (type) {
      case Tetromino.L:
        position = [-26, -16, -6, -5];
        break;
      case Tetromino.J:
        position = [-25, -15, -5, -6];
        break;
      case Tetromino.I:
        position = [-4, -5, -6, -7];
        break;
      case Tetromino.O:
        position = [-15, -16, -5, -6];
        break;
      case Tetromino.S:
        position = [-15, -14, -6, -5];
        break;
      case Tetromino.Z:
        position = [-17, -16, -6, -5];
        break;
      case Tetromino.T:
        position = [-26, -16, -6, -15];
        break;
      default:
    }
  }

  void movePiece(Direction direction) {
    switch (direction) {
      case Direction.down:
        for (int i = 0; i < position.length; i++) {
          position[i] += rowLength; //横幅分増やしてあげれば，ピクセル一個分下降する
        }
        break;
      case Direction.right:
        for (int i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;
      case Direction.left:
        for (int i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      default:
    }
  }
}
