import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/projects/projects_state.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/kpi_metric_tile.dart';
import '../../widgets/verdict_badge.dart';
import 'project_detail_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const ProjectsListScreen({super.key, this.onNavigateTab});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  final _searchController = TextEditingController();

  final List<String> _filters = const [
    'All',
    'Residential',
    'Commercial',
    'MixedUse',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          AppStrings.get('navProjects', locale: locale),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: AppColors.gold),
            tooltip: AppStrings.get('newStudy', locale: locale),
            onPressed: () {
              context.read<CalculatorCubit>().resetToDefaults();
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(1); // Go to calculator tab
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          if (state is ProjectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectsLoaded) {
            final studies = state.filteredStudies;

            return Column(
              children: [
                // Search & Filter Bar
                FadeSlideEntrance(
                  duration: const Duration(milliseconds: 450),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<ProjectsCubit>().searchProjects(val);
                          },
                          style: TextStyle(
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: locale == 'ar'
                                ? 'بحث عن مشروع أو موقع...'
                                : 'Search study or location...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<ProjectsCubit>().searchProjects('');
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.map((f) {
                              final isSelected = state.selectedFilter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    f == 'All'
                                        ? (locale == 'ar' ? 'الكل' : 'All')
                                        : AppStrings.get(f.toLowerCase(), locale: locale),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    ),
                                  ),
                                  onSelected: (_) {
                                    context.read<ProjectsCubit>().filterByAssetType(f);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Studies List
                Expanded(
                  child: studies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 48,
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                locale == 'ar'
                                    ? 'لا توجد دراسات جدوى مطابقة'
                                    : 'No feasibility studies found',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          itemCount: studies.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final study = studies[index];
                            return FadeSlideEntrance(
                              delay: Duration(milliseconds: 100 + (index * 60)),
                              duration: const Duration(milliseconds: 480),
                              child: _buildProjectItem(context, study, isDark, locale),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context,
    FeasibilityStudy study,
    bool isDark,
    String locale,
  ) {
    return Dismissible(
      key: Key(study.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<ProjectsCubit>().deleteStudy(study.id);
      },
      child: InkWell(
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${study.assetType} • ${study.location}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                          ),
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
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      locale == 'ar' ? 'التكلفة\n(TDC)' : 'Cost\n(TDC)',
                      KpiMetricTile.formatCurrency(study.totalDevelopmentCost, currency: study.currency),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      locale == 'ar' ? 'الإيرادات\nالمتوقعة' : 'Gross\nRevenue',
                      KpiMetricTile.formatCurrency(study.grossRevenue, currency: study.currency),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      locale == 'ar' ? 'العائد\n(ROI)' : 'Return\n(ROI)',
                      '${study.roiPct.toStringAsFixed(1)}%',
                      isDark,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      locale == 'ar' ? 'الداخلي\n(IRR)' : 'IRR\n(Rate)',
                      '${study.annualizedIrrPct.toStringAsFixed(1)}%',
                      isDark,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value, bool isDark, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color ?? (isDark ? AppColors.darkText : AppColors.lightText),
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
