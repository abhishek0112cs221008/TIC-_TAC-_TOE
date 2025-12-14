import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
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
    final boardSize = ResponsiveHelper.getGameBoardSize(context);
    final padding = ResponsiveHelper.getSpacing(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final spacing = ResponsiveHelper.getSpacing(
      context,
      mobile: 10.0,
      tablet: 12.0,
      desktop: 14.0,
    );

    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        margin: EdgeInsets.all(padding),
        padding: EdgeInsets.all(padding),
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
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
      ),
    );
  }
}
