class GameStats {
  int xWins;
  int oWins;
  int draws;

  GameStats({
    this.xWins = 0,
    this.oWins = 0,
    this.draws = 0,
  });

  int get totalGames => xWins + oWins + draws;

  // Save stats (in-memory for now)
  Future<void> save() async {
    // Stats are kept in memory
  }

  // Load stats (in-memory for now)
  static Future<GameStats> load() async {
    return GameStats();
  }

  // Reset all stats
  Future<void> reset() async {
    xWins = 0;
    oWins = 0;
    draws = 0;
  }

  void recordWin(String winner) {
    if (winner == 'X') {
      xWins++;
    } else if (winner == 'O') {
      oWins++;
    }
  }

  void recordDraw() {
    draws++;
  }
}
