import 'package:shared_preferences/shared_preferences.dart';

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

  // Save stats to persistent storage
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('x_wins', xWins);
      await prefs.setInt('o_wins', oWins);
      await prefs.setInt('draws', draws);
    } catch (e) {
      print('Error saving stats: $e');
    }
  }

  // Load stats from persistent storage
  static Future<GameStats> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return GameStats(
        xWins: prefs.getInt('x_wins') ?? 0,
        oWins: prefs.getInt('o_wins') ?? 0,
        draws: prefs.getInt('draws') ?? 0,
      );
    } catch (e) {
      print('Error loading stats: $e');
      return GameStats();
    }
  }

  // Reset all stats
  Future<void> reset() async {
    xWins = 0;
    oWins = 0;
    draws = 0;
    await save();
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
