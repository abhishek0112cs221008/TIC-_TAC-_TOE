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
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
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
              _buildThemeCard(
                context,
                AppThemeType.pureBlack,
                'Pure Black',
                const Color(0xFF000000),
                const Color(0xFF00D856),
                Icons.dark_mode,
              ),
              const SizedBox(height: 15),
              _buildThemeCard(
                context,
                AppThemeType.pureWhite,
                'Pure White',
                const Color(0xFFFFFFFF),
                const Color(0xFFFF5A5F),
                Icons.light_mode,
              ),
              const SizedBox(height: 15),
              _buildThemeCard(
                context,
                AppThemeType.airbnbUpi,
                'Airbnb + UPI',
                const Color(0xFFFF5A5F),
                const Color(0xFF00D856),
                Icons.auto_awesome,
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
    AppThemeType type,
    String label,
    Color color1,
    Color color2,
    IconData icon,
  ) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isSelected = gameProvider.currentTheme == type;

    return GestureDetector(
      onTap: () {
        gameProvider.setTheme(type);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color1.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  void _showGameModeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GameModeDialog(),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
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
          border: Border.all(
            color: colors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const GameModeSelector(),
      ),
    );
  }
}
