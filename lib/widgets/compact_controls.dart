import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/game_mode_selector.dart';
import '../widgets/settings_dialog.dart';

class CompactControls extends StatelessWidget {
  const CompactControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            context,
            Icons.palette_outlined,
            'Theme',
            colors.primary,
            () => _showThemeSelector(context),
          ),
          _buildIconButton(
            context,
            Icons.sports_esports_outlined,
            'Mode',
            colors.secondary,
            () => _showGameModeSelector(context),
          ),
          _buildIconButton(
            context,
            Icons.settings_outlined,
            'Settings',
            colors.accent,
            () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
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
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.surface.withOpacity(0.95),
                colors.surface.withOpacity(0.98),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border.all(
              color: colors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 30),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _buildThemeCard(
                      context,
                      AppThemeType.pureBlack,
                      'Pure Black',
                      Colors.black,
                      Icons.dark_mode,
                      isSelected:
                          gameProvider.currentTheme == AppThemeType.pureBlack,
                    ),
                    const SizedBox(width: 15),
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
                    const SizedBox(width: 15),
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
                    const SizedBox(width: 15),
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
                    const SizedBox(width: 15),
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
    showDialog(context: context, builder: (context) => const GameModeDialog());
  }

  void _showSettings(BuildContext context) {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }
}

class GameModeDialog extends StatelessWidget {
  const GameModeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colors = AppTheme.getColors(context);

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
          border: Border.all(color: colors.primary.withOpacity(0.3), width: 2),
        ),
        child: const GameModeSelector(),
      ),
    );
  }
}
