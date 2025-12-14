import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const DesiTicTacToeApp());
}

class DesiTicTacToeApp extends StatelessWidget {
  const DesiTicTacToeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          // Determine theme mode based on selected theme
          ThemeMode themeMode;
          if (gameProvider.currentTheme == AppThemeType.system) {
            themeMode = ThemeMode.system; // Follow device theme
          } else if (gameProvider.currentTheme == AppThemeType.pureWhite) {
            themeMode = ThemeMode.light;
          } else {
            themeMode = ThemeMode.dark;
          }

          return MaterialApp(
            title: 'Tic-Tac-Toe',
            theme: AppTheme.getTheme(gameProvider.currentTheme, Brightness.light),
            darkTheme: AppTheme.getTheme(gameProvider.currentTheme, Brightness.dark),
            themeMode: themeMode,
            home: const GameScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
