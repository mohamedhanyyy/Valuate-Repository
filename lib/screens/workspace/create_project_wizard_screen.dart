import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/location_data.dart';
import '../../core/services/user_location_service.dart';
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
  final _projectNameController = TextEditingController();
  final _developerNameController = TextEditingController();
  final _locationController = TextEditingController();
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

  static const List<Map<String, String>> _sectorsList = [
    {'key': 'residential', 'ar': 'سكني', 'en': 'Residential'},
    {'key': 'commercial', 'ar': 'تجاري', 'en': 'Commercial'},
    {'key': 'hospitality', 'ar': 'ضيافة', 'en': 'Hospitality'},
  ];

  static const List<Map<String, String>> _typeOptions = [
    {'key': 'on_plan', 'ar': 'البيع على المخطط', 'en': 'On Plan Sales'},
    {'key': 'off_plan', 'ar': 'البيع على الخارطة', 'en': 'Off Plan Sales'},
    {'key': 'percentage_completion', 'ar': 'نسبة الإنجاز', 'en': 'Percentage Of Completion'},
  ];

  static const List<Map<String, String>> _countryOptions = [
    {'code': 'SA', 'ar': 'المملكة العربية السعودية', 'en': 'Saudi Arabia', 'currency': 'SAR', 'city_ar': 'الرياض', 'city_en': 'Riyadh'},
    {'code': 'EG', 'ar': 'جمهورية مصر العربية', 'en': 'Egypt', 'currency': 'EGP', 'city_ar': 'القاهرة', 'city_en': 'Cairo'},
  ];

  static const List<Map<String, String>> _paymentModeOptions = [
    {'key': 'land_payment', 'ar': 'دفع ثمن الأرض', 'en': 'Land Purchase'},
    {'key': 'revenue_share', 'ar': 'حصة الإيرادات', 'en': 'Revenue Share'},
    {'key': 'inkind_share', 'ar': 'حصة عينية', 'en': 'In-Kind Share'},
  ];

  final Set<String> _selectedSectors = kDebugMode ? {'residential'} : {};
  final Map<String, _SectorDateControllers> _sectorControllers = {};
  final Map<String, TextEditingController> _sectorPercentageControllers = {};

  String _selectedTypeKey = 'on_plan';
  String _selectedCountryCode = 'SA';
  String _selectedGovernorateKey = 'riyadh';
  String _selectedCity = '';
  final Set<String> _selectedLandPaymentModes = kDebugMode ? {'land_payment'} : {};
  String? _mapGisPoint = kDebugMode ? '24.8423, 46.6631' : '';

  String _getSectorLabel(String key, bool isAr) {
    final match = _sectorsList.firstWhere(
      (s) => s['key'] == key || s['ar'] == key || s['en']?.toLowerCase() == key.toLowerCase(),
      orElse: () => {'key': key, 'ar': key, 'en': key},
    );
    return isAr ? match['ar']! : match['en']!;
  }

  String _getTypeLabel(String key, bool isAr) {
    final match = _typeOptions.firstWhere(
      (t) => t['key'] == key || t['en'] == key,
      orElse: () => {'key': key, 'ar': key, 'en': key},
    );
    return isAr ? match['ar']! : match['en']!;
  }

  String _getCountryLabel(String code, bool isAr) {
    final match = _countryOptions.firstWhere(
      (c) => c['code'] == code,
      orElse: () => _countryOptions.first,
    );
    return isAr ? match['ar']! : match['en']!;
  }

  String _getPaymentModeLabel(String key, bool isAr) {
    final match = _paymentModeOptions.firstWhere(
      (m) => m['key'] == key || m['ar'] == key || m['en'] == key,
      orElse: () => {'key': key, 'ar': key, 'en': key},
    );
    return isAr ? match['ar']! : match['en']!;
  }

  @override
  void initState() {
    super.initState();
    final isAr = context.read<LocaleCubit>().state == 'ar';
    final authState = context.read<AuthCubit>().state;
    final defaultDevName = authState is Authenticated
        ? authState.user.fullName
        : (kDebugMode ? (isAr ? 'محمد هاني' : 'Mohamed Hany') : '');
    _developerNameController.text = defaultDevName;

    // Initialize controllers for sectors
    for (final s in _sectorsList) {
      _sectorControllers[s['key']!] = _SectorDateControllers();
    }
    if (kDebugMode) {
      _sectorPercentageControllers['residential'] = TextEditingController(text: '100');
      _projectNameController.text = isAr ? 'مشروع برج الأندلس' : 'Al-Andalus Tower Project';
    }

    final defaultGov = LocationData.getDefaultGovernorate(_selectedCountryCode);
    _selectedGovernorateKey = defaultGov.key;
    _selectedCity = isAr ? defaultGov.nameAr : defaultGov.nameEn;
    _locationController.text = isAr ? defaultGov.nameAr : defaultGov.nameEn;
    _mapGisPoint = '${defaultGov.defaultLat.toStringAsFixed(4)}, ${defaultGov.defaultLng.toStringAsFixed(4)}';

    // Fetch user's real device GPS location for initial location
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    try {
      final userLoc = await UserLocationService.determineUserLocation(preferredCountry: _selectedCountryCode);
      if (!mounted) return;
      final isAr = context.read<LocaleCubit>().state == 'ar';
      setState(() {
        _selectedCountryCode = userLoc.countryCode;
        _selectedGovernorateKey = userLoc.governorate.key;
        _selectedCity = isAr ? userLoc.governorate.nameAr : userLoc.governorate.nameEn;
        _locationController.text = isAr ? userLoc.addressAr : userLoc.addressEn;
        _mapGisPoint = '${userLoc.lat.toStringAsFixed(4)}, ${userLoc.lng.toStringAsFixed(4)}';
      });
    } catch (e) {
      debugPrint('Init user location error: $e');
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

  void _onToggleLandPaymentMode(String mode) {
    setState(() {
      if (_selectedLandPaymentModes.contains(mode)) {
        if (_selectedLandPaymentModes.length > 1) {
          _selectedLandPaymentModes.remove(mode);
        }
      } else {
        _selectedLandPaymentModes.add(mode);
      }
    });
  }

  void _onToggleSector(String sector) {
    setState(() {
      if (_selectedSectors.contains(sector)) {
        if (_selectedSectors.length > 1) {
          _selectedSectors.remove(sector);
          _sectorPercentageControllers[sector]?.dispose();
          _sectorPercentageControllers.remove(sector);
        }
      } else {
        _selectedSectors.add(sector);
        _sectorPercentageControllers[sector] = TextEditingController(text: '0');
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
    final isAr = locale == 'ar';
    final currentCountry = _getCountryLabel(_selectedCountryCode, isAr);
    final result = await LocationMapPickerDialog.show(
      context,
      currentCountry: currentCountry,
      currentLocation: _locationController.text,
      isDark: isDark,
      locale: locale,
    );

    if (result != null) {
      final matchedCountry = _countryOptions.firstWhere(
        (c) => c['ar'] == result.countryAr || c['en']?.toLowerCase() == result.countryEn.toLowerCase(),
        orElse: () => _selectedCountryCode == 'EG' ? _countryOptions.last : _countryOptions.first,
      );
      final matchedGov = LocationData.matchGovernorate(
        matchedCountry['code']!,
        '${result.cityAr} ${result.cityEn} ${result.nameAr} ${result.nameEn}',
      );
      setState(() {
        _selectedCountryCode = matchedCountry['code']!;
        _selectedGovernorateKey = matchedGov.key;
        _selectedCity = isAr ? matchedGov.nameAr : matchedGov.nameEn;
        _locationController.text = isAr ? result.nameAr : result.nameEn;
        _mapGisPoint = '${result.lat.toStringAsFixed(4)}, ${result.lng.toStringAsFixed(4)}';
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

      final isEg = _selectedCountryCode == 'EG';
      final landArea = double.tryParse(_landAreaController.text) ?? 5000.0;
      final landCost = double.tryParse(_landCostController.text) ?? (isEg ? 35000000.0 : 15000000.0);
      final constCost = double.tryParse(_constructionCostController.text) ?? (isEg ? 22000.0 : 4200.0);
      final revenue = double.tryParse(_expectedRevenueController.text) ?? (isEg ? 65000.0 : 9800.0);
      final far = double.tryParse(_farController.text) ?? 2.5;
      final efficiency = double.tryParse(_efficiencyController.text) ?? 85.0;

      // Validate required sector timelines
      for (final s in _selectedSectors) {
        final ctrl = _getControllersFor(s);
        final sectorName = _getSectorLabel(s, isAr);
        if (ctrl.salesStart.text.trim().isEmpty ||
            ctrl.salesEnd.text.trim().isEmpty ||
            ctrl.constStart.text.trim().isEmpty ||
            ctrl.constEnd.text.trim().isEmpty) {
          AppSnackBar.showError(
            context,
            message: isAr
                ? 'يرجى إدخال جميع تواريخ الجدول الزمني لقطاع $sectorName'
                : 'Please enter all timeline dates for $sectorName',
          );
          return;
        }
      }

      // Build sector timelines
      final List<SectorTimeline> timelines = [];
      int minConstYear = 2026;
      int maxConstYear = 2028;

      for (final s in _selectedSectors) {
        final ctrl = _getControllersFor(s);
        final sStart = int.tryParse(ctrl.salesStart.text.trim()) ?? 2026;
        final sEnd = int.tryParse(ctrl.salesEnd.text.trim()) ?? 2029;
        final cStart = int.tryParse(ctrl.constStart.text.trim()) ?? 2026;
        final cEnd = int.tryParse(ctrl.constEnd.text.trim()) ?? 2028;

        if (cStart < minConstYear) minConstYear = cStart;
        if (cEnd > maxConstYear) maxConstYear = cEnd;

        timelines.add(SectorTimeline(
          sector: _getSectorLabel(s, isAr),
          salesStartYear: sStart,
          salesEndYear: sEnd,
          constructionStartYear: cStart,
          constructionEndYear: cEnd,
        ));
      }

      final months = ((maxConstYear - minConstYear + 1) * 12).clamp(12, 60);

      final selectedCountryMatch = _countryOptions.firstWhere(
        (c) => c['code'] == _selectedCountryCode,
        orElse: () => _countryOptions.first,
      );
      final currency = selectedCountryMatch['currency'] ?? 'SAR';
      final countryName = isAr ? selectedCountryMatch['ar']! : selectedCountryMatch['en']!;

      final Map<String, double> percentages = {};
      for (final s in _selectedSectors) {
        percentages[_getSectorLabel(s, isAr)] = double.tryParse(_sectorPercentageControllers[s]?.text.trim() ?? '') ?? 0.0;
      }

      final study = FeasibilityStudy(
        id: 'prj_${DateTime.now().millisecondsSinceEpoch}',
        title: _projectNameController.text.trim().isNotEmpty
            ? _projectNameController.text.trim()
            : (isAr ? 'مشروع عقاري جديد' : 'New Real Estate Project'),
        developerName: _developerNameController.text.trim().isNotEmpty
            ? _developerNameController.text.trim()
            : (kDebugMode ? (isAr ? 'محمد هاني' : 'Mohamed Hany') : ''),
        assetType: _selectedSectors.isNotEmpty ? _getSectorLabel(_selectedSectors.first, isAr) : (isAr ? 'سكني' : 'Residential'),
        selectedSectors: _selectedSectors.map((s) => _getSectorLabel(s, isAr)).toList(),
        sectorPercentages: percentages,
        sectorTimelines: timelines,
        projectType: _getTypeLabel(_selectedTypeKey, isAr),
        country: countryName,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : '$_selectedCity, $countryName',
        mapLocation: _mapGisPoint,
        landPaymentMode: _selectedLandPaymentModes.map((k) => _getPaymentModeLabel(k, isAr)).join(' + '),
        landPaymentModes: _selectedLandPaymentModes.map((k) => _getPaymentModeLabel(k, isAr)).toList(),
        revenueSharePct: _selectedLandPaymentModes.contains('revenue_share')
            ? (double.tryParse(_revenueSharePctController.text) ?? 0.0)
            : 0.0,
        inKindSharePct: _selectedLandPaymentModes.contains('inkind_share')
            ? (double.tryParse(_inKindSharePctController.text) ?? 0.0)
            : 0.0,
        landArea: landArea,
        far: far,
        efficiencyPct: efficiency,
        landCost: _selectedLandPaymentModes.contains('land_payment') ? landCost : 0.0,
        landPricePerSqm: _selectedLandPaymentModes.contains('land_payment')
            ? double.tryParse(_landPricePerSqmController.text)
            : null,
        landPaymentYears: _selectedLandPaymentModes.contains('land_payment')
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
          children: _sectorsList.map((s) {
            final key = s['key']!;
            final isSel = _selectedSectors.contains(key);
            final label = isAr ? s['ar']! : s['en']!;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => _onToggleSector(key),
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
                      label,
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
                              '${_getSectorLabel(s, isAr)} - ${isAr ? 'النسبة' : 'Percentage'}',
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
          value: _selectedTypeKey,
          items: _typeOptions.map((opt) {
            final isSel = opt['key'] == _selectedTypeKey;
            final label = isAr ? opt['ar']! : opt['en']!;
            return DropdownMenuItem<String>(
              value: opt['key'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  if (isSel)
                    const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ],
              ),
            );
          }).toList(),
          hint: isAr ? 'اختر النوع' : 'Select type',
          isDark: isDark,
          onChanged: (v) => setState(() => _selectedTypeKey = v ?? _selectedTypeKey),
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
          value: _selectedCountryCode,
          items: _countryOptions.map((c) {
            final isSel = c['code'] == _selectedCountryCode;
            final label = isAr ? c['ar']! : c['en']!;
            return DropdownMenuItem<String>(
              value: c['code'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, size: 18, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                  if (isSel)
                    const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ],
              ),
            );
          }).toList(),
          hint: isAr ? 'يرجى اختيار دولة' : 'Please select a country',
          isDark: isDark,
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _selectedCountryCode = v;
                final defaultGov = LocationData.getDefaultGovernorate(v);
                _selectedGovernorateKey = defaultGov.key;
                _selectedCity = isAr ? defaultGov.nameAr : defaultGov.nameEn;
                _mapGisPoint = '${defaultGov.defaultLat.toStringAsFixed(4)}, ${defaultGov.defaultLng.toStringAsFixed(4)}';
                _locationController.text = isAr ? defaultGov.nameAr : defaultGov.nameEn;
              });
            }
          },
        ),
        const SizedBox(height: 14),

        // Governorate / Province (المحافظة / المنطقة)
        _fieldLabel(
          _selectedCountryCode == 'EG'
              ? (isAr ? 'المحافظة *' : 'Governorate *')
              : (isAr ? 'المنطقة *' : 'Region / Province *'),
          isDark,
        ),
        const SizedBox(height: 6),
        _buildDropdownSelector(
          value: _selectedGovernorateKey,
          items: LocationData.getGovernoratesForCountry(_selectedCountryCode).map((gov) {
            final isSel = gov.key == _selectedGovernorateKey;
            final label = isAr ? gov.nameAr : gov.nameEn;
            return DropdownMenuItem<String>(
              value: gov.key,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_city_rounded, size: 18, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                  if (isSel)
                    const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                ],
              ),
            );
          }).toList(),
          hint: isAr ? 'يرجى اختيار المحافظة / المنطقة' : 'Please select a governorate / region',
          isDark: isDark,
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _selectedGovernorateKey = v;
                final govList = LocationData.getGovernoratesForCountry(_selectedCountryCode);
                final gov = govList.firstWhere((g) => g.key == v, orElse: () => govList.first);
                _selectedCity = isAr ? gov.nameAr : gov.nameEn;
                _mapGisPoint = '${gov.defaultLat.toStringAsFixed(4)}, ${gov.defaultLng.toStringAsFixed(4)}';
                _locationController.text = isAr ? gov.nameAr : gov.nameEn;
              });
            }
          },
        ),
        const SizedBox(height: 14),

        // Location / Map
        _fieldLabel(isAr ? 'تفاصيل الموقع والحي *' : 'District & Location Details *', isDark),
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
                        hintText: isAr
                            ? 'أدخل اسم الحي أو تفاصيل الموقع أو اختر من الخريطة'
                            : 'Enter district name or choose on map',
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

        // Land Payment Structure Pills
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _paymentModeOptions.map((opt) {
            final key = opt['key']!;
            final isSel = _selectedLandPaymentModes.contains(key);
            final label = isAr ? opt['ar']! : opt['en']!;
            return InkWell(
              onTap: () => _onToggleLandPaymentMode(key),
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
                  label,
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
        if (_selectedLandPaymentModes.contains('land_payment')) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field 1: تكلفة الأرض
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

              // Field 2: سعر المتر
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

              // Field 3: عدد السنوات
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

        if (_selectedLandPaymentModes.contains('land_payment') &&
            (_selectedLandPaymentModes.contains('revenue_share') ||
             _selectedLandPaymentModes.contains('inkind_share')))
          const SizedBox(height: 14),

        if (_selectedLandPaymentModes.contains('revenue_share') &&
            _selectedLandPaymentModes.contains('inkind_share')) ...[
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
                    _fieldLabel(isAr ? '% من مساحة البناء' : '% of BUA (In-Kind Share)', isDark),
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
        ] else if (_selectedLandPaymentModes.contains('revenue_share')) ...[
          _fieldLabel(isAr ? '% من إجمالي الإيرادات' : '% of Gross Revenue', isDark),
          const SizedBox(height: 6),
          CustomTextField(
            controller: _revenueSharePctController,
            hintText: isAr ? 'أدخل نسبة الإيرادات' : 'Enter revenue percentage',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ] else if (_selectedLandPaymentModes.contains('inkind_share')) ...[
          _fieldLabel(isAr ? '% من مساحة البناء' : '% of BUA (In-Kind Share)', isDark),
          const SizedBox(height: 6),
          CustomTextField(
            controller: _inKindSharePctController,
            hintText: isAr ? 'أدخل نسبة الحصة العينية' : 'Enter in-kind percentage',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectorTimelineCard(String sector, bool isDark, bool isAr) {
    final ctrl = _getControllersFor(sector);
    final sectorLabel = _getSectorLabel(sector, isAr);

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
          // Sector Title Header
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
                isAr ? 'تواريخ قطاع $sectorLabel' : '$sectorLabel Timeline',
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
                      isAr ? 'سنة بدء مبيعات $sectorLabel *' : '$sectorLabel Sales Start *',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.salesStart,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isAr ? 'هذا الحقل مطلوب' : 'This field is required';
                        }
                        final y = int.tryParse(val.trim());
                        if (y == null || y < 2000 || y > 2100) {
                          return isAr ? 'سنة غير صحيحة' : 'Invalid year';
                        }
                        return null;
                      },
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
                      isAr ? 'سنة انتهاء مبيعات $sectorLabel *' : '$sectorLabel Sales End *',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.salesEnd,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isAr ? 'هذا الحقل مطلوب' : 'This field is required';
                        }
                        final y = int.tryParse(val.trim());
                        if (y == null || y < 2000 || y > 2100) {
                          return isAr ? 'سنة غير صحيحة' : 'Invalid year';
                        }
                        final start = int.tryParse(ctrl.salesStart.text.trim());
                        if (start != null && y < start) {
                          return isAr ? 'يجب أن تكون ≥ سنة البدء' : 'Must be ≥ Start';
                        }
                        return null;
                      },
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
                      isAr ? 'سنة بدء بناء $sectorLabel *' : '$sectorLabel Const Start *',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.constStart,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isAr ? 'هذا الحقل مطلوب' : 'This field is required';
                        }
                        final y = int.tryParse(val.trim());
                        if (y == null || y < 2000 || y > 2100) {
                          return isAr ? 'سنة غير صحيحة' : 'Invalid year';
                        }
                        return null;
                      },
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
                      isAr ? 'سنة انتهاء بناء $sectorLabel *' : '$sectorLabel Const End *',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: ctrl.constEnd,
                      hintText: 'YYYY',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isAr ? 'هذا الحقل مطلوب' : 'This field is required';
                        }
                        final y = int.tryParse(val.trim());
                        if (y == null || y < 2000 || y > 2100) {
                          return isAr ? 'سنة غير صحيحة' : 'Invalid year';
                        }
                        final start = int.tryParse(ctrl.constStart.text.trim());
                        if (start != null && y < start) {
                          return isAr ? 'يجب أن تكون ≥ سنة البدء' : 'Must be ≥ Start';
                        }
                        return null;
                      },
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
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String hint,
    required bool isDark,
    required ValueChanged<String?> onChanged,
    IconData? prefixIcon,
  }) {
    final validValue = items.any((item) => item.value == value) ? value : null;
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
          value: validValue,
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
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
