import 'package:flutter/material.dart';

// Grid Dimensions
const int rowLength = 10;
const int colLength = 20;

enum Tetromino { L, J, I, O, S, Z, T }

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Colors.orange,
  Tetromino.J: Colors.blue,
  Tetromino.I: Colors.cyan,
  Tetromino.O: Colors.yellow,
  Tetromino.S: Colors.green,
  Tetromino.Z: Colors.red,
  Tetromino.T: Colors.purple,
};

// Initial positions for each piece type (relative to center)
// We will define shapes using a list of integers representing the index in a 4x4 grid or similar,
// but simpler is to use relative (row, col) offsets.
// Let's use relative coordinates from a pivot point.

/*
  Shapes:
  L:
    *
    *
    * *

  J:
      *
      *
    * *

  I:
    *
    *
    *
    *

  O:
    * *
    * *

  S:
      * *
    * *

  Z:
    * *
      * *

  T:
    * * *
      *
*/

// Defining shapes as list of vectors (row, col)
const Map<Tetromino, List<List<int>>> tetrominoShapes = {
  Tetromino.L: [
    [-1, 0],
    [0, 0],
    [1, 0],
    [1, 1]
  ],
  Tetromino.J: [
    [-1, 0],
    [0, 0],
    [1, 0],
    [1, -1]
  ],
  Tetromino.I: [
    [-1, 0],
    [0, 0],
    [1, 0],
    [2, 0]
  ],
  Tetromino.O: [
    [0, 0],
    [0, 1],
    [1, 0],
    [1, 1]
  ],
  Tetromino.S: [
    [0, 0],
    [0, 1],
    [1, 0],
    [1, -1]
  ],
  Tetromino.Z: [
    [0, 0],
    [0, -1],
    [1, 0],
    [1, 1]
  ],
  Tetromino.T: [
    [-1, 0],
    [0, 0],
    [0, 1],
    [0, -1] // T is actually 3 wide, let's adjust: center at 0,0. Left 0,-1, Right 0,1, Top -1,0
  ],
};
