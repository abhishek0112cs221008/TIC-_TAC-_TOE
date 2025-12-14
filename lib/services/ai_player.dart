import 'dart:math';

enum AIDifficulty { easy, medium, hard }

class AIPlayer {
  final AIDifficulty difficulty;
  final Random _random = Random();

  AIPlayer({required this.difficulty});

  int getMove(List<String> board, String aiSymbol) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return _getRandomMove(board);
      case AIDifficulty.medium:
        return _getMediumMove(board, aiSymbol);
      case AIDifficulty.hard:
        return _getBestMove(board, aiSymbol);
    }
  }

  // Easy: Random move
  int _getRandomMove(List<String> board) {
    List<int> availableMoves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        availableMoves.add(i);
      }
    }
    return availableMoves[_random.nextInt(availableMoves.length)];
  }

  // Medium: Mix of smart and random moves
  int _getMediumMove(List<String> board, String aiSymbol) {
    String playerSymbol = aiSymbol == 'X' ? 'O' : 'X';

    // 50% chance to make a smart move
    if (_random.nextBool()) {
      // Try to win
      int? winMove = _findWinningMove(board, aiSymbol);
      if (winMove != null) return winMove;

      // Block opponent
      int? blockMove = _findWinningMove(board, playerSymbol);
      if (blockMove != null) return blockMove;
    }

    // Otherwise random
    return _getRandomMove(board);
  }

  // Hard: Minimax algorithm (unbeatable)
  int _getBestMove(List<String> board, String aiSymbol) {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        List<String> newBoard = List.from(board);
        newBoard[i] = aiSymbol;
        int score = _minimax(newBoard, 0, false, aiSymbol);
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    return bestMove;
  }

  int _minimax(List<String> board, int depth, bool isMaximizing, String aiSymbol) {
    String playerSymbol = aiSymbol == 'X' ? 'O' : 'X';
    String? winner = _checkWinner(board);

    if (winner == aiSymbol) return 10 - depth;
    if (winner == playerSymbol) return depth - 10;
    if (board.every((cell) => cell != '')) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          List<String> newBoard = List.from(board);
          newBoard[i] = aiSymbol;
          int score = _minimax(newBoard, depth + 1, false, aiSymbol);
          bestScore = max(bestScore, score);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          List<String> newBoard = List.from(board);
          newBoard[i] = playerSymbol;
          int score = _minimax(newBoard, depth + 1, true, aiSymbol);
          bestScore = min(bestScore, score);
        }
      }
      return bestScore;
    }
  }

  int? _findWinningMove(List<String> board, String symbol) {
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        List<String> testBoard = List.from(board);
        testBoard[i] = symbol;
        if (_checkWinner(testBoard) == symbol) {
          return i;
        }
      }
    }
    return null;
  }

  String? _checkWinner(List<String> board) {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (List<int> pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }
    return null;
  }
}
