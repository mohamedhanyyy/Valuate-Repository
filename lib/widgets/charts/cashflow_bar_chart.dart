import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/feasibility_study.dart';

class CashflowBarChart extends StatefulWidget {
  final FeasibilityStudy study;
  final String locale;

  const CashflowBarChart({
    super.key,
    required this.study,
    required this.locale,
  });

  @override
  State<CashflowBarChart> createState() => _CashflowBarChartState();
}

class _CashflowBarChartState extends State<CashflowBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CashflowBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.study != widget.study) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cashflows = widget.study.getMonthlyCashflows();

    // Group into 6 phases for clean mobile bar chart display
    final int step = (cashflows.length / 6).ceil();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final List<BarChartGroupData> barGroups = [];

        for (int i = 0; i < 6 && (i * step) < cashflows.length; i++) {
          final sub = cashflows.sublist(
            i * step,
            ((i + 1) * step).clamp(0, cashflows.length),
          );
          final avgOutflow = (sub.fold(0.0, (acc, c) => acc + c.outflow) / (1000000)) * progress;
          final avgInflow = (sub.fold(0.0, (acc, c) => acc + c.inflow) / (1000000)) * progress;

          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: avgOutflow,
                  color: AppColors.danger,
                  width: 9,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: avgInflow,
                  color: AppColors.success,
                  width: 9,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: null,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final type = rodIndex == 0
                            ? (widget.locale == 'ar' ? 'مصروفات' : 'Outflow')
                            : (widget.locale == 'ar' ? 'إيرادات' : 'Inflow');
                        return BarTooltipItem(
                          'P${group.x + 1} $type\n${rod.toY.toStringAsFixed(2)}M',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final phase = value.toInt() + 1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'P$phase',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(AppColors.danger, widget.locale == 'ar' ? 'التدفقات الخارجة (M)' : 'Outflows (M)', isDark),
                const SizedBox(width: 16),
                _legend(AppColors.success, widget.locale == 'ar' ? 'الإيرادات المحصلة (M)' : 'Inflows (M)', isDark),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _legend(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
