import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';

import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/projects/projects_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class CreateProjectWizardScreen extends StatefulWidget {
  const CreateProjectWizardScreen({super.key});

  @override
  State<CreateProjectWizardScreen> createState() =>
      _CreateProjectWizardScreenState();
}

class _CreateProjectWizardScreenState extends State<CreateProjectWizardScreen> {
  int _currentStep = 1; // Step 1: Standard Information, Step 2: Financial Model

  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _developerNameController = TextEditingController(text: 'mohamed hany');
  final _landAreaController = TextEditingController(text: '5000');
  final _landCostController = TextEditingController(text: '15000000');
  final _constructionCostController = TextEditingController(text: '4200');
  final _expectedRevenueController = TextEditingController(text: '9800');
  final _farController = TextEditingController(text: '2.5');
  final _efficiencyController = TextEditingController(text: '85');
  final _developmentMonthsController = TextEditingController(text: '24');

  String _selectedSector = 'Residential';
  String _selectedType = 'Sell'; // Sell, Rent, Hold
  String _selectedCountry = 'Saudi Arabia';
  String _selectedCity = 'Riyadh';
  String _landPaymentMode = 'Cash Payment'; // Cash Payment, In Kind Share, Revenue Share

  final List<String> _types = const [
    'Sell',
    'Rent',
    'Hold',
  ];

  final List<String> _sectors = const [
    'Residential',
    'Commercial',
    'Hospitality',
    'Mixed-Use',
    'Industrial',
  ];

  final List<String> _countries = const [
    'Saudi Arabia',
    'United Arab Emirates',
    'Egypt',
    'Qatar',
    'Kuwait',
    'Bahrain',
    'Oman',
  ];

  final List<String> _paymentModes = const [
    'Cash Payment',
    'In Kind Share',
    'Revenue Share',
  ];

  @override
  void dispose() {
    _projectNameController.dispose();
    _developerNameController.dispose();
    _landAreaController.dispose();
    _landCostController.dispose();
    _constructionCostController.dispose();
    _expectedRevenueController.dispose();
    _farController.dispose();
    _efficiencyController.dispose();
    _developmentMonthsController.dispose();
    super.dispose();
  }

  void _saveProject() {
    if (_formKey.currentState?.validate() ?? false) {
      final landArea = double.tryParse(_landAreaController.text) ?? 5000.0;
      final landCost = double.tryParse(_landCostController.text) ?? 15000000.0;
      final constCost = double.tryParse(_constructionCostController.text) ?? 4200.0;
      final revenue = double.tryParse(_expectedRevenueController.text) ?? 9800.0;
      final far = double.tryParse(_farController.text) ?? 2.5;
      final efficiency = double.tryParse(_efficiencyController.text) ?? 85.0;
      final months = int.tryParse(_developmentMonthsController.text) ?? 24;

      final study = FeasibilityStudy(
        id: 'prj_${DateTime.now().millisecondsSinceEpoch}',
        title: _projectNameController.text.trim().isNotEmpty
            ? _projectNameController.text.trim()
            : 'New Feasibility Project',
        assetType: _selectedSector,
        location: '$_selectedCity, $_selectedCountry',
        landArea: landArea,
        far: far,
        efficiencyPct: efficiency,
        landCost: landCost,
        constructionCostPerSqm: constCost,
        expectedRevenuePerSqm: revenue,
        developmentMonths: months,
        currency: _selectedCountry == 'United Arab Emirates'
            ? 'AED'
            : _selectedCountry == 'Egypt'
                ? 'EGP'
                : _selectedCountry == 'Qatar'
                    ? 'QAR'
                    : 'SAR',
      );

      context.read<ProjectsCubit>().addOrUpdateStudy(study);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully in Valuate Workspace!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
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
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          locale == 'ar'
              ? 'إنشاء مشروع جديد (خطوة $_currentStep من 2)'
              : 'Create Project - Step $_currentStep of 2',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: _currentStep == 1
              ? _buildStep1(isDark, locale)
              : _buildStep2(isDark, locale),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  child: Text(
                    locale == 'ar' ? 'السابق' : 'Previous',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentStep == 2) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: _currentStep == 1
                    ? (locale == 'ar' ? 'التالي: النمذجة المالية' : 'Next: Financial Model')
                    : (locale == 'ar' ? 'حفظ وتأكيد المشروع' : 'Save & Create Project'),
                 icon: _currentStep == 2 ? Icons.check_circle_outline_rounded : null,
                onPressed: () {
                  if (_currentStep == 1) {
                    if (_projectNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a project name'),
                          backgroundColor: AppColors.danger,
                        ),
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

  Widget _buildStep1(bool isDark, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          locale == 'ar' ? '1. المعلومات الأساسية للمشروع' : '1. Standard Information',
          Icons.info_outline_rounded,
          isDark,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: locale == 'ar' ? 'اسم المشروع *' : 'Project name *',
          hintText: 'e.g. Al-Narjis Luxury Heights',
          controller: _projectNameController,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Project name is required' : null,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: locale == 'ar' ? 'اسم المطور *' : 'Developer name *',
          hintText: 'e.g. Gateway Real Estate Development',
          controller: _developerNameController,
        ),
        const SizedBox(height: 14),

        // Sector Radio / Chips
        Text(
          locale == 'ar' ? 'قطاع المشروع *' : 'Project Sectors *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sectors.map((s) {
            final isSel = _selectedSector == s;
            return ChoiceChip(
              label: Text(s),
              selected: isSel,
              selectedColor: AppColors.primaryBlue,
              onSelected: (_) => setState(() => _selectedSector = s),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Type (Sell, Rent, Hold)
        Text(
          locale == 'ar' ? 'نوع استراتيجية المشروع *' : 'Strategy Type *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((t) {
            final isSel = _selectedType == t;
            return ChoiceChip(
              label: Text(t),
              selected: isSel,
              selectedColor: AppColors.gold,
              onSelected: (_) => setState(() => _selectedType = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        _sectionHeader(
          locale == 'ar' ? '2. موقع المشروع' : '2. Project Location',
          Icons.location_on_outlined,
          isDark,
        ),
        const SizedBox(height: 12),
        _dropdownField(
          label: locale == 'ar' ? 'الدولة *' : 'Country *',
          value: _selectedCountry,
          items: _countries,
          isDark: isDark,
          onChanged: (v) => setState(() => _selectedCountry = v!),
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: locale == 'ar' ? 'المدينة / الحي *' : 'City / Submarket *',
          hintText: 'e.g. Riyadh, North District',
          initialValue: _selectedCity,
          onChanged: (v) => _selectedCity = v,
        ),
        const SizedBox(height: 24),

        _sectionHeader(
          locale == 'ar' ? '3. تفاصيل الأرض وطريقة السداد' : '3. Land Details & Payment Terms',
          Icons.landscape_outlined,
          isDark,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: locale == 'ar' ? 'مساحة الأرض (م²) *' : 'Land Area (m²) *',
          hintText: '5000',
          controller: _landAreaController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        _dropdownField(
          label: locale == 'ar' ? 'هيكل دفع الأرض *' : 'Land Payment Structure *',
          value: _landPaymentMode,
          items: _paymentModes,
          isDark: isDark,
          onChanged: (v) => setState(() => _landPaymentMode = v!),
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: locale == 'ar' ? 'تكلفة الأرض الإجمالية' : 'Total Land Acquisition Cost',
          hintText: '15000000',
          controller: _landCostController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          locale == 'ar' ? '4. مواصفات البناء والمسطحات' : '4. Construction & Floor Specs',
          Icons.architecture_rounded,
          isDark,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'FAR (معامل البناء)',
                hintText: '2.5',
                controller: _farController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'كفاءة البيع GFA (%)',
                hintText: '85',
                controller: _efficiencyController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _sectionHeader(
          locale == 'ar' ? '5. تقديرات التكلفة وسعر البيع' : '5. Cost Benchmarks & Pricing',
          Icons.attach_money_rounded,
          isDark,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: locale == 'ar' ? 'تكلفة البناء المباشر / م²' : 'Hard Construction Cost / m²',
          hintText: '4200',
          controller: _constructionCostController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: locale == 'ar' ? 'متوسط سعر البيع المتوقع / م²' : 'Expected Sale Revenue / m²',
          hintText: '9800',
          controller: _expectedRevenueController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),

        _sectionHeader(
          locale == 'ar' ? '6. الجدول الزمني للتطوير' : '6. Time Frame & Phasing',
          Icons.calendar_month_outlined,
          isDark,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: locale == 'ar' ? 'مدة المشروع الإجمالية (شهور)' : 'Total Project Duration (Months)',
          hintText: '24',
          controller: _developmentMonthsController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gold),
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
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              items: items.map((i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(i, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
