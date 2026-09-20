import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';

class CountryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String isoCode;
  final String phoneCode;
  final String flagEmoji;

  const CountryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.isoCode,
    required this.phoneCode,
    required this.flagEmoji,
  });
}

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final int _pageSize = 10;

  final List<CountryModel> _countries = [
    const CountryModel(
      id: '3',
      nameAr: 'المملكة العربية السعودية',
      nameEn: 'Saudi Arabia',
      isoCode: 'SA',
      phoneCode: '+966',
      flagEmoji: '🇸🇦',
    ),
    const CountryModel(
      id: '1',
      nameAr: 'مصر',
      nameEn: 'Egypt',
      isoCode: 'eg',
      phoneCode: '+20',
      flagEmoji: '🇪🇬',
    ),
    const CountryModel(
      id: '2',
      nameAr: 'الإمارات العربية المتحدة',
      nameEn: 'United Arab Emirates',
      isoCode: 'AE',
      phoneCode: '+971',
      flagEmoji: '🇦🇪',
    ),
    const CountryModel(
      id: '4',
      nameAr: 'دولة قطر',
      nameEn: 'Qatar',
      isoCode: 'QA',
      phoneCode: '+974',
      flagEmoji: '🇶🇦',
    ),
    const CountryModel(
      id: '5',
      nameAr: 'دولة الكويت',
      nameEn: 'Kuwait',
      isoCode: 'KW',
      phoneCode: '+965',
      flagEmoji: '🇰🇼',
    ),
    const CountryModel(
      id: '6',
      nameAr: 'مملكة البحرين',
      nameEn: 'Bahrain',
      isoCode: 'BH',
      phoneCode: '+973',
      flagEmoji: '🇧🇭',
    ),
    const CountryModel(
      id: '7',
      nameAr: 'سلطنة عمان',
      nameEn: 'Oman',
      isoCode: 'OM',
      phoneCode: '+968',
      flagEmoji: '🇴🇲',
    ),
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
    final isAr = locale == 'ar';
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.fullName : 'mohamed hany';

    final surfaceBg = isDark ? const Color(0xFF131A31) : Colors.white;
    final bannerBg = isDark ? const Color(0xFF161F38) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF1E2A4A) : const Color(0xFFE2E8F0);
    final headerRowBg = isDark ? const Color(0xFF10162B) : const Color(0xFFF8FAFC);

    final query = _searchController.text.trim().toLowerCase();
    final filteredCountries = _countries.where((c) {
      if (query.isEmpty) return true;
      return c.nameAr.contains(query) ||
          c.nameEn.toLowerCase().contains(query) ||
          c.isoCode.toLowerCase().contains(query) ||
          c.phoneCode.contains(query) ||
          c.id.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          isAr ? 'الدول' : 'Countries',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          // User Name Pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          // Language Badge
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10, right: 14, left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Banner Card (مساحة العمل / الدول - الدول)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: bannerBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'مساحة العمل  /  الدول' : 'Workspace  /  Countries',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            isAr ? 'الدول' : 'Countries',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.brandNavy,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAr ? '${_countries.length} الإجمالي' : '${_countries.length} Total',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131A31) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      size: 22,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Table Container Card
            Container(
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Top Controls Bar (Search Bar & Page Size dropdown)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Page Size Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F1426) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isAr ? 'عرض $_pageSize دول' : 'Show $_pageSize',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                            ],
                          ),
                        ),

                        // Search Input Field
                        SizedBox(
                          width: 260,
                          height: 38,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                            decoration: InputDecoration(
                              hintText: isAr ? 'ابحث عن دولة' : 'Search country',
                              hintStyle: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                              ),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F1426) : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data Table Content
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 700),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(headerRowBg),
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 56,
                        horizontalMargin: 24,
                        columnSpacing: 36,
                        dividerThickness: 0.8,
                        columns: [
                          DataColumn(
                            label: Text(
                              'ID',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              isAr ? 'الاسم' : 'Name',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              isAr ? 'رمز ISO' : 'ISO Code',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              isAr ? 'رمز الهاتف' : 'Phone Code',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              isAr ? 'العلم' : 'Flag',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                        ],
                        rows: filteredCountries.map((c) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  c.id,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  isAr ? c.nameAr : c.nameEn,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.brandNavy,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    c.isoCode,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.gold : AppColors.brandNavy,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.phoneCode,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.flagEmoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
