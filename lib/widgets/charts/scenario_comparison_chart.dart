import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/feasibility_study.dart';

class ScenarioComparisonChart extends StatefulWidget {
  final FeasibilityStudy study;
  final String locale;

  const ScenarioComparisonChart({
    super.key,
    required this.study,
    required this.locale,
  });

  @override
  State<ScenarioComparisonChart> createState() => _ScenarioComparisonChartState();
}

class _ScenarioComparisonChartState extends State<ScenarioComparisonChart>
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
  void didUpdateWidget(covariant ScenarioComparisonChart oldWidget) {
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
    final isAr = widget.locale == 'ar';
    final scenarios = widget.study.getScenarios();
    final base = scenarios['Base']!;
    final bull = scenarios['Bull']!;
    final bear = scenarios['Bear']!;

    final bearRoi = bear.roiPct;
    final baseRoi = base.roiPct;
    final bullRoi = bull.roiPct;

    // Calculate safe, robust min & max Y bounds to prevent any overflow or inverted math
    final minRoi = math.min(0.0, math.min(bearRoi, math.min(baseRoi, bullRoi)));
    final maxRoi = math.max(0.0, math.max(bearRoi, math.max(baseRoi, bullRoi)));

    double minY = 0.0;
    if (minRoi < 0) {
      minY = (minRoi * 1.25 / 10.0).floor() * 10.0;
    }

    double maxY = 10.0;
    if (maxRoi > 0) {
      maxY = (maxRoi * 1.25 / 10.0).ceil() * 10.0;
    } else {
      maxY = 10.0; // Headroom above 0 when all ROIs are negative
    }

    if (maxY - minY < 20.0) {
      maxY = minY + 20.0;
    }

    final interval = ((maxY - minY) / 4).clamp(5.0, 50.0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;

        final bearToY = bearRoi * progress;
        final baseToY = baseRoi * progress;
        final bullToY = bullRoi * progress;

        final barGroups = [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                fromY: 0.0,
                toY: bearToY,
                color: AppColors.danger,
                width: 24,
                borderRadius: bearToY >= 0
                    ? const BorderRadius.vertical(top: Radius.circular(6))
                    : const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                fromY: 0.0,
                toY: baseToY,
                color: AppColors.primaryBlue,
                width: 24,
                borderRadius: baseToY >= 0
                    ? const BorderRadius.vertical(top: Radius.circular(6))
                    : const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                fromY: 0.0,
                toY: bullToY,
                color: AppColors.success,
                width: 24,
                borderRadius: bullToY >= 0
                    ? const BorderRadius.vertical(top: Radius.circular(6))
                    : const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
            ],
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRect(
              child: SizedBox(
                height: 175,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    minY: minY,
                    maxY: maxY,
                    baselineY: 0.0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) =>
                            isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final names = [
                            isAr ? 'متحفظ (-10%)' : 'Bear (-10%)',
                            isAr ? 'الأساسي' : 'Base Case',
                            isAr ? 'متفائل (+10%)' : 'Bull (+10%)',
                          ];
                          final val = rod.toY;
                          final prefix = val > 0 ? '+' : '';
                          return BarTooltipItem(
                            '${names[group.x.clamp(0, 2)]}\n',
                            const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text: '$prefix${val.toStringAsFixed(1)}% ROI',
                                style: TextStyle(
                                  color: rod.color ?? Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          interval: interval,
                          getTitlesWidget: (val, meta) {
                            if (val == meta.max || val == meta.min) {
                              return const SizedBox.shrink();
                            }
                            final prefix = val > 0 ? '+' : '';
                            return Text(
                              '$prefix${val.toInt()}%',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextFaint
                                    : AppColors.lightTextFaint,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx > 2) return const SizedBox.shrink();
                            final labels = [
                              isAr ? 'متحفظ' : 'Bear (-10%)',
                              isAr ? 'أساسي' : 'Base Case',
                              isAr ? 'متفائل' : 'Bull (+10%)',
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
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
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (value) {
                        if (value == 0) {
                          return FlLine(
                            color: isDark ? Colors.white38 : Colors.black38,
                            strokeWidth: 1.5,
                          );
                        }
                        return FlLine(
                          color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
                          strokeWidth: 0.8,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Scenario Summary KPI Cards Row
            Row(
              children: [
                _buildScenarioCard(
                  label: isAr ? 'متحفظ (-10%)' : 'Bear (-10%)',
                  roi: bearRoi,
                  color: AppColors.danger,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildScenarioCard(
                  label: isAr ? 'الأساسي' : 'Base Case',
                  roi: baseRoi,
                  color: AppColors.primaryBlue,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildScenarioCard(
                  label: isAr ? 'متفائل (+10%)' : 'Bull (+10%)',
                  roi: bullRoi,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildScenarioCard({
    required String label,
    required double roi,
    required Color color,
    required bool isDark,
  }) {
    final isPositive = roi > 0;
    final prefix = isPositive ? '+' : '';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$prefix${roi.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
