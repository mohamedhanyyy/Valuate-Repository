import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SkylineWidget extends StatefulWidget {
  final double height;
  final bool isDark;

  const SkylineWidget({
    super.key,
    this.height = 90,
    this.isDark = true,
  });

  @override
  State<SkylineWidget> createState() => _SkylineWidgetState();
}

class _SkylineWidgetState extends State<SkylineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: CustomPaint(
            painter: _SkylinePainter(
              pulseValue: _pulseController.value,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    );
  }
}

class _SkylinePainter extends CustomPainter {
  final double pulseValue;
  final bool isDark;

  _SkylinePainter({
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 480.0;
    final scaleY = size.height / 120.0;

    // 1. Draw Skyline Silhouette Polygon Fill
    final fillPaint = Paint()
      ..color = isDark
          ? AppColors.darkBorder.withValues(alpha: 0.35)
          : AppColors.lightBorder.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    const points = [
      Offset(0, 120), Offset(0, 72), Offset(20, 72), Offset(20, 60),
      Offset(40, 60), Offset(40, 84), Offset(60, 84), Offset(60, 40),
      Offset(80, 40), Offset(80, 90), Offset(100, 90), Offset(100, 55),
      Offset(118, 55), Offset(118, 100), Offset(140, 100), Offset(140, 30),
      Offset(160, 30), Offset(160, 95), Offset(182, 95), Offset(182, 66),
      Offset(200, 66), Offset(200, 110), Offset(222, 110), Offset(222, 48),
      Offset(244, 48), Offset(244, 80), Offset(266, 80), Offset(266, 20),
      Offset(286, 20), Offset(286, 105), Offset(308, 105), Offset(308, 62),
      Offset(330, 62), Offset(330, 90), Offset(350, 90), Offset(350, 44),
      Offset(372, 44), Offset(372, 100), Offset(394, 100), Offset(394, 70),
      Offset(414, 70), Offset(414, 88), Offset(434, 88), Offset(434, 55),
      Offset(456, 55), Offset(456, 112), Offset(480, 112), Offset(480, 120)
    ];

    final fillPath = Path();
    fillPath.moveTo(points[0].dx * scaleX, points[0].dy * scaleY);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx * scaleX, points[i].dy * scaleY);
    }
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw Polyline Trajectory
    final linePaint = Paint()
      ..color = isDark ? AppColors.darkAccent : AppColors.lightAccent
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const linePoints = [
      Offset(0, 88), Offset(24, 70), Offset(48, 78), Offset(72, 52),
      Offset(96, 64), Offset(120, 34), Offset(144, 58), Offset(168, 26),
      Offset(192, 48), Offset(216, 20), Offset(240, 44), Offset(264, 16),
      Offset(288, 40), Offset(312, 58), Offset(336, 30), Offset(360, 50),
      Offset(384, 22), Offset(408, 46), Offset(432, 18), Offset(456, 38),
      Offset(480, 24),
    ];

    final linePath = Path();
    linePath.moveTo(linePoints[0].dx * scaleX, linePoints[0].dy * scaleY);
    for (int i = 1; i < linePoints.length; i++) {
      linePath.lineTo(linePoints[i].dx * scaleX, linePoints[i].dy * scaleY);
    }
    canvas.drawPath(linePath, linePaint);

    // 3. Draw Nodes (Dots)
    final dotPaint = Paint()
      ..color = isDark ? AppColors.darkAccentStrong : AppColors.lightAccentStrong
      ..style = PaintingStyle.fill;

    const keyNodes = [
      Offset(0, 88),
      Offset(144, 58),
      Offset(288, 40),
      Offset(432, 18),
      Offset(480, 24),
    ];

    for (final node in keyNodes) {
      canvas.drawCircle(
        Offset(node.dx * scaleX, node.dy * scaleY),
        3.5,
        dotPaint,
      );
    }

    // 4. Draw Animated Pulse at (480, 24)
    final pulseOffset = Offset(480 * scaleX, 24 * scaleY);
    final pulsePaint = Paint()
      ..color = (isDark ? AppColors.darkAccentStrong : AppColors.primaryBlue)
          .withValues(alpha: (1.0 - pulseValue).clamp(0.0, 1.0))
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      pulseOffset,
      3.5 + (pulseValue * 12.0),
      pulsePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.isDark != isDark;
  }
}
