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
  Piece currentPiece = Piece(type: Tetromino.L);

  @override
  void initState() {
    //初期状態
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initialaizePiece();

    //1フレームのレート
    Duration framerate = const Duration(milliseconds: 400);
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

  void moveLeft() {
    if(!checkCollision(Direction.left)){
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if(!checkCollision(Direction.right)){
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }

  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  void clearLines(){
    for(int row = colLength - 1; row >= 0; row--){
      bool rowIsFull = true;

      for(int col = 0; col < rowLength; col++){
        
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                  itemCount: rowLength * colLength,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength),
                  itemBuilder: (context, index) {
                    int row = (index / rowLength).floor();
                    int col = (index % rowLength);
                    if (currentPiece.position.contains(index)) {
                      return Pixel(
                          color: Colors.yellow, child: index.toString());
                    } else if (gameBoard[row][col] != null) {
                      final Tetromino? tetrominoType = gameBoard[row][col];
                      return Pixel(
                          color: tetrominoColors[tetrominoType], child: '');
                    } else {
                      return Pixel(
                          color: Colors.grey[900], child: index.toString());
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //left
                    IconButton(
                      onPressed: moveLeft,
                      color: Colors.white,
                      icon: Icon(Icons.arrow_back),
                      iconSize: 48.0,
                    ),
                    //rotate
                    IconButton(
                      onPressed: rotatePiece,
                      color: Colors.white,
                      icon: Icon(Icons.rotate_right),
                      iconSize: 48.0,
                    ),

                    //right
                    IconButton(
                      onPressed: moveRight,
                      color: Colors.white,
                      icon: Icon(Icons.arrow_forward),
                      iconSize: 48.0,
                    ),
                  ]),
            )
          ],
        ));
  }
}
