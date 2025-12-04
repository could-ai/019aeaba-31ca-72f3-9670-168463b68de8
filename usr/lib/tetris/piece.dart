import 'package:flutter/material.dart';
import 'values.dart';

class Piece {
  Tetromino type;
  List<int> position = []; // The pivot position [row, col] on the board

  // The current shape positions relative to the pivot
  List<List<int>> shape = [];

  Piece({required this.type}) {
    // Deep copy the shape definition so we can modify it (rotate)
    shape = List.from(tetrominoShapes[type]!.map((e) => List<int>.from(e)));
    
    // Start position (top middle of board)
    position = [0, 4]; 
  }

  void move(int rowOffset, int colOffset) {
    position[0] += rowOffset;
    position[1] += colOffset;
  }

  void rotate() {
    // O piece doesn't rotate
    if (type == Tetromino.O) return;

    // Simple rotation: (x, y) -> (y, -x)
    // In our row/col system: (row, col) -> (col, -row)
    // Wait, standard 2D rotation 90 deg clockwise is (x,y) -> (y, -x).
    // Here row is y (down is positive), col is x (right is positive).
    // So (r, c) -> (c, -r) might work? Let's try standard matrix.
    // x' = x cos 90 - y sin 90 = -y
    // y' = x sin 90 + y cos 90 = x
    // So (x, y) -> (-y, x).
    // Mapping to (row, col): row is y, col is x.
    // new_col = -old_row
    // new_row = old_col
    // But we need to be careful with coordinate systems.
    
    for (int i = 0; i < shape.length; i++) {
      int r = shape[i][0];
      int c = shape[i][1];

      // Clockwise rotation
      shape[i][0] = c;
      shape[i][1] = -r;
    }
  }
}
