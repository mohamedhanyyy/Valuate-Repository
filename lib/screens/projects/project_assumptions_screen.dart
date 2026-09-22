import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/valuate_logo.dart';
import 'project_detail_screen.dart';

class ProjectAssumptionsScreen extends StatefulWidget {
  final FeasibilityStudy study;

  const ProjectAssumptionsScreen({super.key, required this.study});

  @override
  State<ProjectAssumptionsScreen> createState() =>
      _ProjectAssumptionsScreenState();
}

class _ProjectAssumptionsScreenState extends State<ProjectAssumptionsScreen> {
  late FeasibilityStudy _study;
  late List<int> _years;

  // Sales Trend % controllers
  final Map<int, TextEditingController> _salesTrendControllers = {};

  // Price Growth % controller
  late TextEditingController _priceGrowthController;

  // Hard Cost BUA / Unit rate controllers
  final Map<String, TextEditingController> _hardCostControllers = {};

  // Construction S-Curve controllers: CostCentre -> Year -> controller
  final Map<String, Map<int, TextEditingController>> _sCurveControllers = {};

  // Override rule / audit controller
  late TextEditingController _overrideNotesController;

  final List<String> _costCentres = const [
    'Grading & Mobilization',
    'Villas Building structure & block work',
    'Landscape',
    'Infrastructure',
    'Finishing Cost',
  ];

  String _costCentreLabel(String cat, bool isAr) {
    if (!isAr) return cat;
    switch (cat) {
      case 'Grading & Mobilization':
        return 'التسوية والتجهيزات الأولية';
      case 'Villas Building structure & block work':
        return 'الهيكل الإنشائي وأعمال البلوك';
      case 'Landscape':
        return 'تنسيق الموقع والمسطحات الخضراء';
      case 'Infrastructure':
        return 'البنية التحتية والمرافق';
      case 'Finishing Cost':
        return 'تكاليف التشطيبات';
      default:
        return cat;
    }
  }

  @override
  void initState() {
    super.initState();
    _study = widget.study;
    _years = _study.projectYears;

    final asm = _study.assumptions;

    // Initialize Sales Trend
    for (final y in _years) {
      final initialVal = asm.salesTrend[y] ?? (y == _years.first ? 15.0 : (y == _years[1] ? 50.0 : 35.0));
      _salesTrendControllers[y] = TextEditingController(text: initialVal.toStringAsFixed(0));
    }

    // Price growth
    _priceGrowthController = TextEditingController(text: asm.priceGrowthRate.toStringAsFixed(0));

    // Hard cost unit rates
    for (final cat in _costCentres) {
      final rate = asm.hardCostUnitRates[cat] ?? 3500.0;
      _hardCostControllers[cat] = TextEditingController(text: rate.toStringAsFixed(0));
    }

    // Construction S-Curve
    for (final cat in _costCentres) {
      _sCurveControllers[cat] = {};
      final existingRow = asm.constructionSCurve[cat] ?? {};
      for (final y in _years) {
        final pct = existingRow[y] ?? 0.0;
        _sCurveControllers[cat]![y] = TextEditingController(text: pct.toStringAsFixed(0));
      }
    }

    // Override notes
    _overrideNotesController = TextEditingController(text: asm.overrideNotes);
  }

  @override
  void dispose() {
    for (final c in _salesTrendControllers.values) {
      c.dispose();
    }
    _priceGrowthController.dispose();
    for (final c in _hardCostControllers.values) {
      c.dispose();
    }
    for (final row in _sCurveControllers.values) {
      for (final c in row.values) {
        c.dispose();
      }
    }
    _overrideNotesController.dispose();
    super.dispose();
  }

  double get _salesTrendTotal {
    double total = 0.0;
    for (final c in _salesTrendControllers.values) {
      total += double.tryParse(c.text) ?? 0.0;
    }
    return total;
  }

  double _sCurveRowTotal(String cat) {
    double total = 0.0;
    final row = _sCurveControllers[cat];
    if (row != null) {
      for (final c in row.values) {
        total += double.tryParse(c.text) ?? 0.0;
      }
    }
    return total;
  }

  void _saveAssumptions() {
    final isAr = context.read<LocaleCubit>().state == 'ar';

    // Parse sales trend
    final Map<int, double> sales = {};
    for (final entry in _salesTrendControllers.entries) {
      sales[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }

    // Parse hard cost rates
    final Map<String, double> rates = {};
    for (final entry in _hardCostControllers.entries) {
      rates[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }

    // Parse s-curve
    final Map<String, Map<int, double>> scurve = {};
    for (final catEntry in _sCurveControllers.entries) {
      scurve[catEntry.key] = {};
      for (final yearEntry in catEntry.value.entries) {
        scurve[catEntry.key]![yearEntry.key] = double.tryParse(yearEntry.value.text) ?? 0.0;
      }
    }

    final newAssumptions = ProjectAssumptions(
      salesTrend: sales,
      priceGrowthRate: double.tryParse(_priceGrowthController.text) ?? 12.0,
      hardCostUnitRates: rates,
      constructionSCurve: scurve,
      overrideNotes: _overrideNotesController.text,
    );

    final updatedStudy = _study.copyWith(
      assumptions: newAssumptions,
      status: ProjectStatus.evaluated,
    );

    context.read<ProjectsCubit>().addOrUpdateStudy(updatedStudy);

    AppSnackBar.showSuccess(
      context,
      message: isAr
          ? 'تم التحقق من الافتراضات وحفظها بنجاح'
          : 'Assumptions validated and saved successfully',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(study: updatedStudy),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';

    final salesTotal = _salesTrendTotal;
    final salesValid = (salesTotal - 100.0).abs() < 0.1;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ValuateLogo(height: 22, isDark: isDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAr ? 'التحقق من الافتراضات (خطوة 5)' : 'Validate Assumptions (Step 5)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveAssumptions,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.brandBlue),
            label: Text(
              isAr ? 'حفظ ومتابعة' : 'Proceed',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandBlue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isAr ? 'التحقق من افتراضات المشروع' : 'Validate Project Assumptions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _study.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? 'يبدأ النموذج بالمعايير السوقية. عدّل الافتراضات أدناه لتتوافق مع معطيات المشروع قبل مراجعة النتائج والتدفقات النقدية.'
                        : 'The model starts with market norms. Replace them below when project facts are available before reading outputs.',
                    style: const TextStyle(color: AppColors.brandLight, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 1. SALES TREND CARD
            _buildSectionCard(
              title: isAr ? '1. اتجاه المبيعات السنوي' : '1. Sales Trend Phasing',
              subtitle: isAr
                  ? 'توزيع نسبة المبيعات السنوية (يجب أن يكون الإجمالي 100%)'
                  : 'Allocate annual sales and confirm a 100% total',
              icon: Icons.trending_up_rounded,
              isDark: isDark,
              extraHeader: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: salesValid ? AppColors.success.withValues(alpha: 0.15) : AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: salesValid ? AppColors.success : AppColors.danger, width: 1),
                ),
                child: Text(
                  '${salesTotal.toStringAsFixed(0)}% / 100%',
                  style: TextStyle(
                    color: salesValid ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              child: Row(
                children: _years.map((y) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            y.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _salesTrendControllers[y],
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              suffixText: '%',
                              suffixStyle: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurface : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. PRICE GROWTH CARD
            _buildSectionCard(
              title: isAr ? '2. نمو الأسعار السنوي' : '2. Annual Price Growth',
              subtitle: isAr
                  ? 'نسبة الزيادة السنوية المتوقعة في الأسعار لكل منتج وسنة'
                  : 'Set the annual price escalation by product and year',
              icon: Icons.price_change_outlined,
              isDark: isDark,
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: isAr ? 'معدل الزيادة السنوية (%)' : 'Annual Escalation Rate (%)',
                      controller: _priceGrowthController,
                      keyboardType: TextInputType.number,
                      suffixText: '% / annum',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. HARD COST BUDGETS
            _buildSectionCard(
              title: isAr ? '3. تكاليف البناء المباشرة' : '3. Hard Cost Centres',
              subtitle: isAr
                  ? 'مراجعة معدلات التكلفة لكل مركز تكلفة بنائي'
                  : 'Review unit cost by cost centre',
              icon: Icons.construction_rounded,
              isDark: isDark,
              child: Column(
                children: _costCentres.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: Text(
                            _costCentreLabel(cat, isAr),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 9,
                          child: TextFormField(
                            controller: _hardCostControllers[cat],
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              suffixText: '${_study.currency}/m²',
                              suffixStyle: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurface : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. CONSTRUCTION S-CURVE
            _buildSectionCard(
              title: isAr ? '4. منحنى البناء' : '4. Construction S-Curve Phasing',
              subtitle: isAr
                  ? 'توزيع نسب الإنجاز السنوية لكل مركز تكلفة (كل صف = 100%)'
                  : 'Phase each cost centre. Every row totals 100%',
              icon: Icons.waterfall_chart_rounded,
              isDark: isDark,
              child: Column(
                children: _costCentres.map((cat) {
                  final rowTotal = _sCurveRowTotal(cat);
                  final rowValid = (rowTotal - 100.0).abs() < 0.1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : AppColors.lightSurfaceHover,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rowValid ? Colors.transparent : AppColors.danger.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _costCentreLabel(cat, isAr),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${rowTotal.toStringAsFixed(0)}% / 100%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: rowValid ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _years.map((y) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: TextFormField(
                                  controller: _sCurveControllers[cat]?[y],
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: y.toString(),
                                    labelStyle: TextStyle(
                                      fontSize: 9.5,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                    suffixText: '%',
                                    suffixStyle: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                                    filled: true,
                                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 5. OVERRIDE RULE CARD
            _buildSectionCard(
              title: isAr ? '5. سجل التعديلات وقواعد الاستثناء' : '5. Override Rule Audit',
              subtitle: isAr
                  ? 'تسجيل مصدر وتاريخ وسبب أي تعديل أو استثناء في الافتراضات'
                  : 'Record the source, date and reason for every changed assumption',
              icon: Icons.history_edu_rounded,
              isDark: isDark,
              child: CustomTextField(
                label: isAr ? 'ملاحظات وسند التعديل' : 'Audit notes and reference',
                controller: _overrideNotesController,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            PrimaryButton(
              text: isAr ? 'حفظ الافتراضات والانتقال لمراجعة التدفقات النقدية' : 'Save & Review Cash Flows (Step 6 & 7)',
              icon: Icons.arrow_forward_rounded,
              backgroundColor: AppColors.brandBlue,
              onPressed: _saveAssumptions,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Widget child,
    Widget? extraHeader,
  }) {
    return Container(
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
            children: [
              Icon(icon, size: 20, color: AppColors.brandBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
              ?extraHeader,
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
