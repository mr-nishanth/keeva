import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Pure vector presentation of the Keeva logo mark.
///
/// Accurately renders the Inward Aperture ribbon with Aurora gradient,
/// secondary accent arc, and luminous preserved spark glow.
class KeevaLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const KeevaLogo({super.key, this.size = 72.0, this.showGlow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.darkPrimary.withValues(alpha: 0.18),
                  blurRadius: size * 0.44,
                  spreadRadius: size * 0.06,
                ),
              ]
            : null,
      ),
      child: CustomPaint(size: Size(size, size), painter: _KeevaLogoPainter()),
    );
  }
}

class _KeevaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 432.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Inner Visual Plate (220x220, rx=56) centered at (106, 106)
    final plateRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(106, 106, 220, 220),
      const Radius.circular(56),
    );

    final platePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF222834), Color(0xFF141820)],
      ).createShader(const Rect.fromLTWH(106, 106, 220, 220));
    canvas.drawRRect(plateRect, platePaint);

    final plateBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x47FFFFFF), Color(0x10FFFFFF)],
      ).createShader(const Rect.fromLTWH(106, 106, 220, 220));
    canvas.drawRRect(plateRect, plateBorderPaint);

    // 2. Inward Aperture Ribbon (Aurora Gradient)
    final ribbonPath = Path()
      ..moveTo(184, 280)
      ..lineTo(184, 212)
      ..cubicTo(184, 184, 202, 168, 228, 168)
      ..lineTo(254, 168)
      ..cubicTo(274, 168, 286, 180, 286, 200)
      ..cubicTo(286, 222, 266, 238, 242, 238)
      ..lineTo(222, 238)
      ..cubicTo(208, 238, 200, 246, 200, 260)
      ..lineTo(200, 280);

    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF6366F1)],
        stops: [0.0, 0.45, 1.0],
      ).createShader(const Rect.fromLTWH(184, 168, 102, 112));
    canvas.drawPath(ribbonPath, ribbonPaint);

    // 3. Secondary Accent Arc
    final arcPath = Path()
      ..moveTo(220, 292)
      ..lineTo(262, 292)
      ..cubicTo(282, 292, 294, 280, 294, 260)
      ..lineTo(294, 238);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x736366F1);
    canvas.drawPath(arcPath, arcPaint);

    // 4. Spark Ambient Glow
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFA7F3D0),
              const Color(0x8010B981),
              const Color(0x0010B981),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(center: const Offset(242, 204), radius: 22),
          );
    canvas.drawCircle(const Offset(242, 204), 22, glowPaint);

    // 5. Spark Core Gleam
    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(242, 204), 8, corePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
