import 'package:flutter/material.dart';
import '../logic/chess_logic.dart';

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  final ChessLogic logic = ChessLogic();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 64,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemBuilder: (context, index) {
        int row = index ~/ 8;
        int col = index % 8;

        bool isSelected = logic.isSelected(row, col);
        bool canMoveHere = logic.validMoves[row][col];

        Color baseColor =
            (row + col) % 2 == 0 ? Colors.brown[300]! : Colors.brown[100]!;
        Color color = isSelected
            ? Colors.blue.withOpacity(0.5)
            : canMoveHere
                ? Colors.green.withOpacity(0.5)
                : baseColor;

        return GestureDetector(
          onTap: () {
            setState(() {
              logic.handleTap(row, col);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black54),
            ),
            child: Center(
              child: Text(
                logic.board[row][col],
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}
