import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialogs/location_map_picker_dialog.dart';
import '../../widgets/primary_button.dart';
import '../projects/project_metrics_screen.dart';

class _SectorDateControllers {
  final TextEditingController salesStart;
  final TextEditingController salesEnd;
  final TextEditingController constStart;
  final TextEditingController constEnd;

  _SectorDateControllers({
    String salesStartYear = '2026',
    String salesEndYear = '2029',
    String constStartYear = '2026',
    String constEndYear = '2028',
  })  : salesStart = TextEditingController(text: kDebugMode ? salesStartYear : null),
        salesEnd = TextEditingController(text: kDebugMode ? salesEndYear : null),
        constStart = TextEditingController(text: kDebugMode ? constStartYear : null),
        constEnd = TextEditingController(text: kDebugMode ? constEndYear : null);

  void dispose() {
    salesStart.dispose();
    salesEnd.dispose();
    constStart.dispose();
    constEnd.dispose();
  }
}

class CreateProjectWizardScreen extends StatefulWidget {
  const CreateProjectWizardScreen({super.key});

  @override
  State<CreateProjectWizardScreen> createState() =>
      _CreateProjectWizardScreenState();
}

class _CreateProjectWizardScreenState extends State<CreateProjectWizardScreen> {
  int _currentStep = 1; // Step 1: Basic info & Location, Step 2: Sector Dates & Land Details

  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController(text: kDebugMode ? 'مشروع برج الأندلس' : null);
  final _developerNameController = TextEditingController();
  final _locationController = TextEditingController(text: kDebugMode ? 'الرياض - حي النرجس' : null);
  final _landAreaController = TextEditingController(text: kDebugMode ? '5000' : null);
  final _landCostController = TextEditingController(text: kDebugMode ? '15000000' : null);
  final _landPricePerSqmController = TextEditingController(text: kDebugMode ? '3000' : null);
  final _landPaymentYearsController = TextEditingController(text: kDebugMode ? '0' : null);
  final _constructionCostController = TextEditingController(text: kDebugMode ? '4200' : null);
  final _expectedRevenueController = TextEditingController(text: kDebugMode ? '9800' : null);
  final _farController = TextEditingController(text: kDebugMode ? '2.5' : null);
  final _efficiencyController = TextEditingController(text: kDebugMode ? '85' : null);
  final _revenueSharePctController = TextEditingController(text: kDebugMode ? '15' : null);
  final _inKindSharePctController = TextEditingController(text: kDebugMode ? '20' : null);

  // Selected Sectors (Multi-select)
  final List<String> _mainSectors = const ['سكني', 'تجاري', 'ضيافة'];
  final Set<String> _selectedSectors = kDebugMode ? {'سكني'} : {};
  final Map<String, _SectorDateControllers> _sectorControllers = {};
  final Map<String, TextEditingController> _sectorPercentageControllers = {};

  String _selectedType = kDebugMode ? 'On Plan Sales' : '';
  String _selectedCountry = kDebugMode ? 'المملكة العربية السعودية' : '';
  String _selectedCity = kDebugMode ? 'الرياض' : '';
  final Set<String> _selectedLandPaymentModes = kDebugMode ? {'دفع ثمن الأرض'} : {};
  String? _mapGisPoint = kDebugMode ? '24.8423, 46.6631' : '';

  final List<String> _typesList = const [
    'On Plan Sales',
    'Off Plan Sales',
    'Percentage Of Completion',
  ];

  final List<String> _countriesAr = const [
    'المملكة العربية السعودية',
    'الإمارات العربية المتحدة',
    'جمهورية مصر العربية',
    'دولة قطر',
    'دولة الكويت',
    'مملكة البحرين',
    'سلطنة عمان',
  ];

  final List<String> _paymentModes = const [
    'حصة عينية',
    'حصة الإيرادات',
    'دفع ثمن الأرض',
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final defaultDevName = authState is Authenticated
        ? authState.user.fullName
        : (kDebugMode ? 'mohamed hany' : '');
    _developerNameController.text = defaultDevName;

    // Initialize controllers for sectors
    for (final s in _mainSectors) {
      _sectorControllers[s] = _SectorDateControllers();
    }
    if (kDebugMode) {
      _sectorPercentageControllers['سكني'] = TextEditingController(text: '100');
    }
  }

  @override
  void dispose() {

    _projectNameController.dispose();
    _developerNameController.dispose();
    _locationController.dispose();
    _landAreaController.dispose();
    _landCostController.dispose();
    _landPricePerSqmController.dispose();
    _landPaymentYearsController.dispose();
    _constructionCostController.dispose();
    _expectedRevenueController.dispose();
    _farController.dispose();
    _efficiencyController.dispose();
    _revenueSharePctController.dispose();
    _inKindSharePctController.dispose();

    for (final c in _sectorControllers.values) {
      c.dispose();
    }
    for (final c in _sectorPercentageControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double get _totalSectorPercentage {
    double sum = 0.0;
    for (final s in _selectedSectors) {
      final ctrl = _sectorPercentageControllers[s];
      if (ctrl != null) {
        sum += double.tryParse(ctrl.text.trim()) ?? 0.0;
      }
    }
    return sum;
  }

  void _onToggleSector(String sector) {
    setState(() {
      if (_selectedSectors.contains(sector)) {
        _selectedSectors.remove(sector);
        _sectorControllers[sector]?.dispose();
        _sectorControllers.remove(sector);
      } else {
        _selectedSectors.add(sector);
        _sectorControllers[sector] = _SectorDateControllers();
        if (!_sectorPercentageControllers.containsKey(sector)) {
          final defaultPct = _selectedSectors.length == 1 ? '100' : '0';
          _sectorPercentageControllers[sector] = TextEditingController(text: defaultPct);
        } else if (_selectedSectors.length == 1) {
          _sectorPercentageControllers[sector]?.text = '100';
        }
      }
    });
  }

  void _onToggleLandPaymentMode(String mode) {
    setState(() {
      if (_selectedLandPaymentModes.contains(mode)) {
        _selectedLandPaymentModes.remove(mode);
      } else {
        _selectedLandPaymentModes.add(mode);
      }
    });
  }

  _SectorDateControllers _getControllersFor(String sector) {
    if (!_sectorControllers.containsKey(sector)) {
      _sectorControllers[sector] = _SectorDateControllers();
    }
    return _sectorControllers[sector]!;
  }

  void _pickMapLocation(bool isDark, String locale) async {
    final result = await LocationMapPickerDialog.show(
      context,
      currentCountry: _selectedCountry,
      currentLocation: _locationController.text,
      isDark: isDark,
      locale: locale,
    );

    if (result != null) {
      setState(() {
        _locationController.text = locale == 'ar' ? result.nameAr : result.nameEn;
        _selectedCountry = locale == 'ar' ? result.countryAr : result.countryEn;
        _selectedCity = locale == 'ar' ? result.cityAr : result.cityEn;
        _mapGisPoint = '${result.lat}, ${result.lng}';
      });
    }
  }

  void _saveProject() {
    if (_formKey.currentState?.validate() ?? false) {
      final locale = context.read<LocaleCubit>().state;
      final isAr = locale == 'ar';

      if (_selectedLandPaymentModes.isEmpty) {
        AppSnackBar.showError(
          context,
          message: isAr
              ? 'يرجى اختيار طريقة دفع واحدة على الأقل للأرض'
              : 'Please select at least one land payment structure',
        );
        return;
      }

      final landArea = double.tryParse(_landAreaController.text) ?? 5000.0;
      final landCost = double.tryParse(_landCostController.text) ?? 15000000.0;
      final constCost = double.tryParse(_constructionCostController.text) ?? 4200.0;
      final revenue = double.tryParse(_expectedRevenueController.text) ?? 9800.0;
      final far = double.tryParse(_farController.text) ?? 2.5;
      final efficiency = double.tryParse(_efficiencyController.text) ?? 85.0;

      // Build sector timelines
      final List<SectorTimeline> timelines = [];
      int minConstYear = 2026;
      int maxConstYear = 2028;

      for (final s in _selectedSectors) {
        final ctrl = _getControllersFor(s);
        final sStart = int.tryParse(ctrl.salesStart.text) ?? 2026;
        final sEnd = int.tryParse(ctrl.salesEnd.text) ?? 2029;
        final cStart = int.tryParse(ctrl.constStart.text) ?? 2026;
        final cEnd = int.tryParse(ctrl.constEnd.text) ?? 2028;

        if (cStart < minConstYear) minConstYear = cStart;
        if (cEnd > maxConstYear) maxConstYear = cEnd;

        timelines.add(SectorTimeline(
          sector: s,
          salesStartYear: sStart,
          salesEndYear: sEnd,
          constructionStartYear: cStart,
          constructionEndYear: cEnd,
        ));
      }

      final months = ((maxConstYear - minConstYear + 1) * 12).clamp(12, 60);

      String currency = 'SAR';
      if (_selectedCountry.contains('الإمارات') || _selectedCountry.contains('Emirates')) {
        currency = 'AED';
      } else if (_selectedCountry.contains('مصر') || _selectedCountry.contains('Egypt')) {
        currency = 'EGP';
      } else if (_selectedCountry.contains('قطر') || _selectedCountry.contains('Qatar')) {
        currency = 'QAR';
      } else if (_selectedCountry.contains('الكويت') || _selectedCountry.contains('Kuwait')) {
        currency = 'KWD';
      } else if (_selectedCountry.contains('البحرين') || _selectedCountry.contains('Bahrain')) {
        currency = 'BHD';
      } else if (_selectedCountry.contains('عمان') || _selectedCountry.contains('Oman')) {
        currency = 'OMR';
      }

      final Map<String, double> percentages = {};
      for (final s in _selectedSectors) {
        percentages[s] = double.tryParse(_sectorPercentageControllers[s]?.text.trim() ?? '') ?? 0.0;
      }

      final study = FeasibilityStudy(
        id: 'prj_${DateTime.now().millisecondsSinceEpoch}',
        title: _projectNameController.text.trim().isNotEmpty
            ? _projectNameController.text.trim()
            : (kDebugMode ? 'مشروع برج الأندلس' : 'مشروع عقاري جديد'),
        developerName: _developerNameController.text.trim().isNotEmpty
            ? _developerNameController.text.trim()
            : (kDebugMode ? 'mohamed hany' : ''),
        assetType: _selectedSectors.isNotEmpty ? _selectedSectors.first : 'سكني',
        selectedSectors: _selectedSectors.toList(),
        sectorPercentages: percentages,
        sectorTimelines: timelines,
        projectType: _selectedType,
        country: _selectedCountry,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : '$_selectedCity, $_selectedCountry',
        mapLocation: _mapGisPoint,
        landPaymentMode: _selectedLandPaymentModes.join(' + '),
        landPaymentModes: _selectedLandPaymentModes.toList(),
        revenueSharePct: _selectedLandPaymentModes.contains('حصة الإيرادات')
            ? (double.tryParse(_revenueSharePctController.text) ?? 0.0)
            : 0.0,
        inKindSharePct: _selectedLandPaymentModes.contains('حصة عينية')
            ? (double.tryParse(_inKindSharePctController.text) ?? 0.0)
            : 0.0,
        landArea: landArea,
        far: far,
        efficiencyPct: efficiency,
        landCost: _selectedLandPaymentModes.contains('دفع ثمن الأرض') ? landCost : 0.0,
        landPricePerSqm: _selectedLandPaymentModes.contains('دفع ثمن الأرض')
            ? double.tryParse(_landPricePerSqmController.text)
            : null,
        landPaymentYears: _selectedLandPaymentModes.contains('دفع ثمن الأرض')
            ? (int.tryParse(_landPaymentYearsController.text) ?? 0)
            : 0,
        constructionCostPerSqm: constCost,
        expectedRevenuePerSqm: revenue,
        developmentMonths: months,
        currency: currency,
      );

      context.read<ProjectsCubit>().addOrUpdateStudy(study);

      AppSnackBar.showSuccess(
        context,
        message: AppStrings.get('studySavedSuccess', locale: context.read<LocaleCubit>().state),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectMetricsScreen(study: study),
        ),
      );
    }
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
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAr ? 'إنشاء مشروع' : 'Create Project',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  isAr ? 'AR' : 'EN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Wizard Banner & 2-Step Progress Indicator
              _buildWizardHeader(isDark, isAr),
              const SizedBox(height: 20),

              // Step Form Content
              _currentStep == 1
                  ? _buildStep1(isDark, isAr)
                  : _buildStep2(isDark, isAr),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: Row(
          children: [
            if (_currentStep == 2)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAr ? 'السابق' : 'Previous',
                        style: TextStyle(
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentStep == 2) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: _currentStep == 1
                    ? (isAr ? 'التالي' : 'Next')
                    : (isAr ? 'حفظ وتأكيد المشروع' : 'Save & Create Project'),
                icon: _currentStep == 2 ? Icons.check_circle_outline_rounded : null,
                onPressed: () {
                  if (_currentStep == 1) {
                    if (_projectNameController.text.trim().isEmpty) {
                      AppSnackBar.showError(
                        context,
                        message: isAr ? 'يرجى إدخال اسم المشروع أولاً' : 'Please enter project name',
                      );
                      return;
                    }

                    if (_selectedSectors.isEmpty) {
                      AppSnackBar.showError(
                        context,
                        message: isAr ? 'يرجى اختيار قطاع واحد على الأقل للمشروع' : 'Please select at least one sector',
                      );
                      return;
                    }

                    for (final s in _selectedSectors) {
                      final pct = double.tryParse(_sectorPercentageControllers[s]?.text.trim() ?? '') ?? 0.0;
                      if (pct <= 0) {
                        AppSnackBar.showError(
                          context,
                          message: isAr
                              ? 'يرجى إدخال نسبة صحيحة لقطاع $s أكبر من 0%'
                              : 'Please enter a valid percentage > 0% for sector $s',
                        );
                        return;
                      }
                    }

                    final totalPct = _totalSectorPercentage;
                    if ((totalPct - 100.0).abs() > 0.01) {
                      AppSnackBar.showError(
                        context,
                        message: isAr
                            ? 'مجموع نسب القطاعات المختارة يجب أن يساوي 100% (المجموع الحالي: ${totalPct.toStringAsFixed(totalPct.truncateToDouble() == totalPct ? 0 : 1)}%)'
                            : 'Total sector percentages must equal 100% (Current: ${totalPct.toStringAsFixed(totalPct.truncateToDouble() == totalPct ? 0 : 1)}%)',
                      );
                      return;
                    }

                    setState(() {
                      _currentStep = 2;
                    });
                  } else {
                    _saveProject();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardHeader(bool isDark, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle Title & Description
        Text(
          _currentStep == 1
              ? (isAr
                  ? 'إنشاء مشروع - الخطوة 1 من 2'
                  : 'Create Project - Step 1 of 2')
              : (isAr
                  ? 'إنشاء مشروع - الخطوة 2 من 2'
                  : 'Create Project - Step 2 of 2'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _currentStep == 1
              ? (isAr
                  ? 'تفاصيل المشروع الأساسية، بما في ذلك الاسم والموقع والنوع لتوفير نظرة شاملة عن نطاق المشروع وأهدافه.'
                  : 'Basic project details, including name, location, and type to provide a comprehensive overview of project scope and objectives.')
              : (isAr
                  ? 'الإطار الزمني وتواريخ القطاعات، وتفاصيل هيكل الأرض لحساب التدفقات والعوائد بدقة.'
                  : 'Timeline schedule, sector milestones, and land structure details for accurate cash flow modeling.'),
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 16),

        // 2-Step Pill Indicator Bar
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep >= 1 ? AppColors.primaryBlue : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep == 2 ? AppColors.primaryBlue : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep1(bool isDark, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Initial Information
        _sectionTitle(isAr ? 'المعلومات الأولية' : 'Initial Information', isDark),
        const SizedBox(height: 14),

        // Project Name
        _fieldLabel(isAr ? 'اسم المشروع *' : 'Project Name *', isDark),
        const SizedBox(height: 6),
        CustomTextField(
          controller: _projectNameController,
          hintText: isAr ? 'أدخل اسم المشروع' : 'Enter project name',
          prefixIcon: const Icon(Icons.apartment_rounded, size: 20, color: AppColors.gold),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? (isAr ? 'اسم المشروع مطلوب' : 'Project name is required')
              : null,
        ),
        const SizedBox(height: 14),

        // Developer Name
        _fieldLabel(isAr ? 'اسم المطور *' : 'Developer Name *', isDark),
        const SizedBox(height: 6),
        CustomTextField(
          controller: _developerNameController,
          hintText: isAr ? 'أدخل اسم المطور' : 'Enter developer name',
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.gold),
        ),
        const SizedBox(height: 14),

        // Project Sectors (Multi-select)
        _fieldLabel(isAr ? 'قطاعات المشروع *' : 'Project Sectors *', isDark),
        const SizedBox(height: 8),

        // 3 Sector Pills Row
        Row(
          children: _mainSectors.map((s) {
            final isSel = _selectedSectors.contains(s);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _onToggleSector(s),
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel
                          ? Colors.white
                          : (isDark ? const Color(0xFF131A31) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSel
                            ? Colors.white
                            : (isDark ? Colors.white24 : AppColors.lightBorder),
                        width: 1,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      s,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        color: isSel
                            ? const Color(0xFF0F1426)
                            : (isDark ? Colors.white70 : AppColors.lightText),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Dynamic Sector Percentage Inputs for selected sectors
        if (_selectedSectors.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _selectedSectors.map((s) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '$s - ${isAr ? 'النسبة' : 'Percentage'}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _sectorPercentageControllers[s],
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.gold : AppColors.brandNavy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Total Percentage Badge
          Builder(
            builder: (context) {
              final total = _totalSectorPercentage;
              final isValid = (total - 100.0).abs() < 0.01;
              return Align(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isValid
                        ? (isDark ? AppColors.success.withValues(alpha: 0.15) : const Color(0xFFE8F5E9))
                        : (isDark ? AppColors.danger.withValues(alpha: 0.15) : const Color(0xFFFFEBEE)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isValid ? AppColors.success : AppColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isValid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        size: 15,
                        color: isValid ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAr
                            ? 'المجموع الكلي للقطاعات: ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1)}% / 100%'
                            : 'Total Sectors: ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1)}% / 100%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isValid
                              ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32))
                              : (isDark ? const Color(0xFFF87171) : const Color(0xFFC62828)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
        ],

        // Type
        _fieldLabel(isAr ? 'النوع *' : 'Type *', isDark),
        const SizedBox(height: 6),
        _buildDropdownSelector(
          value: _selectedType,
          items: _typesList,
          hint: isAr ? 'اختر النوع' : 'Select type',
          isDark: isDark,
          onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
        ),
        const SizedBox(height: 14),

        // Land Area
        _fieldLabel(isAr ? 'مساحة الأرض *' : 'Land Area *', isDark),
        const SizedBox(height: 6),
        CustomTextField(
          controller: _landAreaController,
          hintText: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              'm²',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? (isAr ? 'مساحة الأرض مطلوبة' : 'Land area is required')
              : null,
        ),
        const SizedBox(height: 24),

        // Section: Project Location
        _sectionTitle(isAr ? 'موقع المشروع' : 'Project Location', isDark),
        const SizedBox(height: 14),

        // Country
        _fieldLabel(isAr ? 'البلد *' : 'Country *', isDark),
        const SizedBox(height: 6),
        _buildDropdownSelector(
          value: _selectedCountry,
          items: _countriesAr,
          prefixIcon: Icons.language_rounded,
          hint: isAr ? 'يرجى اختيار خيار' : 'Please select an option',
          isDark: isDark,
          onChanged: (v) => setState(() => _selectedCountry = v ?? _selectedCountry),
        ),
        const SizedBox(height: 14),

        // Location / Map
        _fieldLabel(isAr ? 'الموقع *' : 'Location *', isDark),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                      style: TextStyle(
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: isAr ? 'انقر لتحديد الموقع على الخريطة' : 'Click to select location on map',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        foregroundColor: isDark ? Colors.white : AppColors.brandNavy,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 16, color: AppColors.gold),
                      label: Text(
                        isAr ? 'اختر علي الخريطه' : 'Choose on map',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _pickMapLocation(isDark, isAr ? 'ar' : 'en'),
                    ),
                  ),
                ],
              ),
              if (_mapGisPoint != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
                  child: Text(
                    isAr ? 'الإحداثيات: $_mapGisPoint' : 'Coordinates: $_mapGisPoint',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Section Header: Timeline
        _sectionTitle(isAr ? 'الإطار الزمني' : 'Sector Timeline', isDark),
        const SizedBox(height: 16),

        // Dynamic Sector Timeline Cards for EACH selected sector
        ..._selectedSectors.map((sector) => _buildSectorTimelineCard(sector, isDark, isAr)),

        const SizedBox(height: 24),

        // Section: Land Details (تفاصيل الأرض)
        _sectionTitle(isAr ? 'تفاصيل الأرض' : 'Land Details', isDark),
        const SizedBox(height: 12),

        // Land Payment Structure Pills (حصة عينية, حصة الإيرادات, دفع ثمن الأرض)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _paymentModes.map((mode) {
            final isSel = _selectedLandPaymentModes.contains(mode);
            return InkWell(
              onTap: () => _onToggleLandPaymentMode(mode),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel
                      ? Colors.white
                      : (isDark ? const Color(0xFF131A31) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSel
                        ? Colors.white
                        : (isDark ? Colors.white24 : AppColors.lightBorder),
                    width: 1,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  mode,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    color: isSel
                        ? const Color(0xFF0F1426)
                        : (isDark ? Colors.white70 : AppColors.lightText),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Dynamic Fields based on Selected Land Payment Modes
        if (_selectedLandPaymentModes.contains('دفع ثمن الأرض')) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field 1 (Right in RTL / First): تكلفة الأرض
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isAr ? 'تكلفة الأرض' : 'Land Cost', isDark),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _landCostController,
                      hintText: isAr ? 'أدخل تكلفة الأرض' : 'Enter land cost',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        final total = double.tryParse(val);
                        final area = double.tryParse(_landAreaController.text) ?? 5000.0;
                        if (total != null && area > 0) {
                          final sqmPrice = (total / area).toStringAsFixed(0);
                          _landPricePerSqmController.text = sqmPrice;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Field 2 (Middle): سعر المتر
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isAr ? 'سعر المتر' : 'Price / m²', isDark),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _landPricePerSqmController,
                      hintText: isAr ? 'أدخل سعر متر الأرض' : 'Enter price per sqm',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        final sqmPrice = double.tryParse(val);
                        final area = double.tryParse(_landAreaController.text) ?? 5000.0;
                        if (sqmPrice != null) {
                          final total = (sqmPrice * area).toStringAsFixed(0);
                          _landCostController.text = total;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Field 3 (Left in RTL): عدد السنوات
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isAr ? 'عدد السنوات' : 'Years', isDark),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _landPaymentYearsController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

        if (_selectedLandPaymentModes.contains('دفع ثمن الأرض') &&
            (_selectedLandPaymentModes.contains('حصة الإيرادات') ||
             _selectedLandPaymentModes.contains('حصة عينية')))
          const SizedBox(height: 14),

        if (_selectedLandPaymentModes.contains('حصة الإيرادات') &&
            _selectedLandPaymentModes.contains('حصة عينية')) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isAr ? '% من إجمالي الإيرادات' : '% of Gross Revenue', isDark),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _revenueSharePctController,
                      hintText: isAr ? 'أدخل نسبة الإيرادات' : 'Enter revenue percentage',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isAr ? '% من مساحة البناء (حصة عينية)' : '% of BUA (In-Kind Share)', isDark),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _inKindSharePctController,
                      hintText: isAr ? 'أدخل نسبة الحصة العينية' : 'Enter in-kind percentage',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else if (_selectedLandPaymentModes.contains('حصة الإيرادات')) ...[
          _fieldLabel(isAr ? '% من إجمالي الإيرادات' : '% of Gross Revenue', isDark),
          const SizedBox(height: 6),
          CustomTextField(
            controller: _revenueSharePctController,
            hintText: isAr ? 'أدخل نسبة الإيرادات' : 'Enter revenue percentage',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ] else if (_selectedLandPaymentModes.contains('حصة عينية')) ...[
          _fieldLabel(isAr ? '% من مساحة البناء (حصة عينية)' : '% of BUA (In-Kind Share)', isDark),
          const SizedBox(height: 6),
          CustomTextField(
            controller: _inKindSharePctController,
            hintText: isAr ? 'أدخل نسبة الحصة العينية' : 'Enter in-kind percentage',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],

        const SizedBox(height: 24),

        // Section: Construction & Pricing Parameters
        _sectionTitle(isAr ? 'مواصفات التطوير والتكاليف' : 'Development Specs & Pricing', isDark),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('FAR (معامل البناء) *', isDark),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: _farController,
                    hintText: '2.5',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel(isAr ? 'كفاءة البيع GFA (%) *' : 'GFA Efficiency (%) *', isDark),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: _efficiencyController,
                    hintText: '85',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel(isAr ? 'تكلفة البناء / م² *' : 'Cost / m² *', isDark),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: _constructionCostController,
                    hintText: '4200',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel(isAr ? 'سعر البيع المتوقع / م² *' : 'Sale Rev / m² *', isDark),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: _expectedRevenueController,
                    hintText: '9800',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectorTimelineCard(String sector, bool isDark, bool isAr) {
    final ctrl = _getControllersFor(sector);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sector Title Header (e.g. "سكني تواريخ", "تجاري تواريخ", "ضيافة تواريخ")
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isAr ? '$sector تواريخ' : '$sector Dates',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1: Sales Start Year & Sales End Year
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                      isAr ? '$sector سنة بدء المبيعات' : '$sector Sales Start',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.salesStart,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                      isAr ? '$sector سنة انتهاء المبيعات' : '$sector Sales End',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.salesEnd,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Construction Start Year & Construction End Year
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                      isAr ? '$sector سنة بدء البناء' : '$sector Const Start',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.constStart,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                      isAr ? 'Construction end year $sector' : '$sector Const End',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.constEnd,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _fieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required String hint,
    required bool isDark,
    required ValueChanged<String?> onChanged,
    IconData? prefixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
              ],
              Text(
                hint,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                ),
              ),
            ],
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          items: items.map((i) {
            final isItemSel = i == value;
            return DropdownMenuItem<String>(
              value: i,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (prefixIcon != null) ...[
                        Icon(prefixIcon, size: 18, color: AppColors.gold),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        i,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isItemSel ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                  if (isItemSel)
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
