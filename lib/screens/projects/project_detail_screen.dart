import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/pdf_export_service.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/charts/cashflow_bar_chart.dart';
import '../../widgets/charts/cost_breakdown_pie.dart';
import '../../widgets/kpi_metric_tile.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/verdict_badge.dart';
import 'project_assumptions_screen.dart';
import 'project_metrics_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final FeasibilityStudy study;

  const ProjectDetailScreen({super.key, required this.study});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FeasibilityStudy _study;

  // Sign-off checklist states (Slide 9)
  bool _chkReturn = true;
  bool _chkLiquidity = true;
  bool _chkResilience = true;
  bool _chkInputs = true;

  @override
  void initState() {
    super.initState();
    _study = widget.study;
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurr(double val) {
    return KpiMetricTile.formatCurrency(val, currency: _study.currency);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';

    final isEvaluated = _study.status == ProjectStatus.evaluated;
    final projectNumStr = '#${_study.projectNumber}';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF10172D) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF1E2547),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E284A) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                projectNumStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E2547),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _study.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E2547),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            // Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isEvaluated
                    ? const Color(0xFF059669).withValues(alpha: 0.15)
                    : const Color(0xFF2563EB).withValues(alpha: 0.15),
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
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB)),
            tooltip: isAr ? 'مؤشرات المشروع' : 'Project Metrics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectMetricsScreen(study: _study),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.fact_check_outlined, color: Color(0xFF2563EB)),
            tooltip: isAr ? 'الافتراضات' : 'Assumptions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectAssumptionsScreen(study: _study),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF2563EB)),
            tooltip: isAr ? 'تصدير التقرير PDF' : 'Share PDF Dossier',
            onPressed: () {
              PdfExportService.sharePdf(context, study: _study, locale: locale);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: isDark ? const Color(0xFF10172D) : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: isAr ? 'تفاصيل المشروع' : 'Project Details'),
                Tab(text: isAr ? 'تدفقات البناء' : 'Construction Run Off'),
                Tab(text: isAr ? 'تدفقات المبيعات' : 'Sales Run Off'),
                Tab(text: isAr ? 'التكاليف غير المباشرة' : 'Soft Cost'),
                Tab(text: isAr ? 'التدفق النقدي الموحد' : 'Consolidated Cash Flow'),
                Tab(text: isAr ? 'الملخص والقرار' : 'Executive Summary'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectDetailsTab(isDark, locale, isAr),
          _buildConstructionRunOffTab(isDark, locale, isAr),
          _buildSalesRunOffTab(isDark, locale, isAr),
          _buildSoftCostTab(isDark, locale, isAr),
          _buildConsolidatedCashFlowTab(isDark, locale, isAr),
          _buildExecutiveSummaryTab(isDark, locale, isAr),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: PROJECT DETAILS
  // ---------------------------------------------------------------------------
  Widget _buildProjectDetailsTab(bool isDark, String locale, bool isAr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verdict Card
          VerdictBadge(
            verdict: _study.verdict,
            score: _study.feasibilityScore,
            locale: locale,
            isExpanded: true,
            isPending: true,
          ),
          const SizedBox(height: 16),

          // Top Return Metrics
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: KpiMetricTile(
                    label: AppStrings.get('roi', locale: locale),
                    value: '--',
                    icon: Icons.trending_up_rounded,
                    accentColor: const Color(0xFF10B981),
                    isHighlight: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiMetricTile(
                    label: AppStrings.get('irr', locale: locale),
                    value: '--',
                    icon: Icons.percent_rounded,
                    accentColor: const Color(0xFF2563EB),
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
                    value: '--',
                    icon: Icons.account_balance_wallet_outlined,
                    accentColor: const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiMetricTile(
                    label: AppStrings.get('equityMultiple', locale: locale),
                    value: '--',
                    icon: Icons.multiline_chart_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Project Profile & Boundary Card
          _buildCard(
            title: isAr ? 'ملف وحدود المشروع' : 'Project Profile & Boundary',
            icon: Icons.business_rounded,
            isDark: isDark,
            children: [
              _specRow(isAr ? 'اسم المطور' : 'Developer Name', _study.developerName, isDark),
              _divider(isDark),
              _specRow(isAr ? 'نوع البيع' : 'Sales Type', _study.projectType, isDark),
              _divider(isDark),
              _specRow(isAr ? 'الدولة والموقع' : 'Country & Location', '${_study.location} (${_study.country})', isDark),
              if (_study.mapLocation != null && _study.mapLocation!.isNotEmpty) ...[
                _divider(isDark),
                _specRow(isAr ? 'إحداثيات الموقع' : 'Location Coordinates', _study.mapLocation!, isDark),
              ],
              _divider(isDark),
              _specRow(
                isAr ? 'الإطار الزمني للمشروع' : 'Project Time Frame',
                '${_study.startYear} - ${_study.endYear} (${_study.projectYears.length} ${isAr ? 'سنوات' : 'years'})',
                isDark,
              ),
              _divider(isDark),
              _specRow(isAr ? 'سنة بدء المبيعات' : 'Sales Start Year', '${_study.salesStartYear}', isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Land Details & Economics Card
          _buildCard(
            title: isAr ? 'اقتصاديات وهيكل الأرض' : 'Land Economics & Structure',
            icon: Icons.landscape_rounded,
            isDark: isDark,
            children: [
              _specRow(AppStrings.get('landArea', locale: locale), '${_study.landArea.toStringAsFixed(0)} m²', isDark),
              _divider(isDark),
              _specRow(isAr ? 'هيكل دفع الأرض' : 'Land Payment Structure', _study.landPaymentMode, isDark),
              if (_study.landPaymentYears > 0) ...[
                _divider(isDark),
                _specRow(isAr ? 'سنوات سداد الأرض' : 'Land Payment Years', '${_study.landPaymentYears} ${isAr ? 'سنوات' : 'years'}', isDark),
              ],
              if (_study.revenueSharePct > 0) ...[
                _divider(isDark),
                _specRow(isAr ? 'حصة الإيرادات' : 'Revenue Share', '${_study.revenueSharePct.toStringAsFixed(1)}%', isDark),
              ],
              if (_study.inKindSharePct > 0) ...[
                _divider(isDark),
                _specRow(isAr ? 'الحصة العينية' : 'In-Kind Share', '${_study.inKindSharePct.toStringAsFixed(1)}%', isDark),
              ],
              _divider(isDark),
              _specRow(isAr ? 'إجمالي تكلفة الأرض' : 'Total Land Cost', _formatCurr(_study.landCost), isDark),
              _divider(isDark),
              _specRow(AppStrings.get('far', locale: locale), '${_study.far.toStringAsFixed(1)}x', isDark),
              _divider(isDark),
              _specRow(AppStrings.get('bua', locale: locale), '${_study.bua.toStringAsFixed(0)} m²', isDark),
              _divider(isDark),
              _specRow(AppStrings.get('breakeven', locale: locale), '--', isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Sector Allocations Card
          if (_study.sectorPercentages.isNotEmpty)
            _buildCard(
              title: isAr ? 'توزيع القطاعات (100%)' : 'Sector Allocation (100%)',
              icon: Icons.pie_chart_outline_rounded,
              isDark: isDark,
              children: [
                ..._study.sectorPercentages.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${entry.value.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          const SizedBox(height: 16),

          // Products Catalog
          if (_study.products.isNotEmpty)
            _buildCard(
              title: isAr ? 'المنتجات المختارة والمواصفات' : 'Configured Products & Specifications',
              icon: Icons.inventory_2_outlined,
              isDark: isDark,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? const Color(0xFF1E284A) : const Color(0xFFF1F5F9),
                    ),
                    columns: [
                      DataColumn(label: Text(isAr ? 'المنتج' : 'Product')),
                      DataColumn(label: Text(isAr ? 'القطاع' : 'Sector')),
                      DataColumn(label: Text(isAr ? 'الوزن %' : 'Mix %')),
                      DataColumn(label: Text(isAr ? 'م² الأرض' : 'Plot Area')),
                      DataColumn(label: Text(isAr ? 'متوسط م²' : 'Avg Area')),
                      DataColumn(label: Text(isAr ? 'التشطيب' : 'Finishing')),
                      DataColumn(label: Text(isAr ? 'سعر البيع' : 'Price Rate')),
                    ],
                    rows: _study.products.map((p) {
                      return DataRow(cells: [
                        DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(p.sector)),
                        DataCell(Text('${p.productMixPct.toStringAsFixed(0)}%')),
                        DataCell(Text('${p.plotArea.toStringAsFixed(0)} m²')),
                        DataCell(Text('${p.avgArea.toStringAsFixed(0)} m²')),
                        DataCell(Text(p.propertyFinishing)),
                        DataCell(Text('${p.priceRate.toStringAsFixed(0)} ${_study.currency}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Cost Breakdown Chart
          _buildCard(
            title: AppStrings.get('costBreakdown', locale: locale),
            icon: Icons.donut_large_rounded,
            isDark: isDark,
            children: [
              CostBreakdownPie(study: _study, locale: locale),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: CONSTRUCTION RUN OFF (Slide 8)
  // ---------------------------------------------------------------------------
  Widget _buildConstructionRunOffTab(bool isDark, String locale, bool isAr) {
    final runOff = _study.getConstructionRunOff();
    final years = _study.projectYears;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Information Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.construction_rounded, color: Color(0xFF2563EB), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr
                        ? 'جدول تدفقات البناء السنوية المحسوبة وفق منحنى S-Curve ومراكز التكلفة المباشرة.'
                        : 'Phased hard construction run-off calculated across project timeline using S-Curve distribution.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF1E2547),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Run-off table
          _buildCard(
            title: isAr ? 'جدول تدفقات تكاليف البناء' : 'Construction Run-Off Table',
            icon: Icons.table_chart_rounded,
            isDark: isDark,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? const Color(0xFF1E284A) : const Color(0xFFF1F5F9),
                  ),
                  columns: [
                    DataColumn(label: Text(isAr ? 'مركز التكلفة' : 'Cost Centre')),
                    ...years.map((y) => DataColumn(label: Text('Y$y'))),
                    DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total')),
                  ],
                  rows: [
                    ...runOff.keys.map((category) {
                      final yearMap = runOff[category] ?? {};
                      double catSum = 0.0;
                      return DataRow(
                        cells: [
                          DataCell(Text(category, style: const TextStyle(fontWeight: FontWeight.w600))),
                          ...years.map((y) {
                            final val = yearMap[y] ?? 0.0;
                            catSum += val;
                            return DataCell(Text(_formatCurr(val)));
                          }),
                          DataCell(Text(_formatCurr(catSum), style: const TextStyle(fontWeight: FontWeight.w700))),
                        ],
                      );
                    }),
                    // Total Construction Outflow Row
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            isAr ? 'إجمالي تكاليف البناء' : 'Total Hard Cost',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                          ),
                        ),
                        ...years.map((y) {
                          double yearTotal = 0.0;
                          for (final cat in runOff.keys) {
                            yearTotal += (runOff[cat]?[y] ?? 0.0);
                          }
                          return DataCell(
                            Text(
                              _formatCurr(yearTotal),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                            ),
                          );
                        }),
                        DataCell(
                          Text(
                            _formatCurr(_study.constructionCost),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: SALES RUN OFF (Slide 8)
  // ---------------------------------------------------------------------------
  Widget _buildSalesRunOffTab(bool isDark, String locale, bool isAr) {
    final salesRunOff = _study.getSalesRunOff();
    final years = _study.projectYears;
    final assumptions = _study.assumptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.point_of_sale_rounded, color: Color(0xFF059669), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr
                        ? 'معدل البيع التدريجي السنوي ومعدل نمو الأسعار والإيرادات المحصلة.'
                        : 'Phased sales distribution, price appreciation, and annual collected off-plan revenue.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF1E2547),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildCard(
            title: isAr ? 'جدول تدفقات المبيعات' : 'Sales Run-Off Table',
            icon: Icons.analytics_outlined,
            isDark: isDark,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? const Color(0xFF1E284A) : const Color(0xFFF1F5F9),
                  ),
                  columns: [
                    DataColumn(label: Text(isAr ? 'البند' : 'Metric')),
                    ...years.map((y) => DataColumn(label: Text('Y$y'))),
                    DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total')),
                  ],
                  rows: [
                    // Sales Trend %
                    DataRow(cells: [
                      DataCell(Text(isAr ? 'نسبة المبيعات السنوية (%)' : 'Sales Trend %', style: const TextStyle(fontWeight: FontWeight.w600))),
                      ...years.map((y) => DataCell(Text('${assumptions.salesTrend[y] ?? 0.0}%'))),
                      const DataCell(Text('100%', style: TextStyle(fontWeight: FontWeight.w700))),
                    ]),
                    // Price Growth %
                    DataRow(cells: [
                      DataCell(Text(isAr ? 'معدل نمو الأسعار (%)' : 'Price Growth %', style: const TextStyle(fontWeight: FontWeight.w600))),
                      ...years.map((y) => DataCell(Text('${assumptions.priceGrowth[y] ?? 0.0}%'))),
                      const DataCell(Text('-')),
                    ]),
                    // Off-Plan Sales Revenue
                    DataRow(cells: [
                      DataCell(Text(isAr ? 'إيرادات المبيعات على الخارطة' : 'Off-Plan Sales Revenue', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669)))),
                      ...years.map((y) => DataCell(Text(_formatCurr(salesRunOff[y] ?? 0.0), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF059669))))),
                      DataCell(Text(_formatCurr(_study.grossRevenue), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669)))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: SOFT COST (Slide 8)
  // ---------------------------------------------------------------------------
  Widget _buildSoftCostTab(bool isDark, String locale, bool isAr) {
    final softRunOff = _study.getSoftCostRunOff();
    final years = _study.projectYears;
    final totalSoft = _study.softCosts;
    final totalContingency = _study.contingencyCost;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            title: isAr ? 'تفاصيل التكاليف غير المباشرة والطوارئ' : 'Soft Costs & Phasing',
            icon: Icons.account_balance_outlined,
            isDark: isDark,
            children: [
              _specRow(isAr ? 'نسبة التكاليف غير المباشرة' : 'Soft Cost Rate', '${_study.softCostPct}%', isDark),
              _divider(isDark),
              _specRow(isAr ? 'إجمالي التكاليف غير المباشرة' : 'Total Soft Costs', _formatCurr(totalSoft), isDark),
              _divider(isDark),
              _specRow(isAr ? 'نسبة الطوارئ' : 'Contingency Rate', '${_study.contingencyPct}%', isDark),
              _divider(isDark),
              _specRow(isAr ? 'إجمالي مخصص الطوارئ' : 'Total Contingency Amount', _formatCurr(totalContingency), isDark),
            ],
          ),
          const SizedBox(height: 16),

          _buildCard(
            title: isAr ? 'جدول التوزيع السنوي للتكاليف غير المباشرة' : 'Phased Soft Costs Schedule',
            icon: Icons.calendar_month_outlined,
            isDark: isDark,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? const Color(0xFF1E284A) : const Color(0xFFF1F5F9),
                  ),
                  columns: [
                    DataColumn(label: Text(isAr ? 'البند' : 'Cost Item')),
                    ...years.map((y) => DataColumn(label: Text('Y$y'))),
                    DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text(isAr ? 'التكاليف غير المباشرة والطوارئ' : 'Soft Costs & Contingency', style: const TextStyle(fontWeight: FontWeight.w700))),
                      ...years.map((y) => DataCell(Text(_formatCurr(softRunOff[y] ?? 0.0)))),
                      DataCell(Text(_formatCurr(totalSoft + totalContingency), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB)))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 5: CONSOLIDATED CASH FLOW (Slide 8)
  // ---------------------------------------------------------------------------
  Widget _buildConsolidatedCashFlowTab(bool isDark, String locale, bool isAr) {
    final cfList = _study.getConsolidatedCashFlow();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart
          _buildCard(
            title: AppStrings.get('cashFlowProjection', locale: locale),
            icon: Icons.waterfall_chart_rounded,
            isDark: isDark,
            children: [
              CashflowBarChart(study: _study, locale: locale),
            ],
          ),
          const SizedBox(height: 16),

          // Consolidated Table (Slide 8)
          _buildCard(
            title: isAr ? 'جدول التدفق النقدي الموحد' : 'Consolidated Cash Flow Table',
            icon: Icons.table_view_rounded,
            isDark: isDark,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? const Color(0xFF1E284A) : const Color(0xFFF1F5F9),
                  ),
                  columns: [
                    DataColumn(label: Text(isAr ? 'بند التدفق' : 'Cash Flow Line')),
                    ...cfList.map((cf) => DataColumn(label: Text('Y${cf.year}'))),
                    DataColumn(label: Text(isAr ? 'إجمالي المشروع' : 'Total Project')),
                  ],
                  rows: [
                    // Cash In Section Header
                    DataRow(
                      color: WidgetStateProperty.all(const Color(0xFF059669).withValues(alpha: 0.1)),
                      cells: [
                        DataCell(Text(isAr ? '1. المقبوضات النقدية' : '1. Total Cash In', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669)))),
                        ...cfList.map((_) => const DataCell(Text(''))),
                        const DataCell(Text('')),
                      ],
                    ),
                    // Off-Plan Sales
                    DataRow(cells: [
                      DataCell(Text('  • ${isAr ? 'مبيعات على الخارطة' : 'Off-Plan Sales'}')),
                      ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.offPlanSales)))),
                      DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.offPlanSales)))),
                    ]),
                    // Rent
                    DataRow(cells: [
                      DataCell(Text('  • ${isAr ? 'إيرادات الإيجار' : 'Rental Income'}')),
                      ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.rent)))),
                      DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.rent)))),
                    ]),
                    // Terminal Value
                    DataRow(cells: [
                      DataCell(Text('  • ${isAr ? 'القيمة المتبقية' : 'Terminal Value'}')),
                      ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.terminalValue)))),
                      DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.terminalValue)))),
                    ]),
                    // Total Cash In
                    DataRow(
                      cells: [
                        DataCell(Text(isAr ? 'إجمالي المقبوضات النقدية' : 'Total Cash In', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669)))),
                        ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.totalCashIn), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669))))),
                        DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.totalCashIn)), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669)))),
                      ],
                    ),

                    // Cash Out Section Header
                    DataRow(
                      color: WidgetStateProperty.all(const Color(0xFFDC2626).withValues(alpha: 0.1)),
                      cells: [
                        DataCell(Text(isAr ? '2. المدفوعات النقدية' : '2. Total Cash Out', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)))),
                        ...cfList.map((_) => const DataCell(Text(''))),
                        const DataCell(Text('')),
                      ],
                    ),
                    // Hard Construction
                    DataRow(cells: [
                      DataCell(Text('  • ${isAr ? 'تكاليف البناء' : 'Construction Costs'}')),
                      ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.constructionCost)))),
                      DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.constructionCost)))),
                    ]),
                    // Soft Costs
                    DataRow(cells: [
                      DataCell(Text('  • ${isAr ? 'التكاليف غير المباشرة' : 'Soft Costs'}')),
                      ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.softCost)))),
                      DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.softCost)))),
                    ]),
                    // Land Payments
                    DataRow(cells: [
                      DataCell(Text('  • ${isAr ? 'دفعات الأرض' : 'Land Payments'}')),
                      ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.landPayment)))),
                      DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.landPayment)))),
                    ]),
                    // Total Cash Out
                    DataRow(
                      cells: [
                        DataCell(Text(isAr ? 'إجمالي المدفوعات النقدية' : 'Total Cash Out', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)))),
                        ...cfList.map((cf) => DataCell(Text(_formatCurr(cf.totalCashOut), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626))))),
                        DataCell(Text(_formatCurr(cfList.fold(0.0, (s, c) => s + c.totalCashOut)), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFDC2626)))),
                      ],
                    ),

                    // Net Cash Flow
                    DataRow(
                      color: WidgetStateProperty.all(isDark ? const Color(0xFF131B33) : const Color(0xFFF1F5F9)),
                      cells: [
                        DataCell(Text(isAr ? 'صافي التدفق النقدي' : 'Net Cash Flow', style: const TextStyle(fontWeight: FontWeight.w800))),
                        ...cfList.map((cf) => DataCell(
                          Text(
                            _formatCurr(cf.netCashFlow),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: cf.netCashFlow >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        )),
                        DataCell(
                          Text(
                            _formatCurr(cfList.fold(0.0, (s, c) => s + c.netCashFlow)),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),

                    // Cumulative Cash Flow
                    DataRow(
                      cells: [
                        DataCell(Text(isAr ? 'التدفق النقدي التراكمي' : 'Cumulative Cash Flow', style: const TextStyle(fontWeight: FontWeight.w800))),
                        ...cfList.map((cf) => DataCell(
                          Text(
                            _formatCurr(cf.cumulativeCashFlow),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: cf.cumulativeCashFlow >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        )),
                        DataCell(
                          Text(
                            _formatCurr(cfList.last.cumulativeCashFlow),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 6: EXECUTIVE SUMMARY & DECISION (Slide 9)
  // ---------------------------------------------------------------------------
  Widget _buildExecutiveSummaryTab(bool isDark, String locale, bool isAr) {
    final isGo = _study.isGoDecision;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // MVP Working Rule Card (Slide 9)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isGo
                  ? (isDark ? const Color(0xFF042F2E) : const Color(0xFFECFDF5))
                  : (isDark ? const Color(0xFF3B0712) : const Color(0xFFFFF1F2)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isGo ? const Color(0xFF059669) : const Color(0xFFDC2626),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isGo ? const Color(0xFF059669) : const Color(0xFFDC2626)).withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isGo ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isGo
                            ? (isAr ? 'القرار: انطلاق' : 'DECISION: GO')
                            : (isAr ? 'القرار: توقف' : 'DECISION: NO-GO'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isGo ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isGo ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isGo
                      ? (isAr
                          ? 'المشروع يحقق معايير الاستثمار: صافي القيمة الحالية موجبة ومعدل العائد الداخلي أعلى من العائد المستهدف (${_study.hurdleRate.toStringAsFixed(0)}%).'
                          : 'Project satisfies investment hurdle: Equity NPV is positive (NPV ≥ 0) and IRR meets or exceeds hurdle rate (${_study.hurdleRate.toStringAsFixed(0)}%).')
                      : (isAr
                          ? 'المشروع لا يحقق المعايير: العائد الداخلي أقل من العائد المستهدف (${_study.hurdleRate.toStringAsFixed(0)}%) أو القيمة الحالية سالبة.'
                          : 'Project does not meet investment hurdle criteria: IRR is below ${_study.hurdleRate.toStringAsFixed(0)}% or Equity NPV is negative.'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E2547),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                // Rule definition banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAr
                        ? 'قاعدة القرار: انطلاق إذا كان صافي القيمة الحالية ≥ 0 ومعدل العائد الداخلي ≥ ${_study.hurdleRate.toStringAsFixed(0)}% | توقف إذا كان صافي القيمة الحالية < 0 أو معدل العائد الداخلي < ${_study.hurdleRate.toStringAsFixed(0)}%'
                        : 'MVP Working Rule: GO: NPV ≥ 0 AND IRR ≥ ${_study.hurdleRate.toStringAsFixed(0)}% | NO-GO: NPV < 0 OR IRR < ${_study.hurdleRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Return Metrics Grid (Slide 9)
          _buildCard(
            title: isAr ? 'المؤشرات المالية الرئيسية' : 'Key Return Metrics',
            icon: Icons.trending_up_rounded,
            isDark: isDark,
            children: [
              _specRow(isAr ? 'معدل العائد الداخلي على حقوق الملكية' : 'Equity IRR', '--', isDark),
              _divider(isDark),
              _specRow(isAr ? 'معدل العائد المستهدف' : 'Hurdle Rate Benchmark', '${_study.hurdleRate.toStringAsFixed(1)}%', isDark),
              _divider(isDark),
              _specRow(isAr ? 'فترة استرداد رأس المال' : 'Payback Period', '--', isDark),
              _divider(isDark),
              _specRow(isAr ? 'صافي القيمة الحالية لحقوق الملكية' : 'Equity NPV', '--', isDark),
              _divider(isDark),
              _specRow(isAr ? 'هامش الربح' : 'Profit Margin', '--', isDark),
              _divider(isDark),
              _specRow(isAr ? 'العائد على التطوير' : 'Return on Development (ROD)', '--', isDark),
              _divider(isDark),
              _specRow(isAr ? 'مضاعف حقوق الملكية' : 'Equity Multiple', '--', isDark),
            ],
          ),
          const SizedBox(height: 18),

          // Property Stats (SQM Breakdown) (Slide 9)
          _buildCard(
            title: isAr ? 'إحصائيات العقار والمساحات' : 'Property Stats (SQM Breakdown)',
            icon: Icons.square_foot_rounded,
            isDark: isDark,
            children: [
              _specRow(isAr ? 'مساحة الأرض الإجمالية' : 'Total Land Area', '${_study.landArea.toStringAsFixed(0)} m²', isDark),
              _divider(isDark),
              _specRow(isAr ? 'إجمالي المساحة البنائية' : 'Total BUA', '${_study.bua.toStringAsFixed(0)} m²', isDark),
              _divider(isDark),
              _specRow(isAr ? 'المساحة المبنية الطابقية' : 'Gross Floor Area (GFA)', '${_study.gfa.toStringAsFixed(0)} m²', isDark),
              _divider(isDark),
              _specRow(isAr ? 'معامل البناء' : 'Floor Area Ratio (FAR)', '${_study.far.toStringAsFixed(1)}x', isDark),
              _divider(isDark),
              _specRow(isAr ? 'سعر التعادل للمتر' : 'Breakeven / m²', '--', isDark),
            ],
          ),
          const SizedBox(height: 18),

          // Confirmation Checklist before Sign-Off (Slide 9)
          _buildCard(
            title: isAr ? 'قائمة التحقق قبل الاعتماد' : 'Pre-Sign-Off Confirmation Checklist',
            icon: Icons.checklist_rounded,
            isDark: isDark,
            children: [
              _buildCheckTile(
                title: isAr ? 'متطلب العائد' : 'Return Requirement',
                subtitle: isAr
                    ? 'تحقيق معدل العائد الداخلي لحقوق الملكية أعلى من المعدل المستهدف (${_study.hurdleRate.toStringAsFixed(0)}%).'
                    : 'Equity IRR exceeds hurdle rate (${_study.hurdleRate.toStringAsFixed(0)}%).',
                value: _chkReturn,
                onChanged: (v) => setState(() => _chkReturn = v ?? false),
                isDark: isDark,
              ),
              _divider(isDark),
              _buildCheckTile(
                title: isAr ? 'السيولة والاحتياطي النقدي' : 'Liquidity & Cash Buffer',
                subtitle: isAr
                    ? 'اختبار فترات التدفق النقدي والتأكد من إيجابية التدفقات التراكمية.'
                    : 'Phased cash flow stress-tested; positive cumulative reserves.',
                value: _chkLiquidity,
                onChanged: (v) => setState(() => _chkLiquidity = v ?? false),
                isDark: isDark,
              ),
              _divider(isDark),
              _buildCheckTile(
                title: isAr ? 'المرونة ومخصصات الطوارئ' : 'Resilience & Buffers',
                subtitle: isAr
                    ? 'تضمين منحنى التوزيع السنوي ومخصصات طوارئ لتغطية أي تأخير في التنفيذ.'
                    : 'S-Curve phasing and contingency allocations configured.',
                value: _chkResilience,
                onChanged: (v) => setState(() => _chkResilience = v ?? false),
                isDark: isDark,
              ),
              _divider(isDark),
              _buildCheckTile(
                title: isAr ? 'دقة المدخلات والمقارنات' : 'Inputs & Benchmark Accuracy',
                subtitle: isAr
                    ? 'التحقق من أسعار المتر ومزيج المنتجات ومقارنتها بمعايير السوق.'
                    : 'Unit pricing and product mix cross-referenced with market data.',
                value: _chkInputs,
                onChanged: (v) => setState(() => _chkInputs = v ?? false),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          PrimaryButton(
            text: isAr ? 'تصدير التقرير الرسمي المعتمد PDF' : 'Export Official Signed PDF Report',
            icon: Icons.picture_as_pdf_outlined,
            backgroundColor: const Color(0xFF2563EB),
            onPressed: () {
              PdfExportService.sharePdf(context, study: _study, locale: locale);
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildCheckTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2563EB),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1E2547),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white60 : const Color(0xFF64748B),
          height: 1.3,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E2547),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 14,
      color: isDark ? const Color(0xFF1E284A) : const Color(0xFFE2E8F0),
    );
  }
}
