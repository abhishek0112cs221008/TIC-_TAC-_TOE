import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.privacy_tip, color: colors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 20.0,
                          tablet: 22.0,
                          desktop: 24.0,
                        ),
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Data Collection',
                      'Tic Tac Toe PRO does not collect, store, or share any personal information. All game data is stored locally on your device.',
                      colors,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Local Storage',
                      'We use local storage to save your game statistics and preferences. This data never leaves your device.',
                      colors,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Third-Party Services',
                      'This app does not use any third-party analytics, advertising, or tracking services.',
                      colors,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Contact',
                      'For any privacy concerns, please contact us at work8abhishek@gmail.com',
                      colors,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSection(String title, String content, ThemeColors colors) {
    return Column(
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
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
