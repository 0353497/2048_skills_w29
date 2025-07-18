
import 'package:flutter/material.dart';

class GameBackground extends StatelessWidget {
  final int size;
  final double cellSize;
  final double cellSpacing;

  const GameBackground({
    super.key, 
    required this.size, 
    required this.cellSize, 
    required this.cellSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(cellSpacing),
      child: Stack(
        children: [
          for (int row = 0; row < size; row++)
            for (int col = 0; col < size; col++)
              Positioned(
                left: col * (cellSize + cellSpacing),
                top: row * (cellSize + cellSpacing),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}