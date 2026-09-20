import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/projects/projects_state.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/kpi_metric_tile.dart';

class ConsolidationsScreen extends StatelessWidget {
  const ConsolidationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        title: Text(
          locale == 'ar' ? 'التجميع والدمج المالي' : 'Portfolio Consolidations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          if (state is ProjectsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overview Box
                  FadeSlideEntrance(
                    duration: const Duration(milliseconds: 480),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkBrandBg1, AppColors.darkBrandBg2]
                              : [AppColors.lightBrandBg1, AppColors.lightBrandBg2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale == 'ar' ? 'تجميع المحفظة الشامل' : 'Consolidated Portfolio Group',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            locale == 'ar'
                                ? 'إجمالي المحفظة الاستثمارية النشطة (${state.studies.length} مشاريع)'
                                : 'Active Capital Deployment (${state.studies.length} Projects)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _miniMetric(
                                  label: locale == 'ar' ? 'إجمالي التكاليف' : 'Total Capex',
                                  value: KpiMetricTile.formatCurrency(state.totalInvestmentCost),
                                  isDark: isDark,
                                ),
                              ),
                              Expanded(
                                child: _miniMetric(
                                  label: locale == 'ar' ? 'إجمالي الإيرادات' : 'Total Revenue',
                                  value: KpiMetricTile.formatCurrency(state.totalPipelineValue),
                                  isDark: isDark,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 140),
                    duration: const Duration(milliseconds: 450),
                    child: Text(
                      locale == 'ar' ? 'المشاريع المدمجة في المحفظة' : 'Consolidated Assets & Projects',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.studies.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = state.studies[index];
                      return FadeSlideEntrance(
                        delay: Duration(milliseconds: 200 + (index * 60)),
                        duration: const Duration(milliseconds: 480),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkText : AppColors.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${s.assetType} • ${s.location}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                KpiMetricTile.formatCurrency(s.grossRevenue, currency: s.currency),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _miniMetric({
    required String label,
    required String value,
    required bool isDark,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color ?? (isDark ? AppColors.darkText : AppColors.lightText),
          ),
        ),
      ],
    );
  }
}
