import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  void _showThemeBottomSheet(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colors = AppTheme.getColors(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
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
              const SizedBox(height: 12),
              // Handle bar
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Choose Your Theme',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              // Theme options
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildThemeCard(
                          context,
                          AppThemeType.system,
                          'System',
                          const Color(0xFF4FC3F7),
                          const Color(0xFF81D4FA),
                          Icons.brightness_auto,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.midnight,
                          'Midnight',
                          const Color(0xFF4FC3F7),
                          const Color(0xFF81D4FA),
                          Icons.nightlight_round,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.emerald,
                          'Emerald',
                          const Color(0xFF00E676),
                          const Color(0xFF64FFDA),
                          Icons.eco,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.royal,
                          'Royal',
                          const Color(0xFF7C4DFF),
                          const Color(0xFFB388FF),
                          Icons.diamond,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.crimson,
                          'Crimson',
                          const Color(0xFFFF5252),
                          const Color(0xFFFF80AB),
                          Icons.favorite,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.arctic,
                          'Arctic',
                          const Color(0xFF00B8D4),
                          const Color(0xFF00E5FF),
                          Icons.ac_unit,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.golden,
                          'Golden',
                          const Color(0xFFFFD700),
                          const Color(0xFFFFE082),
                          Icons.wb_sunny,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.purple,
                          'Purple',
                          const Color(0xFFE040FB),
                          const Color(0xFFEA80FC),
                          Icons.auto_awesome,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.mint,
                          'Mint',
                          const Color(0xFF69F0AE),
                          const Color(0xFFB9F6CA),
                          Icons.spa,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.proWhite,
                          'Pro White',
                          const Color(0xFF2C3E50),
                          const Color(0xFF3498DB),
                          Icons.light_mode,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.proBlack,
                          'Pro Black',
                          const Color(0xFFECF0F1),
                          const Color(0xFF3498DB),
                          Icons.dark_mode,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.iosWhite,
                          'iOS White',
                          const Color(0xFF007AFF),
                          const Color(0xFFFF9500),
                          Icons.apple,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.iosBlack,
                          'iOS Black',
                          const Color(0xFF0A84FF),
                          const Color(0xFFFF9F0A),
                          Icons.phone_iphone,
                        ),
                        _buildThemeCard(
                          context,
                          AppThemeType.glassGreen,
                          'Glass Green',
                          const Color(0xFF2ED573),
                          const Color(0xFF0B1412),
                          Icons.blur_on,
                        ),
                      ],
                    ),
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
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);

    // Get current theme name
    String currentThemeName =
        gameProvider.currentTheme.toString().split('.').last;
    currentThemeName =
        currentThemeName[0].toUpperCase() +
        currentThemeName
            .substring(1)
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(0)}',
            )
            .trim();

    return GestureDetector(
      onTap: () => _showThemeBottomSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary.withOpacity(0.3),
              colors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.palette, color: colors.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              currentThemeName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: colors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
