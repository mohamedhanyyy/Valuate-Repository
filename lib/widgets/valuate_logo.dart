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
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
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
        // Wordmark
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'VALU',
                style: GoogleFonts.cairo(
                  color: color,
                  fontSize: height * 0.65,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              TextSpan(
                text: 'ATE',
                style: GoogleFonts.cairo(
                  color: AppColors.gold,
                  fontSize: height * 0.65,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
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

    final dotPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.12,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
