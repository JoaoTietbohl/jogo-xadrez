class ChessLogic {
  List<List<String>> board = [
    ['🏰', '🐎', '🎩', '👸', '♚', '🎩', '🐎', '🏰'], // pretas
    ['🛡️', '🛡️', '🛡️', '🛡️', '🛡️', '🛡️', '🛡️', '🛡️'], // peões pretos
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['⚔️', '⚔️', '⚔️', '⚔️', '⚔️', '⚔️', '⚔️', '⚔️'], // peões brancos
    ['🏰', '🐎', '🎩', '👸', '♔', '🎩', '🐎', '🏰'], // brancas
  ];

  List<List<bool>> validMoves = List.generate(8, (_) => List.filled(8, false));
  int? selectedRow;
  int? selectedCol;

  /// Trata o clique do usuário no tabuleiro
  bool handleTap(int row, int col, bool isWhiteTurn) {
  if (selectedRow == null) {
    if (board[row][col] != '-' &&
        ((isWhiteTurn && isWhitePiece(board[row][col])) ||
         (!isWhiteTurn && isBlackPiece(board[row][col])))) {
      selectedRow = row;
      selectedCol = col;
      calculateValidMoves(row, col);
    }
  } else {
    if (validMoves[row][col]) {
      board[row][col] = board[selectedRow!][selectedCol!];
      board[selectedRow!][selectedCol!] = '-';
      selectedRow = null;
      selectedCol = null;
      validMoves = List.generate(8, (_) => List.filled(8, false));
      return true; // jogada feita
    } else {
      selectedRow = null;
      selectedCol = null;
      validMoves = List.generate(8, (_) => List.filled(8, false));
    }
  }
  return false; // nenhuma jogada feita
}

  /// Verifica se a peça está selecionada
  bool isSelected(int row, int col) {
    return selectedRow == row && selectedCol == col;
  }

  /// Verifica se uma peça é branca
  bool isWhitePiece(String piece) {
    return ['⚔️', '🏰', '🐎', '🎩', '👸', '♔'].contains(piece);
  }

  /// Verifica se uma peça é preta
  bool isBlackPiece(String piece) {
    return ['🛡️', '🏰', '🐎', '🎩', '👸', '♚'].contains(piece);
  }

  /// Verifica se posição está dentro do tabuleiro
  bool inBounds(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  /// Calcula casas válidas para movimento da peça selecionada
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

    // Torre (🏰)
    if (piece == '🏰') {
      for (int r = row - 1; r >= 0; r--) {
        if (board[r][col] == '-') {
          validMoves[r][col] = true;
        } else {
          if (canMoveTo(r, col)) validMoves[r][col] = true;
          break;
        }
      }
      for (int r = row + 1; r < 8; r++) {
        if (board[r][col] == '-') {
          validMoves[r][col] = true;
        } else {
          if (canMoveTo(r, col)) validMoves[r][col] = true;
          break;
        }
      }
      for (int c = col - 1; c >= 0; c--) {
        if (board[row][c] == '-') {
          validMoves[row][c] = true;
        } else {
          if (canMoveTo(row, c)) validMoves[row][c] = true;
          break;
        }
      }
      for (int c = col + 1; c < 8; c++) {
        if (board[row][c] == '-') {
          validMoves[row][c] = true;
        } else {
          if (canMoveTo(row, c)) validMoves[row][c] = true;
          break;
        }
      }
    }

    // Cavalo (🐎)
    if (piece == '🐎') {
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

    // Bispo (🎩)
    if (piece == '🎩') {
      for (int i = 1; row - i >= 0 && col + i < 8; i++) {
        if (board[row - i][col + i] == '-') {
          validMoves[row - i][col + i] = true;
        } else {
          if (canMoveTo(row - i, col + i)) validMoves[row - i][col + i] = true;
          break;
        }
      }
      for (int i = 1; row - i >= 0 && col - i >= 0; i++) {
        if (board[row - i][col - i] == '-') {
          validMoves[row - i][col - i] = true;
        } else {
          if (canMoveTo(row - i, col - i)) validMoves[row - i][col - i] = true;
          break;
        }
      }
      for (int i = 1; row + i < 8 && col + i < 8; i++) {
        if (board[row + i][col + i] == '-') {
          validMoves[row + i][col + i] = true;
        } else {
          if (canMoveTo(row + i, col + i)) validMoves[row + i][col + i] = true;
          break;
        }
      }
      for (int i = 1; row + i < 8 && col - i >= 0; i++) {
        if (board[row + i][col - i] == '-') {
          validMoves[row + i][col - i] = true;
        } else {
          if (canMoveTo(row + i, col - i)) validMoves[row + i][col - i] = true;
          break;
        }
      }
    }

    // Rainha (👸)
    if (piece == '👸') {
      for (int r = row - 1; r >= 0; r--) {
        if (board[r][col] == '-') {
          validMoves[r][col] = true;
        } else {
          if (canMoveTo(r, col)) validMoves[r][col] = true;
          break;
        }
      }
      for (int r = row + 1; r < 8; r++) {
        if (board[r][col] == '-') {
          validMoves[r][col] = true;
        } else {
          if (canMoveTo(r, col)) validMoves[r][col] = true;
          break;
        }
      }
      for (int c = col - 1; c >= 0; c--) {
        if (board[row][c] == '-') {
          validMoves[row][c] = true;
        } else {
          if (canMoveTo(row, c)) validMoves[row][c] = true;
          break;
        }
      }
      for (int c = col + 1; c < 8; c++) {
        if (board[row][c] == '-') {
          validMoves[row][c] = true;
        } else {
          if (canMoveTo(row, c)) validMoves[row][c] = true;
          break;
        }
      }
      for (int i = 1; row - i >= 0 && col + i < 8; i++) {
        if (board[row - i][col + i] == '-') {
          validMoves[row - i][col + i] = true;
        } else {
          if (canMoveTo(row - i, col + i)) validMoves[row - i][col + i] = true;
          break;
        }
      }
      for (int i = 1; row - i >= 0 && col - i >= 0; i++) {
        if (board[row - i][col - i] == '-') {
          validMoves[row - i][col - i] = true;
        } else {
          if (canMoveTo(row - i, col - i)) validMoves[row - i][col - i] = true;
          break;
        }
      }
      for (int i = 1; row + i < 8 && col + i < 8; i++) {
        if (board[row + i][col + i] == '-') {
          validMoves[row + i][col + i] = true;
        } else {
          if (canMoveTo(row + i, col + i)) validMoves[row + i][col + i] = true;
          break;
        }
      }
      for (int i = 1; row + i < 8 && col - i >= 0; i++) {
        if (board[row + i][col - i] == '-') {
          validMoves[row + i][col - i] = true;
        } else {
          if (canMoveTo(row + i, col - i)) validMoves[row + i][col - i] = true;
          break;
        }
      }
    }

    // Rei
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

    // Peão preto (🛡️)
    if (piece == '🛡️') {
      int forwardRow = row + 1;
      if (inBounds(forwardRow, col) && board[forwardRow][col] == '-') {
        validMoves[forwardRow][col] = true;
        if (row == 1 && board[row + 2][col] == '-') {
          validMoves[row + 2][col] = true;
        }
      }
      if (inBounds(forwardRow, col - 1) &&
          board[forwardRow][col - 1] != '-' &&
          isWhitePiece(board[forwardRow][col - 1])) {
        validMoves[forwardRow][col - 1] = true;
      }
      if (inBounds(forwardRow, col + 1) &&
          board[forwardRow][col + 1] != '-' &&
          isWhitePiece(board[forwardRow][col + 1])) {
        validMoves[forwardRow][col + 1] = true;
      }
    }

    // Peão branco (⚔️)
    if (piece == '⚔️') {
      int forwardRow = row - 1;
      if (inBounds(forwardRow, col) && board[forwardRow][col] == '-') {
        validMoves[forwardRow][col] = true;
        if (row == 6 && board[row - 2][col] == '-') {
          validMoves[row - 2][col] = true;
        }
      }
      if (inBounds(forwardRow, col - 1) &&
          board[forwardRow][col - 1] != '-' &&
          isBlackPiece(board[forwardRow][col - 1])) {
        validMoves[forwardRow][col - 1] = true;
      }
      if (inBounds(forwardRow, col + 1) &&
          board[forwardRow][col + 1] != '-' &&
          isBlackPiece(board[forwardRow][col + 1])) {
        validMoves[forwardRow][col + 1] = true;
      }
    }
  }

  /// Acesso direto às jogadas válidas fora da classe
  List<List<bool>> getValidMoves() {
    return validMoves;
  }
}
