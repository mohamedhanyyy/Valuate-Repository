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
    final scenarios = widget.study.getScenarios();
    final base = scenarios['Base']!;
    final bull = scenarios['Bull']!;
    final bear = scenarios['Bear']!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;

        final barGroups = [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: bear.roiPct * progress,
                color: AppColors.danger,
                width: 20,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: base.roiPct * progress,
                color: AppColors.primaryBlue,
                width: 20,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: bull.roiPct * progress,
                color: AppColors.success,
                width: 20,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ];

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: ((bull.roiPct * 1.25) / 10).ceil() * 10.0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final names = [
                          widget.locale == 'ar' ? 'متحفظ' : 'Bear Case',
                          widget.locale == 'ar' ? 'أساسي' : 'Base Case',
                          widget.locale == 'ar' ? 'متفائل' : 'Bull Case'
                        ];
                        return BarTooltipItem(
                          '${names[group.x]}: ${rod.toY.toStringAsFixed(1)}% ROI',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (val, meta) => Text(
                          '${val.toInt()}%',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                          ),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            widget.locale == 'ar' ? 'متحفظ' : 'Bear (-10%)',
                            widget.locale == 'ar' ? 'أساسي' : 'Base Case',
                            widget.locale == 'ar' ? 'متفائل' : 'Bull (+10%)',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
          ],
        );
      },
    );
  }
}
