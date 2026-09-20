import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/feasibility_study.dart';

class CostBreakdownPie extends StatefulWidget {
  final FeasibilityStudy study;
  final String locale;

  const CostBreakdownPie({
    super.key,
    required this.study,
    required this.locale,
  });

  @override
  State<CostBreakdownPie> createState() => _CostBreakdownPieState();
}

class _CostBreakdownPieState extends State<CostBreakdownPie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CostBreakdownPie oldWidget) {
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
    final total = widget.study.totalDevelopmentCost;

    if (total <= 0) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('No cost data')),
      );
    }

    final landPct = (widget.study.landCost / total) * 100.0;
    final constPct = (widget.study.hardConstructionCost / total) * 100.0;
    final softPct = (widget.study.softCosts / total) * 100.0;
    final contPct = (widget.study.contingencyCost / total) * 100.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;

        final sections = [
          PieChartSectionData(
            value: widget.study.landCost * progress + 0.01,
            color: AppColors.gold,
            title: '${landPct.toStringAsFixed(0)}%',
            radius: _touchedIndex == 0 ? 48 : 42,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          PieChartSectionData(
            value: widget.study.hardConstructionCost * progress + 0.01,
            color: AppColors.primaryBlue,
            title: '${constPct.toStringAsFixed(0)}%',
            radius: _touchedIndex == 1 ? 52 : 46,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: widget.study.softCosts * progress + 0.01,
            color: AppColors.purple,
            title: '${softPct.toStringAsFixed(0)}%',
            radius: _touchedIndex == 2 ? 44 : 38,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: widget.study.contingencyCost * progress + 0.01,
            color: AppColors.teal,
            title: '${contPct.toStringAsFixed(0)}%',
            radius: _touchedIndex == 3 ? 40 : 34,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ];

        return Column(
          children: [
            SizedBox(
              height: 180,
              child: Transform.scale(
                scale: 0.85 + (0.15 * progress),
                child: Transform.rotate(
                  angle: (1.0 - progress) * -0.5,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: sections,
                      centerSpaceRadius: 36,
                      sectionsSpace: 3,
                      startDegreeOffset: 180 * (1 - progress),
                    ),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _legendItem(
                  color: AppColors.gold,
                  label: widget.locale == 'ar' ? 'الأرض' : 'Land Acquisition',
                  isDark: isDark,
                  isSelected: _touchedIndex == 0,
                ),
                _legendItem(
                  color: AppColors.primaryBlue,
                  label: widget.locale == 'ar' ? 'البناء المباشر' : 'Hard Construction',
                  isDark: isDark,
                  isSelected: _touchedIndex == 1,
                ),
                _legendItem(
                  color: AppColors.purple,
                  label: widget.locale == 'ar' ? 'المصاريف الهندسية' : 'Soft Costs',
                  isDark: isDark,
                  isSelected: _touchedIndex == 2,
                ),
                _legendItem(
                  color: AppColors.teal,
                  label: widget.locale == 'ar' ? 'احتياطي الطوارئ' : 'Contingency',
                  isDark: isDark,
                  isSelected: _touchedIndex == 3,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required bool isDark,
    bool isSelected = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
