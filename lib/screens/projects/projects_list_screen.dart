import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/pdf_export_service.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/projects/projects_state.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/kpi_metric_tile.dart';
import '../workspace/create_project_wizard_screen.dart';
import 'project_assumptions_screen.dart';
import 'project_detail_screen.dart';
import 'project_metrics_screen.dart';

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
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF10172D) : Colors.white,
        elevation: 0,
        title: Text(
          isAr ? 'المشاريع ودراسات الجدوى' : 'Projects & Studies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1E2547),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2563EB), size: 24),
            tooltip: isAr ? 'إنشاء مشروع جديد' : 'Create New Project',
            onPressed: _openCreateProjectWizard,
          ),
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: Color(0xFF2563EB), size: 24),
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
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          if (state is ProjectsLoaded) {
            final studies = state.filteredStudies;

            return Column(
              children: [
                // Search Bar
                FadeSlideEntrance(
                  duration: const Duration(milliseconds: 450),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        context.read<ProjectsCubit>().searchProjects(val);
                      },
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E2547),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: isAr
                            ? 'بحث عن مشروع، مطور أو موقع...'
                            : 'Search project, developer or location...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF10172D) : Colors.white,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF1E284A) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF1E284A) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  size: 56,
                                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  isAr
                                      ? 'لا توجد مشاريع أو دراسات جدوى مطابقة'
                                      : 'No projects or feasibility studies found',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
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
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 80),
                          itemCount: studies.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final study = studies[index];
                            return FadeSlideEntrance(
                              delay: Duration(milliseconds: 80 + (index * 40)),
                              duration: const Duration(milliseconds: 400),
                              child: _buildProjectCard(context, study, isDark, locale),
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

  Widget _buildProjectCard(
    BuildContext context,
    FeasibilityStudy study,
    bool isDark,
    String locale,
  ) {
    final isAr = locale == 'ar';
    final isEvaluated = study.status == ProjectStatus.evaluated;
    final projectNum = '#${study.projectNumber}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10172D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E284A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(study: study),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Project ID, Title, Status & Actions Menu (Slide 3)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E284A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2D3B6E) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      projectNum,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E2547),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title & Developer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          study.title,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1E2547),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 13,
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                study.developerName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
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

                  // Status Badge (Slide 3: Initialized vs Evaluated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEvaluated
                          ? const Color(0xFF059669).withValues(alpha: 0.12)
                          : const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isEvaluated ? const Color(0xFF059669) : const Color(0xFF2563EB),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isEvaluated
                          ? (isAr ? 'تم التقييم' : 'Evaluated')
                          : (isAr ? 'مُنشأ' : 'Initialized'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isEvaluated ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Context Action Menu (Slide 3 Action Menu)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      size: 20,
                    ),
                    color: isDark ? const Color(0xFF16203D) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      switch (val) {
                        case 'show':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(study: study),
                            ),
                          );
                          break;
                        case 'edit':
                          context.read<CalculatorCubit>().loadStudy(study);
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          }
                          break;
                        case 'metrics':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectMetricsScreen(study: study),
                            ),
                          );
                          break;
                        case 'assumptions':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectAssumptionsScreen(study: study),
                            ),
                          );
                          break;
                        case 'report':
                          PdfExportService.sharePdf(context, study: study, locale: locale);
                          break;
                        case 'delete':
                          _confirmDelete(context, study, isAr);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'show',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Text(isAr ? 'عرض (Show)' : 'Show', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Text(isAr ? 'تعديل (Edit)' : 'Edit in Calculator', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'metrics',
                        child: Row(
                          children: [
                            const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Text(isAr ? 'المؤشرات (Metrics)' : 'Metrics & Products', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'assumptions',
                        child: Row(
                          children: [
                            const Icon(Icons.fact_check_outlined, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Text(isAr ? 'الافتراضات (Assumptions)' : 'Assumptions & Phasing', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Text(isAr ? 'إصدار تقرير (Generate Report)' : 'Generate Report (PDF)', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                            const SizedBox(width: 10),
                            Text(isAr ? 'حذف (Delete)' : 'Delete', style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timing & Details Bar (Slide 3: Start At, Sales Start At)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0E1528) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E284A) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isAr ? 'بدء المشروع' : 'Start'}: ${study.startYear}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('•', style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8))),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.point_of_sale_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isAr ? 'بدء البيع' : 'Sales Start'}: ${study.salesStartYear}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                    const Spacer(),
                    // Decision Pill if evaluated
                    if (isEvaluated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: study.isGoDecision
                              ? const Color(0xFF059669).withValues(alpha: 0.2)
                              : const Color(0xFFDC2626).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          study.isGoDecision ? 'GO' : 'NO-GO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: study.isGoDecision ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tags Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _tagBadge(study.assetType, const Color(0xFF2563EB), isDark),
                  _tagBadge(study.projectType, const Color(0xFF0284C7), isDark),
                  _tagBadge('${study.landArea.toStringAsFixed(0)} m²', const Color(0xFF64748B), isDark),
                ],
              ),
              const SizedBox(height: 12),

              // KPI Row
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      isAr ? 'التكلفة (TDC)' : 'Cost (TDC)',
                      KpiMetricTile.formatCurrency(study.totalDevelopmentCost, currency: study.currency),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      isAr ? 'الإيرادات' : 'Revenue',
                      KpiMetricTile.formatCurrency(study.grossRevenue, currency: study.currency),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      isAr ? 'العائد (ROI)' : 'ROI',
                      '${study.roiPct.toStringAsFixed(1)}%',
                      isDark,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _metric(
                      isAr ? 'الداخلي (IRR)' : 'Equity IRR',
                      '${study.annualizedIrrPct.toStringAsFixed(1)}%',
                      isDark,
                      color: const Color(0xFF2563EB),
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

  void _confirmDelete(BuildContext context, FeasibilityStudy study, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAr ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          isAr
              ? 'هل أنت متأكد من رغبتك في حذف مشروع "${study.title}"؟'
              : 'Are you sure you want to delete "${study.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProjectsCubit>().deleteStudy(study.id);
              AppSnackBar.showSuccess(
                context,
                message: isAr ? 'تم حذف المشروع بنجاح' : 'Project deleted successfully',
              );
            },
            child: Text(isAr ? 'حذف' : 'Delete'),
          ),
        ],
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
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
