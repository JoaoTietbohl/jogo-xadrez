import 'dart:async';
import 'package:flutter/material.dart';
import '../logic/chess_logic.dart';
import '../logic/turn_manager.dart';
import '../logic/check.dart'; // Importação da verificação de cheque

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  final ChessLogic logic = ChessLogic();
  final TurnManager turnManager = TurnManager();

  late Timer _uiTimer;

  @override
  void initState() {
    super.initState();
    turnManager.start();

    // Atualiza a interface a cada segundo
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer.cancel();
    turnManager.stop();
    super.dispose();
  }

  void handleTap(int row, int col) {
    bool moved = logic.handleTap(row, col, turnManager.isWhiteTurn);
    if (moved) {
      turnManager.switchTurn();

      // Verifica se algum rei está em cheque
      final checkStatus = checkKingsStatus(logic.board);
      if (checkStatus['white'] == true) {
        showCheckAlert(context, "⚠️ O rei branco está em cheque!");
      }
      if (checkStatus['black'] == true) {
        showCheckAlert(context, "⚠️ O rei preto está em cheque!");
      }
    }

    setState(() {});
  }

  void showCheckAlert(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cronômetro e status do turno
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(
                "⏱️ Brancas: ${turnManager.getFormattedTime(true)}",
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "⏱️ Pretas: ${turnManager.getFormattedTime(false)}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                turnManager.isWhiteTurn ? "Vez das Brancas ⚪" : "Vez das Pretas ⚫",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Tabuleiro
        Expanded(
          child: GridView.builder(
            itemCount: 64,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemBuilder: (context, index) {
              int row = index ~/ 8;
              int col = index % 8;

              bool isSelected = logic.isSelected(row, col);
              bool canMoveHere = logic.validMoves[row][col];

              Color baseColor = (row + col) % 2 == 0
                  ? Colors.brown[300]!
                  : Colors.brown[100]!;
              Color color = isSelected
                  ? Colors.blue.withOpacity(0.5)
                  : canMoveHere
                      ? Colors.green.withOpacity(0.5)
                      : baseColor;

              return GestureDetector(
                onTap: () => handleTap(row, col),
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
          ),
        ),
      ],
    );
  }
}
