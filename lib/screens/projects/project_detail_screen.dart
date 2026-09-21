import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/pdf_export_service.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/charts/cashflow_bar_chart.dart';
import '../../widgets/charts/cost_breakdown_pie.dart';
import '../../widgets/charts/scenario_comparison_chart.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/kpi_metric_tile.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/verdict_badge.dart';
import 'project_metrics_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final FeasibilityStudy study;

  const ProjectDetailScreen({super.key, required this.study});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          study.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.gold),
            tooltip: locale == 'ar' ? 'مؤشرات ومواصفات المشروع' : 'Project Metrics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectMetricsScreen(study: study),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.gold),
            tooltip: locale == 'ar' ? 'مشاركة ملف PDF' : 'Share PDF Dossier',
            onPressed: () {
              PdfExportService.sharePdf(context, study: study, locale: locale);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.gold),
            tooltip: 'Load in calculator',
            onPressed: () {
              context.read<CalculatorCubit>().loadStudy(study);
              AppSnackBar.showInfo(
                context,
                message: locale == 'ar'
                    ? 'تم تحميل المشروع في الحاسبة للتعديل'
                    : 'Study loaded into calculator for simulation',
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verdict Card
            VerdictBadge(
              verdict: study.verdict,
              score: study.feasibilityScore,
              locale: locale,
              isExpanded: true,
            ),
            const SizedBox(height: 18),

            // Top Return Metrics
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: KpiMetricTile(
                      label: AppStrings.get('roi', locale: locale),
                      value: '${study.roiPct.toStringAsFixed(1)}%',
                      icon: Icons.trending_up_rounded,
                      accentColor: AppColors.success,
                      isHighlight: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiMetricTile(
                      label: AppStrings.get('irr', locale: locale),
                      value: '${study.annualizedIrrPct.toStringAsFixed(1)}%',
                      icon: Icons.percent_rounded,
                      accentColor: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: KpiMetricTile(
                      label: AppStrings.get('netProfit', locale: locale),
                      value: KpiMetricTile.formatCurrency(study.netProfit, currency: study.currency),
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiMetricTile(
                      label: AppStrings.get('equityMultiple', locale: locale),
                      value: '${study.equityMultiple.toStringAsFixed(2)}x',
                      icon: Icons.multiline_chart_rounded,
                      accentColor: AppColors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Project Specifications Table Card
            _buildCard(
              title: AppStrings.get('projectDetails', locale: locale),
              icon: Icons.location_city_rounded,
              isDark: isDark,
              children: [
                _specRow(locale == 'ar' ? 'اسم المطور' : 'Developer Name', study.developerName, isDark),
                _divider(isDark),
                _specRow(AppStrings.get('projectType', locale: locale), study.assetType, isDark),
                _divider(isDark),
                _specRow(locale == 'ar' ? 'نوع الاستراتيجية' : 'Strategy Type', study.projectType, isDark),
                _divider(isDark),
                _specRow(locale == 'ar' ? 'الدولة والموقع' : 'Country & Location', '${study.location} (${study.country})', isDark),
                _divider(isDark),
                _specRow(locale == 'ar' ? 'هيكل دفع الأرض' : 'Land Payment Mode', study.landPaymentMode, isDark),
                if (study.landPaymentYears > 0) ...[
                  _divider(isDark),
                  _specRow(locale == 'ar' ? 'سنوات سداد الأرض' : 'Land Payment Years', '${study.landPaymentYears} ${locale == 'ar' ? 'سنوات' : 'years'}', isDark),
                ],
                if (study.revenueSharePct > 0) ...[
                  _divider(isDark),
                  _specRow(locale == 'ar' ? 'حصة الإيرادات' : 'Revenue Share', '${study.revenueSharePct.toStringAsFixed(study.revenueSharePct.truncateToDouble() == study.revenueSharePct ? 0 : 1)}%', isDark),
                ],
                if (study.inKindSharePct > 0) ...[
                  _divider(isDark),
                  _specRow(locale == 'ar' ? 'الحصة العينية' : 'In-Kind Share', '${study.inKindSharePct.toStringAsFixed(study.inKindSharePct.truncateToDouble() == study.inKindSharePct ? 0 : 1)}%', isDark),
                ],
                _divider(isDark),
                _specRow(AppStrings.get('landArea', locale: locale), '${study.landArea.toStringAsFixed(0)} m²', isDark),
                _divider(isDark),
                _specRow(AppStrings.get('far', locale: locale), '${study.far.toStringAsFixed(1)}x', isDark),
                _divider(isDark),
                _specRow(AppStrings.get('bua', locale: locale), '${study.bua.toStringAsFixed(0)} m²', isDark),
                _divider(isDark),
                _specRow(AppStrings.get('gfa', locale: locale), '${study.gfa.toStringAsFixed(0)} m²', isDark),
                _divider(isDark),
                _specRow(AppStrings.get('breakeven', locale: locale), '${study.breakevenPerSqm.toStringAsFixed(0)} ${study.currency}/m²', isDark),
                if (study.products.isNotEmpty) ...[
                  _divider(isDark),
                  _specRow(
                    locale == 'ar' ? 'مزيج المنتجات' : 'Product Mix',
                    study.products.map((p) => '${p.name} (${p.productMixPct.toStringAsFixed(0)}%)').join('، '),
                    isDark,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),

            // Cost Breakdown Chart
            _buildCard(
              title: AppStrings.get('costBreakdown', locale: locale),
              icon: Icons.donut_large_rounded,
              isDark: isDark,
              children: [
                CostBreakdownPie(study: study, locale: locale),
              ],
            ),
            const SizedBox(height: 18),

            // Phased Cashflows
            _buildCard(
              title: AppStrings.get('cashFlowProjection', locale: locale),
              icon: Icons.waterfall_chart_rounded,
              isDark: isDark,
              children: [
                CashflowBarChart(study: study, locale: locale),
              ],
            ),
            const SizedBox(height: 18),

            // Sensitivity Scenarios
            _buildCard(
              title: AppStrings.get('scenarioAnalysis', locale: locale),
              icon: Icons.balance_rounded,
              isDark: isDark,
              children: [
                ScenarioComparisonChart(study: study, locale: locale),
              ],
            ),
            const SizedBox(height: 20),

            // Export Summary Button
            PrimaryButton(
              text: AppStrings.get('exportPdf', locale: locale),
              icon: Icons.picture_as_pdf_outlined,
              backgroundColor: AppColors.primaryBlue,
              onPressed: () {
                _showExportModal(context, locale, isDark);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _specRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 16,
      color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
    );
  }

  void _showExportModal(BuildContext context, String locale, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.gold),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale == 'ar' ? 'تقرير دراسة الجدوى التنفيذي' : 'Executive Feasibility Dossier',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${study.title}.pdf',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                locale == 'ar'
                    ? 'تم إعداد تقرير شامل يحتوي على المؤشرات المالية (ROI/IRR)، وتوزيع التكاليف، ومراحل التدفقات النقدية، ومعايير السوق الإقليمية.'
                    : 'The summary dossier includes TDC breakdown, IRR sensitivity curves, market comparables, and investment committee sign-off metrics.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: locale == 'ar' ? 'تنزيل ومشاركة التقرير (PDF) ↗' : 'Download & Share PDF Dossier ↗',
                icon: Icons.share_rounded,
                backgroundColor: AppColors.primaryBlue,
                onPressed: () {
                  Navigator.pop(context);
                  PdfExportService.sharePdf(
                    context,
                    study: study,
                    locale: locale,
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
