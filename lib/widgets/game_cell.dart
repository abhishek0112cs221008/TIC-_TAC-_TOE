import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class GameCell extends StatefulWidget {
  final String value;
  final VoidCallback onTap;
  final bool isWinningCell;

  const GameCell({
    Key? key,
    required this.value,
    required this.onTap,
    this.isWinningCell = false,
  }) : super(key: key);

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant GameCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == '' && widget.value != '') {
      _controller.forward();
    } else if (widget.value == '') {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: widget.isWinningCell
                ? LinearGradient(
                    colors: [
                      colors.accent.withOpacity(0.3),
                      colors.accent.withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      colors.surface.withOpacity(0.4),
                      colors.surface.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isWinningCell
                  ? colors.accent.withOpacity(0.8)
                  : (_isHovered && widget.value == '')
                      ? colors.primary.withOpacity(0.5)
                      : colors.primary.withOpacity(0.2),
              width: widget.isWinningCell ? 2 : 1.5,
            ),
            boxShadow: [
              if (widget.isWinningCell || _isHovered)
                BoxShadow(
                  color: widget.isWinningCell
                      ? colors.accent.withOpacity(0.4)
                      : colors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * math.pi * 2,
                    child: CustomPaint(
                      size: const Size(50, 50),
                      painter: widget.value == 'X'
                          ? XPainter(
                              color: colors.xColor,
                              glowIntensity: widget.isWinningCell ? 1.0 : 0.5,
                            )
                          : widget.value == 'O'
                              ? OPainter(
                                  color: colors.oColor,
                                  glowIntensity: widget.isWinningCell ? 1.0 : 0.5,
                                )
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class XPainter extends CustomPainter {
  final Color color;
  final double glowIntensity;

  XPainter({required this.color, this.glowIntensity = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 * glowIntensity)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.moveTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.8);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(XPainter oldDelegate) => false;
}

class OPainter extends CustomPainter {
  final Color color;
  final double glowIntensity;

  OPainter({required this.color, this.glowIntensity = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 * glowIntensity)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(OPainter oldDelegate) => false;
}
