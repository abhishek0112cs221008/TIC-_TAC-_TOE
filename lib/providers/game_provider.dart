import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/game_stats.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../services/ai_player.dart';

class GameProvider extends ChangeNotifier {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  bool _gameEnded = false;
  String? _winner;
  List<int> _winningLine = [];
  bool _isSoundOn = true;
  bool _hapticFeedback = true;
  AppThemeType _currentTheme = AppThemeType.system;
  GameStats _stats = GameStats();
  GameMode _gameMode = GameMode.vsPlayer;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;
  late AIPlayer _aiPlayer;
  bool _isAIThinking = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getters
  List<String> get board => _board;
  String get currentPlayer => _currentPlayer;
  bool get gameEnded => _gameEnded;
  String? get winner => _winner;
  List<int> get winningLine => _winningLine;
  bool get isSoundOn => _isSoundOn;
  bool get hapticFeedback => _hapticFeedback;
  AppThemeType get currentTheme => _currentTheme;
  GameStats get stats => _stats;
  GameMode get gameMode => _gameMode;
  AIDifficulty get aiDifficulty => _aiDifficulty;
  bool get isAIThinking => _isAIThinking;

  GameProvider() {
    _loadStats();
    _aiPlayer = AIPlayer(difficulty: _aiDifficulty);
  }

  Future<void> _loadStats() async {
    _stats = await GameStats.load();
    notifyListeners();
  }

  void setTheme(AppThemeType theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  void setGameMode(GameMode mode) {
    _gameMode = mode;
    resetGame();
    notifyListeners();
  }

  void setAIDifficulty(AIDifficulty difficulty) {
    _aiDifficulty = difficulty;
    _aiPlayer = AIPlayer(difficulty: difficulty);
    notifyListeners();
  }

  Future<void> resetStats() async {
    await _stats.reset();
    _stats = await GameStats.load();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    notifyListeners();
  }

  void toggleHaptic() {
    _hapticFeedback = !_hapticFeedback;
    notifyListeners();
  }

  Future<void> _playMoveSound() async {
    if (!_isSoundOn) return;
    try {
      if (_hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      await _audioPlayer.play(AssetSource('audio/move_sound.mp3'));
    } catch (e) {
      debugPrint('Error playing move sound: $e');
    }
  }

  Future<void> _playWinSound() async {
    if (!_isSoundOn) return;
    try {
      if (_hapticFeedback) {
        HapticFeedback.mediumImpact();
      }
      await _audioPlayer.play(AssetSource('audio/win_sound.mp3'));
    } catch (e) {
      debugPrint('Error playing win sound: $e');
    }
  }

  Future<void> makeMove(int index, VoidCallback onWin, VoidCallback onDraw) async {
    if (_board[index] != '' || _gameEnded || _isAIThinking) return;

    _board[index] = _currentPlayer;
    _playMoveSound();
    
    // Check for winner
    String? gameWinner = _checkWinner();
    
    if (gameWinner != null) {
      _winner = gameWinner;
      _gameEnded = true;
      _stats.recordWin(gameWinner);
      _stats.save();
      _playWinSound();
      onWin();
    } else if (_board.every((cell) => cell != '')) {
      _gameEnded = true;
      _stats.recordDraw();
      _stats.save();
      onDraw();
    } else {
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      
      // If AI mode and it's AI's turn
      if (_gameMode == GameMode.vsAI && _currentPlayer == 'O') {
        notifyListeners();
        await _makeAIMove(onWin, onDraw);
        return;
      }
    }
    
    notifyListeners();
  }

  Future<void> _makeAIMove(VoidCallback onWin, VoidCallback onDraw) async {
    _isAIThinking = true;
    notifyListeners();

    // Add delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    int aiMove = _aiPlayer.getMove(_board, 'O');
    _board[aiMove] = 'O';
    _playMoveSound();

    String? gameWinner = _checkWinner();
    
    if (gameWinner != null) {
      _winner = gameWinner;
      _gameEnded = true;
      _stats.recordWin(gameWinner);
      _stats.save();
      _playWinSound();
      _isAIThinking = false;
      notifyListeners();
      onWin();
    } else if (_board.every((cell) => cell != '')) {
      _gameEnded = true;
      _stats.recordDraw();
      _stats.save();
      _isAIThinking = false;
      notifyListeners();
      onDraw();
    } else {
      _currentPlayer = 'X';
      _isAIThinking = false;
      notifyListeners();
    }
  }

  String? _checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (List<int> pattern in winPatterns) {
      if (_board[pattern[0]] != '' &&
          _board[pattern[0]] == _board[pattern[1]] &&
          _board[pattern[1]] == _board[pattern[2]]) {
        _winningLine = pattern;
        return _board[pattern[0]];
      }
    }
    return null;
  }

  void resetGame() {
    _board = List.filled(9, '');
    _currentPlayer = 'X';
    _gameEnded = false;
    _winner = null;
    _winningLine = [];
    _isAIThinking = false;
    notifyListeners();
  }
}
