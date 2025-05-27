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

  bool handleTap(int row, int col, bool isWhiteTurn) {
    if (winner != null) return false;

    if (selectedRow == null) {
      if (board[row][col] != '-' &&
          ((isWhiteTurn && isWhitePiece(board[row][col])) ||
              (!isWhiteTurn && isBlackPiece(board[row][col])))) {
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

        selectedRow = null;
        selectedCol = null;
        validMoves = List.generate(8, (_) => List.filled(8, false));

        if (captured == '♔') {
          winner = 'Pretas venceram!';
        } else if (captured == '♚') {
          winner = 'Brancas venceram!';
        }

        return true;
      } else {
        selectedRow = null;
        selectedCol = null;
        validMoves = List.generate(8, (_) => List.filled(8, false));
      }
    }
    return false;
  }

  bool isSelected(int row, int col) {
    return selectedRow == row && selectedCol == col;
  }

  bool isWhitePiece(String piece) {
    return ['⚔️', '🏰', '🐎', '🎩', '👸', '♔'].contains(piece);
  }

  bool isBlackPiece(String piece) {
    return ['🛡️', '🏯', '🐴', '🎓', '🤴', '♚'].contains(piece);
  }

  bool inBounds(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  void calculateValidMoves(int row, int col) {
    validMoves = List.generate(8, (_) => List.filled(8, false));
    String piece = board[row][col];

    bool isWhite = isWhitePiece(piece);
    bool isBlack = isBlackPiece(piece);

    bool canMoveTo(int r, int c) {
      if (!inBounds(r, c)) return false;
      String target = board[r][c];
      if (target == '-') return true;
      if (isWhite && isBlackPiece(target)) return true;
      if (isBlack && isWhitePiece(target)) return true;
      return false;
    }

    void addDirectionalMoves(List<List<int>> directions) {
      for (var dir in directions) {
        int dr = dir[0], dc = dir[1];
        int r = row + dr, c = col + dc;
        while (inBounds(r, c)) {
          if (board[r][c] == '-') {
            validMoves[r][c] = true;
          } else {
            if (canMoveTo(r, c)) validMoves[r][c] = true;
            break;
          }
          r += dr;
          c += dc;
        }
      }
    }

    if (piece == '🏰' || piece == '🏯') {
      addDirectionalMoves([
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1]
      ]);
    }

    if (piece == '🎩' || piece == '🎓') {
      addDirectionalMoves([
        [-1, -1],
        [-1, 1],
        [1, -1],
        [1, 1]
      ]);
    }

    if (piece == '👸' || piece == '🤴') {
      addDirectionalMoves([
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
        [-1, -1],
        [-1, 1],
        [1, -1],
        [1, 1]
      ]);
    }

    if (piece == '🐎' || piece == '🐴') {
      List<List<int>> moves = [
        [row - 2, col - 1],
        [row - 2, col + 1],
        [row - 1, col - 2],
        [row - 1, col + 2],
        [row + 1, col - 2],
        [row + 1, col + 2],
        [row + 2, col - 1],
        [row + 2, col + 1],
      ];
      for (var m in moves) {
        int r = m[0], c = m[1];
        if (inBounds(r, c) && canMoveTo(r, c)) {
          validMoves[r][c] = true;
        }
      }
    }

    if (piece == '♔' || piece == '♚') {
      List<List<int>> moves = [
        [row - 1, col - 1],
        [row - 1, col],
        [row - 1, col + 1],
        [row, col - 1],
        [row, col + 1],
        [row + 1, col - 1],
        [row + 1, col],
        [row + 1, col + 1],
      ];
      for (var m in moves) {
        int r = m[0], c = m[1];
        if (inBounds(r, c) && canMoveTo(r, c)) {
          validMoves[r][c] = true;
        }
      }
    }

    if (piece == '🛡️') {
      int forwardRow = row + 1;
      if (inBounds(forwardRow, col) && board[forwardRow][col] == '-') {
        validMoves[forwardRow][col] = true;
        if (row == 1 && board[row + 2][col] == '-') {
          validMoves[row + 2][col] = true;
        }
      }
      if (inBounds(forwardRow, col - 1) &&
          isWhitePiece(board[forwardRow][col - 1])) {
        validMoves[forwardRow][col - 1] = true;
      }
      if (inBounds(forwardRow, col + 1) &&
          isWhitePiece(board[forwardRow][col + 1])) {
        validMoves[forwardRow][col + 1] = true;
      }
    }

    if (piece == '⚔️') {
      int forwardRow = row - 1;
      if (inBounds(forwardRow, col) && board[forwardRow][col] == '-') {
        validMoves[forwardRow][col] = true;
        if (row == 6 && board[row - 2][col] == '-') {
          validMoves[row - 2][col] = true;
        }
      }
      if (inBounds(forwardRow, col - 1) &&
          isBlackPiece(board[forwardRow][col - 1])) {
        validMoves[forwardRow][col - 1] = true;
      }
      if (inBounds(forwardRow, col + 1) &&
          isBlackPiece(board[forwardRow][col + 1])) {
        validMoves[forwardRow][col + 1] = true;
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
          bool stillSafe = !isInCheck(isWhiteTurn);
          board[selectedRow!][selectedCol!] = board[r][c];
          board[r][c] = temp;
          if (stillSafe) {
            filtered[r][c] = true;
          }
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

  List<List<bool>> getValidMoves() => validMoves;

  String? getWinner() => winner;
}
