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
import '../workspace/create_project_wizard_screen.dart';
import 'project_detail_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const ProjectsListScreen({super.key, this.onNavigateTab});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsCubit>().filterByAssetType('All');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateProjectWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateProjectWizardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';

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
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.gold, size: 22),
            tooltip: isAr ? 'إنشاء مشروع جديد' : 'Create New Project',
            onPressed: _openCreateProjectWizard,
          ),
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: AppColors.primaryBlue, size: 22),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateProjectWizard,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.brandNavy,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          isAr ? 'إنشاء مشروع جديد' : 'New Project',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
        ),
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
                // Search Bar
                FadeSlideEntrance(
                  duration: const Duration(milliseconds: 450),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        context.read<ProjectsCubit>().searchProjects(val);
                      },
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                      style: TextStyle(
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: isAr
                            ? 'بحث عن مشروع، مطور أو موقع...'
                            : 'Search project, developer or location...',
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
                  ),
                ),

                // Studies List
                Expanded(
                  child: studies.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 54,
                                  color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  isAr
                                      ? 'لا توجد مشاريع أو دراسات جدوى مطابقة'
                                      : 'No projects or feasibility studies found',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(
                                    isAr ? 'إنشاء مشروعك الأول الآن' : 'Create Your First Project',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: _openCreateProjectWizard,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
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
    final isAr = locale == 'ar';

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
              // Header: Title & Verdict
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        // Developer & Location
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              study.developerName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                study.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  VerdictBadge(
                    verdict: study.verdict,
                    score: study.feasibilityScore,
                    locale: locale,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tags row (Sector, Type, Land Area)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _tagBadge(study.assetType, AppColors.primaryBlue, isDark),
                  _tagBadge(study.projectType, AppColors.gold, isDark),
                  _tagBadge('${study.landArea.toStringAsFixed(0)} m²', isDark ? Colors.blueGrey : Colors.grey, isDark),
                ],
              ),
              const SizedBox(height: 14),

              // Financial KPI grid
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      isAr ? 'التكلفة\n(TDC)' : 'Cost\n(TDC)',
                      KpiMetricTile.formatCurrency(study.totalDevelopmentCost, currency: study.currency),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      isAr ? 'الإيرادات\nالمتوقعة' : 'Gross\nRevenue',
                      KpiMetricTile.formatCurrency(study.grossRevenue, currency: study.currency),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      isAr ? 'العائد\n(ROI)' : 'Return\n(ROI)',
                      '${study.roiPct.toStringAsFixed(1)}%',
                      isDark,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      isAr ? 'الداخلي\n(IRR)' : 'IRR\n(Rate)',
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

  Widget _tagBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
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
