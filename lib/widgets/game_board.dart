import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import 'game_cell.dart';

class GameBoard extends StatelessWidget {
  final VoidCallback onWin;
  final VoidCallback onDraw;

  const GameBoard({
    Key? key,
    required this.onWin,
    required this.onDraw,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final colors = AppTheme.getColors(context);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final isWinningCell = gameProvider.winningLine.contains(index);
          return GameCell(
            value: gameProvider.board[index],
            isWinningCell: isWinningCell,
            onTap: () {
              gameProvider.makeMove(index, onWin, onDraw);
            },
          );
        },
      ),
    );
  }
}
