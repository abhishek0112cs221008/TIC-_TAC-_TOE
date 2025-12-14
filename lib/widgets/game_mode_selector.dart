import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_mode.dart';
import '../services/ai_player.dart';
import '../theme/app_theme.dart';

class GameModeSelector extends StatelessWidget {
  const GameModeSelector({Key? key}) : super(key: key);

  void _showGameModeDialog(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colors = AppTheme.getColors(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surface.withOpacity(0.95),
                  colors.surface.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: colors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Game Mode',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 30),
                _buildModeCard(
                  context,
                  GameMode.vsPlayer,
                  '2 Players',
                  'Play with a friend',
                  Icons.people,
                  colors,
                ),
                const SizedBox(height: 15),
                _buildModeCard(
                  context,
                  GameMode.vsAI,
                  'vs AI',
                  'Challenge the computer',
                  Icons.smart_toy,
                  colors,
                ),
                if (gameProvider.gameMode == GameMode.vsAI) ...[
                  const SizedBox(height: 30),
                  Text(
                    'AI Difficulty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDifficultySelector(context, colors),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    GameMode mode,
    String title,
    String subtitle,
    IconData icon,
    ThemeColors colors,
  ) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isSelected = gameProvider.gameMode == mode;

    return GestureDetector(
      onTap: () {
        gameProvider.setGameMode(mode);
        if (mode == GameMode.vsPlayer) {
          Navigator.pop(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [colors.primary.withOpacity(0.3), colors.primary.withOpacity(0.1)]
                : [colors.surface.withOpacity(0.3), colors.surface.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : colors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? colors.primary : colors.primary.withOpacity(0.6),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colors.primary : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context, ThemeColors colors) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDifficultyChip(context, AIDifficulty.easy, 'Easy', colors),
        _buildDifficultyChip(context, AIDifficulty.medium, 'Medium', colors),
        _buildDifficultyChip(context, AIDifficulty.hard, 'Hard', colors),
      ],
    );
  }

  Widget _buildDifficultyChip(
    BuildContext context,
    AIDifficulty difficulty,
    String label,
    ThemeColors colors,
  ) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isSelected = gameProvider.aiDifficulty == difficulty;

    return GestureDetector(
      onTap: () => gameProvider.setAIDifficulty(difficulty),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? colors.accent : colors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);

    String modeText = gameProvider.gameMode == GameMode.vsPlayer ? '2 Players' : 'vs AI';
    if (gameProvider.gameMode == GameMode.vsAI) {
      String difficulty = gameProvider.aiDifficulty.toString().split('.').last;
      difficulty = difficulty[0].toUpperCase() + difficulty.substring(1);
      modeText += ' ($difficulty)';
    }

    return GestureDetector(
      onTap: () => _showGameModeDialog(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.secondary.withOpacity(0.3),
              colors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.secondary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              gameProvider.gameMode == GameMode.vsPlayer ? Icons.people : Icons.smart_toy,
              color: colors.secondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              modeText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.secondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: colors.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
