import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class ValuateLogo extends StatelessWidget {
  final double height;
  final bool isDark;

  const ValuateLogo({
    super.key,
    this.height = 36,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoAsset = isDark
        ? 'assets/images/valuate_logo_dark.png'
        : 'assets/images/valuate_logo.png';

    return Image.asset(
      logoAsset,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final color = isDark ? Colors.white : AppColors.brandNavy;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand App Icon
            Container(
              width: height * 0.9,
              height: height * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height * 0.22),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.brandNavy,
                    child: Center(
                      child: CustomPaint(
                        size: Size(height * 0.5, height * 0.5),
                        painter: _ValuateMarkPainter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Unified Wordmark (no yellow)
            Text(
              'Valuate',
              style: GoogleFonts.cairo(
                color: color,
                fontSize: height * 0.65,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ValuateMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.15);
    path.lineTo(size.width * 0.5, size.height * 0.85);
    path.lineTo(size.width * 0.9, size.height * 0.15);
    path.lineTo(size.width * 0.72, size.height * 0.15);
    path.lineTo(size.width * 0.5, size.height * 0.58);
    path.lineTo(size.width * 0.28, size.height * 0.15);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
