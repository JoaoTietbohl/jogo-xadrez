bool inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

Map<String, bool> checkKingsStatus(List<List<String>> board) {
  bool isThreatAt(int r, int c, int kingRow, int kingCol) {
    // Simples: se a peça estiver na posição do rei
    return r == kingRow && c == kingCol;
  }

  List<int>? findKing(String symbol) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] == symbol) {
          return [r, c];
        }
      }
    }
    return null;
  }

  // Encontra os reis com base nos seus símbolos
  final whiteKing = findKing('♔');
  final blackKing = findKing('♚');

  bool whiteInCheck = false;
  bool blackInCheck = false;

  // Verifica se alguma peça preta ameaça o rei branco
  if (whiteKing != null) {
    int wr = whiteKing[0], wc = whiteKing[1];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String piece = board[r][c];
        if (['🏯', '🐴', '🎓', '🤴', '♚', '🛡️'].contains(piece)) {
          if (isThreatAt(r, c, wr, wc)) {
            whiteInCheck = true;
          }
        }
      }
    }
  }

  // Verifica se alguma peça branca ameaça o rei preto
  if (blackKing != null) {
    int br = blackKing[0], bc = blackKing[1];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String piece = board[r][c];
        if (['🏰', '🐎', '🎩', '👸', '♔', '⚔️'].contains(piece)) {
          if (isThreatAt(r, c, br, bc)) {
            blackInCheck = true;
          }
        }
      }
    }
  }

  return {
    'white': whiteInCheck,
    'black': blackInCheck,
  };
}
