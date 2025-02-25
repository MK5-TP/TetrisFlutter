import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris/values.dart';
import 'pixel.dart';
import 'piece.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';

List<List<Tetromino?>> gameBoard =
    List.generate(colLength, (i) => List.generate(rowLength, (j) => null));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece =
      Piece(type: Tetromino.values[Random().nextInt(Tetromino.values.length)]);

  int currentScore = 0; //スコア

  bool gameOver = false;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double tiltThreshold = 3.0; // 傾きのしきい値

  double lastX = 0, lastY = 0, lastZ = 0;
  double shakeThreshold = 8.0; // 振りのしきい値

  late final AudioPlayer _bgmPlayer;

  @override
  void initState() {
    //初期状態
    super.initState();
    startAccelerometerListener();
    _bgmPlayer = AudioPlayer();
    startGame();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _bgmPlayer.dispose();
    super.dispose();
  }

  void startGame() {
    playBGM();
    currentPiece.initialaizePiece();

    //1フレームのレート
    Duration framerate = const Duration(milliseconds: 800);
    gameLoop(framerate);
  }

  void gameLoop(Duration framerate) {
    Timer.periodic(
      framerate,
      (timer) {
        setState(() {
          clearLines();
          checkLanding();
          if (gameOver) {
            timer.cancel();
            showGameOverDialog();
          }
          currentPiece.movePiece(Direction.down);
        });
      },
    );
  }
  void playBGM() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('8bit-casino-hitotooki.mp3'));
  }
  void stopBGM() async {
    await _bgmPlayer.stop();
  }
  void playSE(String filename) async {
    final sePlayer = AudioPlayer();
    await sePlayer.play(AssetSource('$filename'));
  }

  void showGameOverDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Game Over"),
              content: Text("Your Score is: $currentScore"),
              actions: [
                TextButton(
                    onPressed: () {
                      resetGame();
                      Navigator.pop(context);
                    },
                    child: Text("Play Again!"))
              ],
            ));
  }

  void resetGame() {
    gameBoard =
        List.generate(colLength, (i) => List.generate(rowLength, (j) => null));

    gameOver = false;
    currentScore = 0;

    createNewPiece();
    startGame();
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

    if (isGameOver()) {
      gameOver = true;
      stopBGM();
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
    //
    //3.playSE('8bit選択8.mp3');
  }

  void dropPiece() {
    setState(() {
      while (!checkCollision(Direction.down)) {
        currentPiece.movePiece(Direction.down);
      }
      checkLanding();
    });
  }

  //行消し
  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true; //その行のすべてにブロックが入っているか

      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      //消す操作
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] == List.generate(row, (index) => null);

        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  //加速度センサ
  void startAccelerometerListener() {
    accelerometerEventStream().listen((event) {
      handleTilt(event);
      handleShake(event);
    });
  }

  void handleTilt(AccelerometerEvent event) {
    if (event.x > tiltThreshold) {
      moveLeft();
    } else if (event.x < -tiltThreshold) {
      moveRight();
    }
  }

  void handleShake(AccelerometerEvent event) {
    double deltaX = (event.x - lastX).abs();
    double deltaY = (event.y - lastY).abs();
    double deltaZ = (event.z - lastZ).abs();

    if (deltaY > shakeThreshold 
        ) {
      dropPiece(); //振ってピース落下
    }

    lastX = event.x;
    lastY = event.y;
    lastZ = event.z;
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
                      return Pixel(color: Colors.yellow, child: '');
                    } else if (gameBoard[row][col] != null) {
                      final Tetromino? tetrominoType = gameBoard[row][col];
                      return Pixel(
                          color: tetrominoColors[tetrominoType], child: '');
                    } else {
                      return Pixel(color: Colors.grey[900], child: '');
                    }
                  }),
            ),
            Text(
              'Score: $currentScore',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 20),
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
                    //HardDrop
                    IconButton(
                      onPressed: dropPiece,
                      color: Colors.white,
                      icon: Icon(Icons.arrow_downward),
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
