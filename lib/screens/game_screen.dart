import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/settings_dialog.dart';
import '../theme/app_theme.dart';
import '../models/game_mode.dart';
import '../services/ai_player.dart';
import '../utils/responsive_helper.dart';
import '../widgets/glass_container.dart';

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
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getDialogWidth(context),
            ),
            child: Container(
              padding: ResponsiveHelper.getResponsivePadding(context),
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
                      size: ResponsiveHelper.getResponsiveValue(
                        context,
                        mobile: 50.0,
                        tablet: 60.0,
                        desktop: 70.0,
                      ),
                      color: colors.accent,
                    ),
                    const SizedBox(height: 15),
                  ],
                  Text(
                    isWin ? 'Victory!' : "Draw!",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 24.0,
                        tablet: 26.0,
                        desktop: 28.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: isWin ? colors.accent : colors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isWin) ...[
                    Text(
                      'Player $winnerSymbol Wins!',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16.0,
                          tablet: 17.0,
                          desktop: 18.0,
                        ),
                        fontWeight: FontWeight.w600,
                        color:
                            winnerSymbol == 'X' ? colors.xColor : colors.oColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Provider.of<GameProvider>(
                        context,
                        listen: false,
                      ).resetGame();
                      _confettiController.stop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
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
      body: Container(
        decoration:
            (gameProvider.currentTheme == AppThemeType.glassGreen ||
                    gameProvider.currentTheme == AppThemeType.glassRed)
                ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.gradientStart, colors.gradientEnd],
                  ),
                )
                : null,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 16.0,
                      tablet: 20.0,
                      desktop: 24.0,
                    ),
                  ),
                  // Header with title and theme switcher
                  Padding(
                    padding: ResponsiveHelper.getResponsiveHorizontalPadding(
                      context,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tic Tac Toe PRO',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 24.0,
                              tablet: 28.0,
                              desktop: 32.0,
                            ),
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.palette_outlined,
                            color: colors.primary,
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                          ),
                          onPressed: () => _showThemeSelector(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 16.0,
                      tablet: 20.0,
                      desktop: 24.0,
                    ),
                  ),
                  // Score Board
                  (gameProvider.currentTheme == AppThemeType.glassGreen ||
                          gameProvider.currentTheme == AppThemeType.glassRed)
                      ? GlassContainer(
                        margin: ResponsiveHelper.getResponsiveHorizontalPadding(
                          context,
                        ),
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        blur: 15,
                        opacity: 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildScoreItem(
                              'X',
                              gameProvider.stats.xWins,
                              colors.xColor,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: colors.primary.withOpacity(0.2),
                            ),
                            _buildScoreItem(
                              'Draw',
                              gameProvider.stats.draws,
                              colors.accent,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: colors.primary.withOpacity(0.2),
                            ),
                            _buildScoreItem(
                              'O',
                              gameProvider.stats.oWins,
                              colors.oColor,
                            ),
                          ],
                        ),
                      )
                      : Container(
                        margin: ResponsiveHelper.getResponsiveHorizontalPadding(
                          context,
                        ),
                        padding: ResponsiveHelper.getResponsivePadding(context),
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
                            _buildScoreItem(
                              'X',
                              gameProvider.stats.xWins,
                              colors.xColor,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: colors.primary.withOpacity(0.2),
                            ),
                            _buildScoreItem(
                              'Draw',
                              gameProvider.stats.draws,
                              colors.accent,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: colors.primary.withOpacity(0.2),
                            ),
                            _buildScoreItem(
                              'O',
                              gameProvider.stats.oWins,
                              colors.oColor,
                            ),
                          ],
                        ),
                      ),
                  SizedBox(
                    height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 16.0,
                      tablet: 20.0,
                      desktop: 24.0,
                    ),
                  ),
                  // Current Player / AI Thinking
                  if (!gameProvider.gameEnded)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(
                          context,
                          mobile: 16.0,
                          tablet: 20.0,
                          desktop: 24.0,
                        ),
                        vertical: ResponsiveHelper.getSpacing(
                          context,
                          mobile: 10.0,
                          tablet: 12.0,
                          desktop: 14.0,
                        ),
                      ),
                      margin: ResponsiveHelper.getResponsiveHorizontalPadding(
                        context,
                      ),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.oColor,
                                ),
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
                                color:
                                    gameProvider.currentPlayer == 'X'
                                        ? colors.xColor
                                        : colors.oColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  SizedBox(
                    height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 12.0,
                      tablet: 16.0,
                      desktop: 20.0,
                    ),
                  ),
                  // Game Board
                  Expanded(
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
                  // Bottom Controls
                  Padding(
                    padding: ResponsiveHelper.getResponsivePadding(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          context,
                          Icons.sports_esports_outlined,
                          gameProvider.gameMode.toString().split('.').last ==
                                  'vsPlayer'
                              ? '2P'
                              : 'AI',
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
          border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _buildThemeCard(
                      context,
                      AppThemeType.system,
                      'System',
                      Colors.grey,
                      Icons.brightness_auto,
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.system,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      context,
                      AppThemeType.pureBlack,
                      'Pure Black',
                      Colors.black,
                      Icons.dark_mode,
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.pureBlack,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      context,
                      AppThemeType.pureWhite,
                      'Pure White',
                      Colors.white,
                      Icons.light_mode,
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.pureWhite,
                      isLight: true,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      context,
                      AppThemeType.glassGreen,
                      'Glass Green',
                      const Color(0xFF1C2A25),
                      Icons.blur_on,
                      accentColor: const Color(0xFF2ED573),
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.glassGreen,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      context,
                      AppThemeType.glassRed,
                      'Glass Red',
                      const Color(0xFF2A1C1C),
                      Icons.blur_on,
                      accentColor: const Color(0xFFFF5A5F),
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.glassRed,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeCard(
                      context,
                      AppThemeType.blackRed,
                      'Black Red',
                      Colors.black,
                      Icons.palette,
                      accentColor: const Color(0xFFFF5A5F),
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.blackRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    AppThemeType theme,
    String label,
    Color color,
    IconData icon, {
    bool isSelected = false,
    bool isLight = false,
    Color? accentColor,
  }) {
    final colors = AppTheme.getColors(context);

    return GestureDetector(
      onTap: () {
        Provider.of<GameProvider>(context, listen: false).setTheme(theme);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border:
                  isSelected
                      ? Border.all(color: colors.accent, width: 3)
                      : Border.all(
                        color: colors.primary.withOpacity(0.1),
                        width: 1,
                      ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: (accentColor ?? color).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: isLight ? Colors.black : Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: colors.primary,
            ),
          ),
        ],
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
                    _buildDifficultyChip(
                      context,
                      AIDifficulty.medium,
                      'Medium',
                    ),
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
          color:
              isSelected ? colors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? colors.primary : colors.primary.withOpacity(0.2),
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
            if (isSelected) Icon(Icons.check_circle, color: colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(
    BuildContext context,
    AIDifficulty difficulty,
    String label,
  ) {
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
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }
}
