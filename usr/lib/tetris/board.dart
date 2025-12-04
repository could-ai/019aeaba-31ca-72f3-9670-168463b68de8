import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'piece.dart';
import 'values.dart';

class TetrisBoard extends StatefulWidget {
  const TetrisBoard({super.key});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> {
  // The grid: null means empty, Color means occupied
  List<List<Color?>> gameBoard = List.generate(
    colLength,
    (i) => List.generate(rowLength, (j) => null),
  );

  Piece? currentPiece;
  int currentScore = 0;
  bool gameOver = false;
  bool isPaused = false;
  Timer? gameTimer;
  
  // Game speed (milliseconds)
  int speed = 500;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      // Reset board
      gameBoard = List.generate(
        colLength,
        (i) => List.generate(rowLength, (j) => null),
      );
      currentScore = 0;
      gameOver = false;
      isPaused = false;
      speed = 500;
      
      spawnNewPiece();
    });
    
    startTimer();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (!isPaused && !gameOver) {
        gameLoop();
      }
    });
  }

  void spawnNewPiece() {
    Random rand = Random();
    Tetromino type = Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: type);
    
    // Check if new piece collides immediately (Game Over)
    if (checkCollision(currentPiece!, rowOffset: 0, colOffset: 0)) {
      setState(() {
        gameOver = true;
      });
      gameTimer?.cancel();
    }
  }

  void gameLoop() {
    setState(() {
      // Try to move down
      if (!checkCollision(currentPiece!, rowOffset: 1, colOffset: 0)) {
        currentPiece!.move(1, 0);
      } else {
        // Land the piece
        lockPiece();
        clearLines();
        spawnNewPiece();
      }
    });
  }

  // Check if the piece would collide if moved by offset
  bool checkCollision(Piece piece, {int rowOffset = 0, int colOffset = 0}) {
    for (var point in piece.shape) {
      int r = piece.position[0] + point[0] + rowOffset;
      int c = piece.position[1] + point[1] + colOffset;

      // Check boundaries
      if (r >= colLength || c < 0 || c >= rowLength) {
        return true;
      }
      
      // Check occupied cells (only if inside board, ignore top out of bounds for now)
      if (r >= 0 && gameBoard[r][c] != null) {
        return true;
      }
    }
    return false;
  }

  void lockPiece() {
    for (var point in currentPiece!.shape) {
      int r = currentPiece!.position[0] + point[0];
      int c = currentPiece!.position[1] + point[1];
      
      if (r >= 0 && r < colLength && c >= 0 && c < rowLength) {
        gameBoard[r][c] = tetrominoColors[currentPiece!.type];
      }
    }
  }

  void clearLines() {
    int linesCleared = 0;
    
    // Check from bottom up
    for (int r = colLength - 1; r >= 0; r--) {
      bool isFull = true;
      for (int c = 0; c < rowLength; c++) {
        if (gameBoard[r][c] == null) {
          isFull = false;
          break;
        }
      }

      if (isFull) {
        // Move all rows above this one down
        for (int rowAbove = r; rowAbove > 0; rowAbove--) {
          gameBoard[rowAbove] = List.from(gameBoard[rowAbove - 1]);
        }
        // Clear top row
        gameBoard[0] = List.generate(rowLength, (index) => null);
        
        // Since we shifted down, we need to check this row index again
        r++; 
        linesCleared++;
      }
    }

    if (linesCleared > 0) {
      currentScore += linesCleared * 100;
      // Increase speed slightly
      if (speed > 100) speed -= 10;
      startTimer(); // Restart timer with new speed
    }
  }

  // Controls
  void moveLeft() {
    if (!gameOver && !isPaused && !checkCollision(currentPiece!, rowOffset: 0, colOffset: -1)) {
      setState(() {
        currentPiece!.move(0, -1);
      });
    }
  }

  void moveRight() {
    if (!gameOver && !isPaused && !checkCollision(currentPiece!, rowOffset: 0, colOffset: 1)) {
      setState(() {
        currentPiece!.move(0, 1);
      });
    }
  }

  void rotatePiece() {
    if (gameOver || isPaused) return;
    
    setState(() {
      currentPiece!.rotate();
      // If rotation causes collision, rotate back (simple wall kick prevention)
      if (checkCollision(currentPiece!)) {
        // Try kicking left
        if (!checkCollision(currentPiece!, colOffset: -1)) {
           currentPiece!.move(0, -1);
        } 
        // Try kicking right
        else if (!checkCollision(currentPiece!, colOffset: 1)) {
           currentPiece!.move(0, 1);
        }
        // Revert if still invalid
        else {
          // Rotate back 3 times (270 deg) to undo 90 deg, or just implement undo
          // Simpler: just reverse the math
          for (int i = 0; i < 3; i++) currentPiece!.rotate(); 
        }
      }
    });
  }

  void dropPiece() {
    if (gameOver || isPaused) return;
    // Move down until collision
    while (!checkCollision(currentPiece!, rowOffset: 1)) {
      currentPiece!.move(1, 0);
    }
    // Force immediate update
    gameLoop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('T E T R I S', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
            onPressed: () {
              setState(() {
                isPaused = !isPaused;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: startGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score Board
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Score: $currentScore',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Game Grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: rowLength / colLength,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    color: Colors.black,
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rowLength * colLength,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength,
                    ),
                    itemBuilder: (context, index) {
                      int r = index ~/ rowLength;
                      int c = index % rowLength;
                      
                      Color? cellColor = gameBoard[r][c];
                      
                      // Check if this cell is part of the current falling piece
                      if (currentPiece != null) {
                        for (var point in currentPiece!.shape) {
                          if (currentPiece!.position[0] + point[0] == r &&
                              currentPiece!.position[1] + point[1] == c) {
                            cellColor = tetrominoColors[currentPiece!.type];
                          }
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cellColor ?? Colors.grey[850],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // Game Over Overlay
          if (gameOver)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'GAME OVER',
                style: TextStyle(color: Colors.red[400], fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),

          // Controls
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlBtn(icon: Icons.arrow_back, onTap: moveLeft),
                _ControlBtn(icon: Icons.rotate_right, onTap: rotatePiece),
                _ControlBtn(icon: Icons.arrow_forward, onTap: moveRight),
                _ControlBtn(icon: Icons.arrow_downward, onTap: dropPiece),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _ControlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
