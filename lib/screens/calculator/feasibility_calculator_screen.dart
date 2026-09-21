import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/calculator/calculator_cubit.dart';
import '../../cubits/calculator/calculator_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/charts/cashflow_bar_chart.dart';
import '../../widgets/charts/cost_breakdown_pie.dart';
import '../../widgets/charts/scenario_comparison_chart.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialogs/voice_feasibility_input_dialog.dart';
import '../../widgets/kpi_metric_tile.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/verdict_badge.dart';

class FeasibilityCalculatorScreen extends StatefulWidget {
  const FeasibilityCalculatorScreen({super.key});

  @override
  State<FeasibilityCalculatorScreen> createState() =>
      _FeasibilityCalculatorScreenState();
}

class _FeasibilityCalculatorScreenState
    extends State<FeasibilityCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _assetTypes = const [
    'Residential',
    'Commercial',
    'MixedUse',
    'Hospitality',
    'Industrial',
  ];

  final List<String> _locations = const [
    'Riyadh, Saudi Arabia',
    'Dubai, UAE',
    'Jeddah, Saudi Arabia',
    'Cairo, Egypt',
    'Abu Dhabi, UAE',
    'Doha, Qatar',
    'Kuwait City, Kuwait',
  ];

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
          AppStrings.get('feasibilityCalculator', locale: locale),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.gold),
            tooltip: locale == 'ar' ? 'إدخال صوتي بالذكاء الاصطناعي' : 'AI Voice Smart Fill',
            onPressed: () {
              VoiceFeasibilityInputDialog.show(
                context,
                locale: locale,
                isDark: isDark,
                onStudyParsed: (parsedStudy, transcript) {
                  context.read<CalculatorCubit>().loadStudy(
                        parsedStudy,
                        voiceTranscript: transcript,
                      );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset to default model',
            onPressed: () {
              context.read<CalculatorCubit>().resetToDefaults();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFE8E5DF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF2C3960), Color(0xFF1E2848)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isDark ? null : Colors.white,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: isDark ? 0.6 : 0.5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.gold.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppColors.gold,
              unselectedLabelColor:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune_rounded, size: 16),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          locale == 'ar' ? 'المدخلات' : 'Inputs & Data',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assessment_outlined, size: 16),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          locale == 'ar' ? 'المؤشرات' : 'KPIs & Verdict',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.insights_rounded, size: 16),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          locale == 'ar' ? 'التحليلات' : 'Analytics',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<CalculatorCubit, CalculatorState>(
        builder: (context, state) {
          final study = state.activeStudy;

          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Inputs
              _buildInputsTab(context, study, isDark, locale),

              // TAB 2: KPIs & Verdict
              _buildKpisTab(context, study, isDark, locale),

              // TAB 3: Analytics & Charts
              _buildAnalyticsTab(context, study, isDark, locale),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputsTab(
    BuildContext context,
    FeasibilityStudy study,
    bool isDark,
    String locale,
  ) {
    final cubit = context.read<CalculatorCubit>();
    final voiceTranscript = context.watch<CalculatorCubit>().state.voiceTranscript;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Voice Transcript Speech Note Bubble (shows what user said!)
          if (voiceTranscript != null && voiceTranscript.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2D54), const Color(0xFF162242)]
                      : [const Color(0xFFF9F7F1), const Color(0xFFF0EBE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: isDark ? 0.6 : 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: isDark ? 0.15 : 0.1),
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
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.record_voice_over_rounded, color: AppColors.gold, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        locale == 'ar' ? 'النص الصوتي المفرّغ بالذكاء الاصطناعي:' : 'Transcribed Voice Input:',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.gold),
                        tooltip: locale == 'ar' ? 'تعديل أو إعادة تسجيل' : 'Re-record / Edit',
                        onPressed: () {
                          VoiceFeasibilityInputDialog.show(
                            context,
                            locale: locale,
                            isDark: isDark,
                            onStudyParsed: (parsedStudy, transcript) {
                              cubit.loadStudy(parsedStudy, voiceTranscript: transcript);
                            },
                          );
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                        ),
                        tooltip: locale == 'ar' ? 'إخفاء' : 'Dismiss',
                        onPressed: () => cubit.clearVoiceTranscript(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF10172D) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
                      ),
                    ),
                    child: Text(
                      '“$voiceTranscript”',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        height: 1.45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // AI Voice Smart Input Banner
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B2446), const Color(0xFF131A32)]
                    : [const Color(0xFFFDFBF7), const Color(0xFFF4EFE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: isDark ? 0.45 : 0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: isDark ? 0.1 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  VoiceFeasibilityInputDialog.show(
                    context,
                    locale: locale,
                    isDark: isDark,
                    onStudyParsed: (parsedStudy, transcript) {
                      cubit.loadStudy(parsedStudy, voiceTranscript: transcript);
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryBlue, Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  locale == 'ar' ? 'إدخال صوتي بالذكاء الاصطناعي' : 'AI Voice Smart Fill',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'AI NLP',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              locale == 'ar'
                                  ? 'سجل صوتياً بيانات المشروع ليتم تعبئة الحقول والـ Sliders تلقائياً'
                                  : 'Speak project details to auto-fill all fields and sliders',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.gold.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Project Definition Card
          _buildCard(
            title: AppStrings.get('projectDetails', locale: locale),
            icon: Icons.apartment_rounded,
            isDark: isDark,
            children: [
              CustomTextField(
                key: ValueKey('${study.id}_${study.title}'),
                label: AppStrings.get('projectName', locale: locale),
                hintText: 'Enter project name',
                initialValue: study.title,
                onChanged: (v) => cubit.updateTitle(v),
              ),
              const SizedBox(height: 14),
              // Asset Type Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('projectType', locale: locale),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _assetTypes.contains(study.assetType)
                            ? study.assetType
                            : _assetTypes.first,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        items: _assetTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              AppStrings.get(type.toLowerCase(), locale: locale),
                              style: TextStyle(
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) cubit.updateAssetType(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Location Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('location', locale: locale),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _locations.contains(study.location)
                            ? study.location
                            : _locations.first,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        items: _locations.map((loc) {
                          return DropdownMenuItem(
                            value: loc,
                            child: Text(
                              loc,
                              style: TextStyle(
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) cubit.updateLocation(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Area & FAR Specs Card
          _buildCard(
            title: locale == 'ar' ? 'المساحات ومعامل البناء' : 'Plot & Area Specifications',
            icon: Icons.square_foot_rounded,
            isDark: isDark,
            children: [
              _buildSliderInput(
                label: AppStrings.get('landArea', locale: locale),
                value: study.landArea,
                unit: 'm²',
                min: 500,
                max: 50000,
                divisions: 99,
                isDark: isDark,
                onChanged: (v) => cubit.updateLandArea(v),
              ),
              const Divider(height: 24),
              _buildSliderInput(
                label: AppStrings.get('far', locale: locale),
                value: study.far,
                unit: 'x',
                min: 0.5,
                max: 8.0,
                divisions: 75,
                isDark: isDark,
                onChanged: (v) => cubit.updateFar(v),
              ),
              const Divider(height: 24),
              _buildSliderInput(
                label: locale == 'ar' ? 'كفاءة المساحة القابلة للبيع (%)' : 'GFA Efficiency (%)',
                value: study.efficiencyPct,
                unit: '%',
                min: 60,
                max: 95,
                divisions: 35,
                isDark: isDark,
                onChanged: (v) => cubit.updateEfficiencyPct(v),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgGrid : AppColors.lightBgGrid.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [


                    Flexible(
                      
                      child: Text(
                        '${AppStrings.get('bua', locale: locale)}: ${study.bua.toStringAsFixed(0)} m²',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${AppStrings.get('gfa', locale: locale)}: ${study.gfa.toStringAsFixed(0)} m²',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Cost & Revenue Assumptions Card
          _buildCard(
            title: locale == 'ar' ? 'التكاليف والإيرادات' : 'Cost & Revenue Parameters',
            icon: Icons.monetization_on_outlined,
            isDark: isDark,
            children: [
              _buildSliderInput(
                label: AppStrings.get('landCost', locale: locale),
                value: study.landCost,
                unit: study.currency,
                min: 1000000,
                max: 100000000,
                divisions: 99,
                isDark: isDark,
                isCurrency: true,
                onChanged: (v) => cubit.updateLandCost(v),
              ),
              const Divider(height: 24),
              _buildSliderInput(
                label: AppStrings.get('constructionCostPerSqm', locale: locale),
                value: study.constructionCostPerSqm,
                unit: '${study.currency}/m²',
                min: 1500,
                max: 12000,
                divisions: 105,
                isDark: isDark,
                onChanged: (v) => cubit.updateConstructionCostPerSqm(v),
              ),
              const Divider(height: 24),
              _buildSliderInput(
                label: AppStrings.get('expectedRevenuePerSqm', locale: locale),
                value: study.expectedRevenuePerSqm,
                unit: '${study.currency}/m²',
                min: 3000,
                max: 35000,
                divisions: 64,
                isDark: isDark,
                onChanged: (v) => cubit.updateExpectedRevenuePerSqm(v),
              ),
              const Divider(height: 24),
              _buildSliderInput(
                label: AppStrings.get('developmentPeriodMonths', locale: locale),
                value: study.developmentMonths.toDouble(),
                unit: locale == 'ar' ? 'شهر' : 'Months',
                min: 6,
                max: 60,
                divisions: 54,
                isDark: isDark,
                onChanged: (v) => cubit.updateDevelopmentMonths(v.toInt()),
              ),
            ],
          ),
          const SizedBox(height: 20),

          PrimaryButton(
            text: locale == 'ar' ? 'عرض النتائج والجدوى' : 'View Feasibility Results',
            onPressed: () {
              _tabController.animateTo(1);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildKpisTab(
    BuildContext context,
    FeasibilityStudy study,
    bool isDark,
    String locale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verdict Card
          FadeSlideEntrance(
            duration: const Duration(milliseconds: 400),
            child: VerdictBadge(
              verdict: study.verdict,
              score: study.feasibilityScore,
              locale: locale,
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 18),

          // Primary Financial Returns Grid
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 450),
            child: IntrinsicHeight(
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
          ),
          const SizedBox(height: 12),
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 180),
            duration: const Duration(milliseconds: 450),
            child: IntrinsicHeight(
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
          ),
          const SizedBox(height: 12),
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 260),
            duration: const Duration(milliseconds: 450),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: KpiMetricTile(
                      label: AppStrings.get('totalDevelopmentCost', locale: locale),
                      value: KpiMetricTile.formatCurrency(study.totalDevelopmentCost, currency: study.currency),
                      icon: Icons.build_circle_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiMetricTile(
                      label: AppStrings.get('grossRevenue', locale: locale),
                      value: KpiMetricTile.formatCurrency(study.grossRevenue, currency: study.currency),
                      icon: Icons.savings_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Breakeven & Efficiency Summary
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 340),
            duration: const Duration(milliseconds: 450),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    label: AppStrings.get('breakeven', locale: locale),
                    value: '${study.breakevenPerSqm.toStringAsFixed(0)} ${study.currency}/m²',
                    isDark: isDark,
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _summaryRow(
                    label: AppStrings.get('profitMargin', locale: locale),
                    value: '${study.marginOnCostPct.toStringAsFixed(1)}%',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _summaryRow(
                    label: AppStrings.get('developmentPeriodMonths', locale: locale),
                    value: '${study.developmentMonths} ${locale == 'ar' ? 'شهر' : 'Months'}',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save Study Button
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 420),
            duration: const Duration(milliseconds: 400),
            child: PrimaryButton(
              text: AppStrings.get('saveProject', locale: locale),
              icon: Icons.bookmark_add_outlined,
              backgroundColor: AppColors.primaryBlue,
              onPressed: () {
                context.read<ProjectsCubit>().addOrUpdateStudy(study);
                AppSnackBar.showSuccess(
                  context,
                  message: AppStrings.get('studySavedSuccess', locale: locale),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(
    BuildContext context,
    FeasibilityStudy study,
    bool isDark,
    String locale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cost Composition Card
          FadeSlideEntrance(
            duration: const Duration(milliseconds: 450),
            child: _buildCard(
              title: AppStrings.get('costBreakdown', locale: locale),
              icon: Icons.donut_large_rounded,
              isDark: isDark,
              children: [
                CostBreakdownPie(study: study, locale: locale),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Cash Flow Phasing Card
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 450),
            child: _buildCard(
              title: AppStrings.get('cashFlowProjection', locale: locale),
              icon: Icons.bar_chart_rounded,
              isDark: isDark,
              children: [
                CashflowBarChart(study: study, locale: locale),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Sensitivity Scenarios Card
          FadeSlideEntrance(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 450),
            child: _buildCard(
              title: AppStrings.get('scenarioAnalysis', locale: locale),
              icon: Icons.compare_arrows_rounded,
              isDark: isDark,
              children: [
                ScenarioComparisonChart(study: study, locale: locale),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
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

  Widget _buildSliderInput({
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required int divisions,
    required bool isDark,
    bool isCurrency = false,
    required ValueChanged<double> onChanged,
  }) {
    final displayValue = isCurrency
        ? KpiMetricTile.formatCurrency(value, currency: unit)
        : '${value is int ? value : value.toStringAsFixed(value < 10 ? 1 : 0)} $unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primaryBlue,
            inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            thumbColor: AppColors.gold,
            overlayColor: AppColors.gold.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required bool isDark,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
