import 'dart:async';
import 'package:flutter/material.dart';
import '../logic/chess_logic.dart';
import '../logic/turn_manager.dart';

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
    if (logic.gameOver) return;

    bool moved = logic.handleTap(row, col, turnManager.isWhiteTurn);
    if (moved) {
      turnManager.switchTurn();

      final bool isWhiteTurn = turnManager.isWhiteTurn;
      final checkStatus = logic.isKingInCheck(isWhiteTurn);
      final hasEscapeMoves = logic.playerHasLegalMoves(isWhiteTurn);

      if (checkStatus && !hasEscapeMoves) {
        // XEQUE-MATE
        String winner = isWhiteTurn
            ? "⚫ Pretas venceram!"
            : "⚪ Brancas venceram!";
        logic.winner = winner; // Isso já "finaliza" o jogo
        showEndGameAlert(context, "♛ Xeque-mate! $winner");
      } else if (checkStatus) {
        String side = isWhiteTurn ? "branco" : "preto";
        showCheckAlert(context, "⚠️ O rei $side está em cheque!");
      } else if (!hasEscapeMoves) {
        logic.winner = "🤝 Empate por afogamento! Nenhum movimento possível.";
        showEndGameAlert(context, logic.winner!);
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

  void showEndGameAlert(BuildContext context, String winnerMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(winnerMessage, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text("⏱️ Brancas: ${turnManager.getFormattedTime(true)}"),
              Text("⏱️ Pretas: ${turnManager.getFormattedTime(false)}"),
              const SizedBox(height: 10),
              Text(
                logic.gameOver
                    ? logic.getWinner() ?? "🏁 Fim de Jogo"
                    : turnManager.isWhiteTurn
                    ? "Vez das Brancas ⚪"
                    : "Vez das Pretas ⚫",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

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

// Função auxiliar para detectar cheque (opcional se for usar getWinner dentro de logic)
Map<String, bool> checkKingsStatus(List<List<String>> board) {
  bool whiteInCheck = false;
  bool blackInCheck = false;
  int whiteKingRow = -1, whiteKingCol = -1;
  int blackKingRow = -1, blackKingCol = -1;

  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      if (board[r][c] == '♔') {
        whiteKingRow = r;
        whiteKingCol = c;
      } else if (board[r][c] == '♚') {
        blackKingRow = r;
        blackKingCol = c;
      }
    }
  }

  final logic = ChessLogic();
  logic.board = board;

  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      String piece = board[r][c];
      if (logic.isBlackPiece(piece)) {
        logic.calculateValidMoves(r, c);
        if (whiteKingRow != -1 &&
            logic.validMoves[whiteKingRow][whiteKingCol]) {
          whiteInCheck = true;
        }
      } else if (logic.isWhitePiece(piece)) {
        logic.calculateValidMoves(r, c);
        if (blackKingRow != -1 &&
            logic.validMoves[blackKingRow][blackKingCol]) {
          blackInCheck = true;
        }
      }
    }
  }

  return {'white': whiteInCheck, 'black': blackInCheck};
}
