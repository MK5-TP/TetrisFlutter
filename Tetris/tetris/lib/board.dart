import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/values.dart';
import 'pixel.dart';
import 'piece.dart';
import 'values.dart';

List<List<Tetromino?>> gameBoard =
    List.generate(colLength, (i) => List.generate(rowLength, (j) => null));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.J);

  @override
  void initState() {
    //初期状態
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initialaizePiece();

    //1フレームのレート
    Duration framerate = const Duration(milliseconds: 100);
    gameLoop(framerate);
  }

  void gameLoop(Duration framerate) {
    Timer.periodic(
      framerate,
      (timer) {
        setState(() {
          checkLanding();
          currentPiece.movePiece(Direction.down);
        });
      },
    );
  }

  //衝突判定
  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      //現在のピースが何行何列目にあるかを特定
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    return false;
  }

  void checkLanding() {
    // 着地判定
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      createNewPiece();
    }
  }

  void createNewPiece() {
    Random rand = Random();

    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initialaizePiece();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: GridView.builder(
            itemCount: rowLength * colLength,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowLength),
            itemBuilder: (context, index) {
              int row = (index / rowLength).floor();
              int col = (index % rowLength);
              if (currentPiece.position.contains(index)) {
                return Pixel(color: Colors.yellow, child: index.toString());
              } else if (gameBoard[row][col] != null) {
                final Tetromino? tetrominoType = gameBoard[row][col];
                return Pixel(color: tetrominoColors[tetrominoType], child: '');
              } else {
                return Pixel(color: Colors.grey[900], child: index.toString());
              }
            }));
  }
}
