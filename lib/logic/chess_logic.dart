class ChessLogic {
  List<List<String>> board = [
    ['🏯', '🐴', '🎓', '🤴', '♚', '🎓', '🐴', '🏯'],
    ['🛡️', '🛡️', '🛡️', '🛡️', '🛡️', '🛡️', '🛡️', '🛡️'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['⚔️', '⚔️', '⚔️', '⚔️', '⚔️', '⚔️', '⚔️', '⚔️'],
    ['🏰', '🐎', '🎩', '👸', '♔', '🎩', '🐎', '🏰'],
  ];

  List<List<bool>> validMoves = List.generate(8, (_) => List.filled(8, false));
  int? selectedRow;
  int? selectedCol;
  String? winner;

  bool get gameOver => winner != null;

  bool handleTap(int row, int col, bool isWhiteTurn) {
    if (winner != null) return false;

    String selectedPiece = board[row][col];
    if (selectedRow == null) {
      if (selectedPiece != '-' &&
          ((isWhiteTurn && isWhitePiece(selectedPiece)) ||
              (!isWhiteTurn && isBlackPiece(selectedPiece)))) {
        selectedRow = row;
        selectedCol = col;
        calculateValidMoves(row, col);
        removeMovesThatLeaveKingInCheck(isWhiteTurn);
      }
    } else {
      if (validMoves[row][col]) {
        String piece = board[selectedRow!][selectedCol!];
        String captured = board[row][col];
        board[row][col] = piece;
        board[selectedRow!][selectedCol!] = '-';

        if (captured == '♔') {
          winner = 'Pretas venceram!';
        } else if (captured == '♚') {
          winner = 'Brancas venceram!';
        }

        clearSelection();
        return true;
      } else {
        clearSelection();
      }
    }
    return false;
  }

  void clearSelection() {
    selectedRow = null;
    selectedCol = null;
    validMoves = List.generate(8, (_) => List.filled(8, false));
  }

  bool isSelected(int row, int col) => selectedRow == row && selectedCol == col;

  bool isWhitePiece(String piece) =>
      ['⚔️', '🏰', '🐎', '🎩', '👸', '♔'].contains(piece);

  bool isBlackPiece(String piece) =>
      ['🛡️', '🏯', '🐴', '🎓', '🤴', '♚'].contains(piece);

  bool inBounds(int row, int col) => row >= 0 && row < 8 && col >= 0 && col < 8;

  void calculateValidMoves(int row, int col) {
    validMoves = List.generate(8, (_) => List.filled(8, false));
    String piece = board[row][col];

    bool isWhite = isWhitePiece(piece);
    bool isBlack = isBlackPiece(piece);

    bool canMoveTo(int r, int c) {
      if (!inBounds(r, c)) return false;
      String target = board[r][c];
      return target == '-' ||
          (isWhite && isBlackPiece(target)) ||
          (isBlack && isWhitePiece(target));
    }

    void addDirectionalMoves(List<List<int>> directions) {
      for (var dir in directions) {
        int r = row + dir[0], c = col + dir[1];
        while (inBounds(r, c)) {
          if (board[r][c] == '-') {
            validMoves[r][c] = true;
          } else {
            if (canMoveTo(r, c)) validMoves[r][c] = true;
            break;
          }
          r += dir[0];
          c += dir[1];
        }
      }
    }

    if (['🏰', '🏯'].contains(piece)) {
      addDirectionalMoves([
        [-1, 0], [1, 0], [0, -1], [0, 1]
      ]);
    }

    if (['🎩', '🎓'].contains(piece)) {
      addDirectionalMoves([
        [-1, -1], [-1, 1], [1, -1], [1, 1]
      ]);
    }

    if (['👸', '🤴'].contains(piece)) {
      addDirectionalMoves([
        [-1, 0], [1, 0], [0, -1], [0, 1],
        [-1, -1], [-1, 1], [1, -1], [1, 1]
      ]);
    }

    if (['🐎', '🐴'].contains(piece)) {
      for (var offset in [
        [-2, -1], [-2, 1], [-1, -2], [-1, 2],
        [1, -2], [1, 2], [2, -1], [2, 1]
      ]) {
        int r = row + offset[0], c = col + offset[1];
        if (inBounds(r, c) && canMoveTo(r, c)) validMoves[r][c] = true;
      }
    }

    if (['♔', '♚'].contains(piece)) {
      for (var offset in [
        [-1, -1], [-1, 0], [-1, 1],
        [0, -1],          [0, 1],
        [1, -1],  [1, 0], [1, 1]
      ]) {
        int r = row + offset[0], c = col + offset[1];
        if (inBounds(r, c) && canMoveTo(r, c)) validMoves[r][c] = true;
      }
    }

    if (piece == '🛡️' || piece == '⚔️') {
      int direction = piece == '🛡️' ? 1 : -1;
      int startRow = piece == '🛡️' ? 1 : 6;

      if (inBounds(row + direction, col) && board[row + direction][col] == '-') {
        validMoves[row + direction][col] = true;
        if (row == startRow && board[row + 2 * direction][col] == '-') {
          validMoves[row + 2 * direction][col] = true;
        }
      }

      for (int dc in [-1, 1]) {
        int r = row + direction, c = col + dc;
        if (inBounds(r, c)) {
          String target = board[r][c];
          if ((piece == '🛡️' && isWhitePiece(target)) ||
              (piece == '⚔️' && isBlackPiece(target))) {
            validMoves[r][c] = true;
          }
        }
      }
    }
  }

  void removeMovesThatLeaveKingInCheck(bool isWhiteTurn) {
    List<List<bool>> original = validMoves.map((row) => List.of(row)).toList();
    List<List<bool>> filtered = List.generate(8, (_) => List.filled(8, false));

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (original[r][c]) {
          String temp = board[r][c];
          board[r][c] = board[selectedRow!][selectedCol!];
          board[selectedRow!][selectedCol!] = '-';
          bool safe = !isInCheck(isWhiteTurn);
          board[selectedRow!][selectedCol!] = board[r][c];
          board[r][c] = temp;
          if (safe) filtered[r][c] = true;
        }
      }
    }

    validMoves = filtered;
  }

  bool isInCheck(bool isWhiteTurn) {
    String king = isWhiteTurn ? '♔' : '♚';
    int kingRow = -1, kingCol = -1;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] == king) {
          kingRow = r;
          kingCol = c;
        }
      }
    }

    if (kingRow == -1) return true;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String piece = board[r][c];
        if ((isWhiteTurn && isBlackPiece(piece)) ||
            (!isWhiteTurn && isWhitePiece(piece))) {
          calculateValidMoves(r, c);
          if (validMoves[kingRow][kingCol]) return true;
        }
      }
    }

    return false;
  }

  bool playerHasLegalMoves(bool isWhiteTurn) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String piece = board[r][c];
        if ((isWhiteTurn && isWhitePiece(piece)) ||
            (!isWhiteTurn && isBlackPiece(piece))) {
          selectedRow = r;
          selectedCol = c;
          calculateValidMoves(r, c);
          removeMovesThatLeaveKingInCheck(isWhiteTurn);
          if (validMoves.any((row) => row.contains(true))) {
            clearSelection();
            return true;
          }
        }
      }
    }
    clearSelection();
    return false;
  }

  bool isKingInCheck(bool isWhiteTurn) => isInCheck(isWhiteTurn);

  List<List<bool>> getValidMoves() => validMoves;
  String? getWinner() => winner;
}
