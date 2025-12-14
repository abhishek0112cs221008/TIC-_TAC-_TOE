import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import 'privacy_policy_dialog.dart';
import 'about_dialog.dart' as about;

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.getDialogWidth(context),
          maxHeight: ResponsiveHelper.getDialogMaxHeight(context),
        ),
        child: Container(
          padding: ResponsiveHelper.getResponsivePadding(context),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 24.0,
                        tablet: 26.0,
                        desktop: 28.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSettingTile(
                context,
                'Sound Effects',
                'Play sounds during gameplay',
                Icons.volume_up,
                gameProvider.isSoundOn,
                (value) => gameProvider.toggleSound(),
                colors,
              ),
              const SizedBox(height: 15),
              _buildSettingTile(
                context,
                'Haptic Feedback',
                'Vibrate on moves',
                Icons.vibration,
                gameProvider.hapticFeedback,
                (value) => gameProvider.toggleHaptic(),
                colors,
              ),
              const SizedBox(height: 15),
              _buildNavigationTile(
                context,
                'Privacy Policy',
                'View our privacy policy',
                Icons.mail,
                colors,
                () {
                  showDialog(
                    context: context,
                    builder: (context) => const PrivacyPolicyDialog(),
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildNavigationTile(
                context,
                'About',
                'App information',
                Icons.info,
                colors,
                () {
                  showDialog(
                    context: context,
                    builder: (context) => const about.AboutDialog(),
                  );
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  await gameProvider.resetStats();
                  if (context.mounted) {
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
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    ThemeColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 28,
          ),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeColors colors,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: colors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: 24,
            ),
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.primary.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
