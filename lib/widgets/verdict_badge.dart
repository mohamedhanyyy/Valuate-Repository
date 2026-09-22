import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../models/feasibility_study.dart';

class VerdictBadge extends StatelessWidget {
  final VerdictType verdict;
  final int score;
  final String locale;
  final bool isExpanded;
  final bool isPending;

  const VerdictBadge({
    super.key,
    required this.verdict,
    required this.score,
    required this.locale,
    this.isExpanded = false,
    this.isPending = false,
  });

  Color _getColor(bool isDark) {
    if (isPending) return const Color(0xFF2563EB);
    switch (verdict) {
      case VerdictType.go:
        return isDark ? AppColors.success : AppColors.successLight;
      case VerdictType.caution:
        return isDark ? const Color(0xFFFBBF24) : AppColors.warning;
      case VerdictType.noGo:
        return isDark ? AppColors.danger : AppColors.dangerLight;
    }
  }

  String get _title {
    if (isPending) {
      return locale == 'ar' ? 'قيد التقييم' : 'Pending Evaluation';
    }
    switch (verdict) {
      case VerdictType.go:
        return AppStrings.get('goDecision', locale: locale);
      case VerdictType.caution:
        return AppStrings.get('cautionDecision', locale: locale);
      case VerdictType.noGo:
        return AppStrings.get('noGoDecision', locale: locale);
    }
  }

  IconData get _icon {
    if (isPending) return Icons.hourglass_empty_rounded;
    switch (verdict) {
      case VerdictType.go:
        return Icons.check_circle_rounded;
      case VerdictType.caution:
        return Icons.warning_amber_rounded;
      case VerdictType.noGo:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(isDark);

    if (!isExpanded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              _title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        children: [
          // Circular Score Meter
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: isPending ? 0.0 : score / 100.0,
                  strokeWidth: 4.5,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  isPending ? '--' : '$score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Decision & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPending
                      ? (locale == 'ar'
                          ? 'بانتظار اكتمال التحليلات المالية واستلام قرار الجدوى من الخادم (Backend).'
                          : 'Awaiting financial feasibility calculations and verdict from backend.')
                      : verdict == VerdictType.go
                          ? (locale == 'ar'
                              ? 'المشروع يحقق معدل عائد وهوامش ربحية استثمارية ممتازة تفوق المعايير الإقليمية.'
                              : 'High feasibility. Returns and margins exceed regional hurdle rates.')
                          : verdict == VerdictType.caution
                              ? (locale == 'ar'
                                  ? 'عائد متوسط. يتطلب مراجعة تكلفة الأرض أو تعظيم المسطحات التأجيرية.'
                                  : 'Moderate feasibility. Optimize land cost or GFA efficiency to improve IRR.')
                              : (locale == 'ar'
                                  ? 'مشروع عالي المخاطر أو ذو هامش منخفض جداً. يوصى بإعادة دراسة التكاليف.'
                                  : 'High financial risk. Development costs outweigh projected revenue.'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
