import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../theme/app_theme.dart';
import '../models/game_mode.dart';
import '../services/ai_player.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showGameEndPopup(bool isWin, String? winnerSymbol) {
    final colors = AppTheme.getColors(context);

    if (isWin) {
      _confettiController.play();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isWin ? colors.accent : colors.primary,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWin) ...[
                  Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: colors.accent,
                  ),
                  const SizedBox(height: 15),
                ],
                Text(
                  isWin ? 'Victory!' : "Draw!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isWin ? colors.accent : colors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                if (isWin) ...[
                  Text(
                    'Player $winnerSymbol Wins!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: winnerSymbol == 'X' ? colors.xColor : colors.oColor,
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<GameProvider>(context, listen: false).resetGame();
                    _confettiController.stop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                // Header with title and theme switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tic Tac Toe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.palette_outlined, color: colors.primary),
                        onPressed: () => _showThemeSelector(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Score Board
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreItem('X', gameProvider.stats.xWins, colors.xColor),
                      Container(
                        width: 1,
                        height: 40,
                        color: colors.primary.withOpacity(0.2),
                      ),
                      _buildScoreItem('Draw', gameProvider.stats.draws, colors.accent),
                      Container(
                        width: 1,
                        height: 40,
                        color: colors.primary.withOpacity(0.2),
                      ),
                      _buildScoreItem('O', gameProvider.stats.oWins, colors.oColor),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Current Player / AI Thinking
                if (!gameProvider.gameEnded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (gameProvider.isAIThinking) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.oColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'AI Thinking...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.oColor,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Player ${gameProvider.currentPlayer}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: gameProvider.currentPlayer == 'X'
                                  ? colors.xColor
                                  : colors.oColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Game Board
                Expanded(
                  child: Center(
                    child: GameBoard(
                      onWin: () {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _showGameEndPopup(true, gameProvider.winner);
                        });
                      },
                      onDraw: () {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _showGameEndPopup(false, null);
                        });
                      },
                    ),
                  ),
                ),
                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        context,
                        Icons.sports_esports_outlined,
                        gameProvider.gameMode.toString().split('.').last == 'vsPlayer' ? '2P' : 'AI',
                        colors.secondary,
                        () => _showGameModeSelector(context),
                      ),
                      _buildControlButton(
                        context,
                        Icons.refresh,
                        'New',
                        colors.primary,
                        () {
                          gameProvider.resetGame();
                          _confettiController.stop();
                        },
                      ),
                      _buildControlButton(
                        context,
                        Icons.settings_outlined,
                        'Set',
                        colors.accent,
                        () => _showSettings(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 15,
                minBlastForce: 8,
                emissionFrequency: 0.02,
                numberOfParticles: 25,
                gravity: 0.15,
                shouldLoop: false,
                colors: [
                  colors.primary,
                  colors.secondary,
                  colors.accent,
                  colors.xColor,
                  colors.oColor,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colors = AppTheme.getColors(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(context, AppThemeType.system, 'System', Icons.brightness_auto),
              const SizedBox(height: 12),
              _buildThemeOption(context, AppThemeType.pureBlack, 'Pure Black', Icons.dark_mode),
              const SizedBox(height: 12),
              _buildThemeOption(context, AppThemeType.pureWhite, 'Pure White', Icons.light_mode),
              const SizedBox(height: 12),
              _buildThemeOption(context, AppThemeType.airbnbUpi, 'Red & Green', Icons.auto_awesome),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, AppThemeType type, String label, IconData icon) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);
    final isSelected = gameProvider.currentTheme == type;

    return GestureDetector(
      onTap: () {
        gameProvider.setTheme(type);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.primary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: colors.primary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary),
          ],
        ),
      ),
    );
  }

  void _showGameModeSelector(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colors = AppTheme.getColors(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildGameModeOption(
                context,
                GameMode.vsPlayer,
                '2 Players',
                'Play with a friend',
                Icons.people,
              ),
              const SizedBox(height: 12),
              _buildGameModeOption(
                context,
                GameMode.vsAI,
                'vs AI',
                'Challenge the computer',
                Icons.smart_toy,
              ),
              if (gameProvider.gameMode == GameMode.vsAI) ...[
                const SizedBox(height: 20),
                Text(
                  'AI Difficulty',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDifficultyChip(context, AIDifficulty.easy, 'Easy'),
                    _buildDifficultyChip(context, AIDifficulty.medium, 'Medium'),
                    _buildDifficultyChip(context, AIDifficulty.hard, 'Hard'),
                  ],
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameModeOption(
    BuildContext context,
    GameMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);
    final isSelected = gameProvider.gameMode == mode;

    return GestureDetector(
      onTap: () {
        gameProvider.setGameMode(mode);
        if (mode == GameMode.vsPlayer) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.primary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context, AIDifficulty difficulty, String label) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);
    final isSelected = gameProvider.aiDifficulty == difficulty;

    return GestureDetector(
      onTap: () => gameProvider.setAIDifficulty(difficulty),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.accent : colors.primary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colors.background : colors.primary,
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colors = AppTheme.getColors(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingTile(
                context,
                'Sound Effects',
                'Play sounds during gameplay',
                Icons.volume_up,
                gameProvider.isSoundOn,
                (value) => gameProvider.toggleSound(),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                context,
                'Haptic Feedback',
                'Vibrate on moves',
                Icons.vibration,
                gameProvider.hapticFeedback,
                (value) => gameProvider.toggleHaptic(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await gameProvider.resetStats();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('All stats reset!'),
                        backgroundColor: colors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Reset All Stats'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.secondary,
                  foregroundColor: colors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final colors = AppTheme.getColors(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.primary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.accent,
          ),
        ],
      ),
    );
  }
}
