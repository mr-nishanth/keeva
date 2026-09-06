import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Pure vector presentation of the canonical Keeva logo mark.
///
/// Accurately renders the Inward Aperture ribbon with Aurora gradient,
/// secondary accent arc, luminous preserved spark glow, and subtle
/// Obsidian plate container.
class KeevaLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool showPlate;

  const KeevaLogo({
    super.key,
    this.size = 72.0,
    this.showGlow = true,
    this.showPlate = true,
  });

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
                  color: AppColors.darkPrimary.withValues(alpha: 0.28),
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.08,
                ),
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.16),
                  blurRadius: size * 0.6,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _KeevaLogoPainter(showPlate: showPlate),
      ),
    );
  }
}

class _KeevaLogoPainter extends CustomPainter {
  final bool showPlate;

  const _KeevaLogoPainter({this.showPlate = true});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Base Squircle Plate Container (if enabled)
    if (showPlate) {
      final plateRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 32, 448, 448),
        const Radius.circular(112),
      );

      final platePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF181D26), Color(0xFF0E1117)],
        ).createShader(const Rect.fromLTWH(32, 32, 448, 448));
      canvas.drawRRect(plateRect, platePaint);

      final plateBorderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x38FFFFFF), Color(0x0AFFFFFF)],
        ).createShader(const Rect.fromLTWH(32, 32, 448, 448));
      canvas.drawRRect(plateRect, plateBorderPaint);
    }

    // 2. The Luminous Preserved Spark (Ambient Glow)
    final sparkCenter = const Offset(280, 200);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFA7F3D0), Color(0xCC10B981), Color(0x0010B981)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: sparkCenter, radius: 44));
    canvas.drawCircle(sparkCenter, 44, glowPaint);

    // 3. Core Gleaming Spark Beacon
    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(sparkCenter, 16, corePaint);

    // 4. Secondary Memory Envelope Arc (Aurora Indigo)
    final arcPath = Path()
      ..moveTo(232, 384)
      ..lineTo(320, 384)
      ..cubicTo(360, 384, 384, 360, 384, 320)
      ..lineTo(384, 272);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xB36366F1);
    canvas.drawPath(arcPath, arcPaint);

    // 5. Inward Aperture Ribbon (Aurora Mint to Indigo Gradient)
    final ribbonPath = Path()
      ..moveTo(160, 360)
      ..lineTo(160, 216)
      ..cubicTo(160, 160, 196, 128, 248, 128)
      ..lineTo(304, 128)
      ..cubicTo(344, 128, 368, 152, 368, 192)
      ..cubicTo(368, 240, 328, 272, 280, 272)
      ..lineTo(240, 272)
      ..cubicTo(208, 272, 192, 288, 192, 320)
      ..lineTo(192, 360);

    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF6366F1)],
        stops: [0.0, 0.45, 1.0],
      ).createShader(const Rect.fromLTWH(160, 128, 208, 232));
    canvas.drawPath(ribbonPath, ribbonPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KeevaLogoPainter oldDelegate) =>
      oldDelegate.showPlate != showPlate;
}
