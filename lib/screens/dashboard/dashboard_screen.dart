import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/projects/projects_state.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/kpi_metric_tile.dart';
import '../../widgets/skyline_widget.dart';
import '../../widgets/theme_lang_bar.dart';
import '../../widgets/valuate_logo.dart';
import '../../widgets/verdict_badge.dart';
import '../projects/project_detail_screen.dart';
import '../workspace/create_project_wizard_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const DashboardScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.firstName : 'mohamed';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: ValuateLogo(height: 30, isDark: isDark),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: ThemeLangBar(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProjectsCubit>().loadProjects();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Greeting & Welcome Banner
              FadeSlideEntrance(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locale == 'ar' ? 'مرحباً، $userName' : 'Welcome back, $userName',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.get('brandSubtitle', locale: locale),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_graph_rounded,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SkylineWidget(height: 55, isDark: isDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Portfolio KPI Metrics Strip
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoaded) {
                    return FadeSlideEntrance(
                      delay: const Duration(milliseconds: 120),
                      duration: const Duration(milliseconds: 550),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('portfolioOverview', locale: locale),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: KpiMetricTile(
                                  label: AppStrings.get('totalPipelineValue', locale: locale),
                                  value: KpiMetricTile.formatCurrency(state.totalPipelineValue),
                                  icon: Icons.pie_chart_outline_rounded,
                                  accentColor: AppColors.primaryBlue,
                                  isHighlight: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KpiMetricTile(
                                  label: AppStrings.get('averageRoi', locale: locale),
                                  value: '--',
                                  icon: Icons.trending_up_rounded,
                                  accentColor: AppColors.success,
                                  subtext: locale == 'ar' ? 'بانتظار التقييم' : 'Pending Evaluation',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 22),

              // New Feasibility Project Launcher Card
              FadeSlideEntrance(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 550),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandBlue, Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandBlue.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_business_rounded,
                          color: AppColors.gold,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale == 'ar' ? 'إنشاء دراسة جدوى جديدة' : 'New Feasibility Project',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locale == 'ar'
                                  ? 'معالج ذكي لتحديد المنتجات والتكاليف والمراحل'
                                  : 'Guided wizard for products, phasing & DCF',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateProjectWizardScreen(),
                            ),
                          );
                        },
                        child: Text(
                          locale == 'ar' ? 'ابدأ الآن' : 'Create',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Feasibility Studies Section
              FadeSlideEntrance(
                delay: const Duration(milliseconds: 280),
                duration: const Duration(milliseconds: 550),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('recentStudies', locale: locale),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else if (onTabChange != null) {
                          onTabChange!(1);
                        }
                      },
                      child: Text(
                        AppStrings.get('viewAll', locale: locale),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Studies List
              BlocBuilder<ProjectsCubit, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectsLoaded) {
                    final studies = state.studies.take(3).toList();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studies.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final study = studies[index];
                        return FadeSlideEntrance(
                          delay: Duration(milliseconds: 320 + (index * 80)),
                          duration: const Duration(milliseconds: 500),
                          child: _buildStudyCard(context, study, isDark, locale),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudyCard(
    BuildContext context,
    FeasibilityStudy study,
    bool isDark,
    String locale,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(study: study),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        study.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            study.location,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                VerdictBadge(
                  verdict: study.verdict,
                  score: study.feasibilityScore,
                  locale: locale,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgGrid : AppColors.lightBgGrid.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _metricItem(
                      label: locale == 'ar' ? 'العائد\n(ROI)' : 'Return\n(ROI)',
                      value: '${study.roiPct.toStringAsFixed(1)}%',
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  _divider(isDark),
                  Expanded(
                    child: _metricItem(
                      label: locale == 'ar' ? 'العائد الداخلي\n(IRR)' : 'Internal Return\n(IRR)',
                      value: '${study.annualizedIrrPct.toStringAsFixed(1)}%',
                      color: AppColors.primaryBlue,
                      isDark: isDark,
                    ),
                  ),
                  _divider(isDark),
                  Expanded(
                    child: _metricItem(
                      label: locale == 'ar' ? 'صافي الربح\nالمتوقع' : 'Projected\nNet Profit',
                      value: KpiMetricTile.formatCurrency(study.netProfit, currency: study.currency),
                      color: AppColors.gold,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricItem({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 38,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
