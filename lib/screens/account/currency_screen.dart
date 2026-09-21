import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';


class CurrencyModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String creator;
  final String symbol;
  final String createdAt;

  const CurrencyModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.creator,
    required this.symbol,
    required this.createdAt,
  });
}

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _pageSize = 10;

  final List<CurrencyModel> _currencies = [
    const CurrencyModel(
      id: '6',
      nameAr: 'الروبيل الروسي',
      nameEn: 'Russian Ruble',
      creator: 'Gateway Tech Team',
      symbol: '₽',
      createdAt: '2025/10/13',
    ),
    const CurrencyModel(
      id: '5',
      nameAr: 'ريال سعودي',
      nameEn: 'Saudi Riyal',
      creator: 'Gateway Tech Team',
      symbol: 'ر.س',
      createdAt: '2025/10/13',
    ),
    const CurrencyModel(
      id: '4',
      nameAr: 'الجنيه البريطاني',
      nameEn: 'British Pound',
      creator: 'Gateway Tech Team',
      symbol: '£',
      createdAt: '2025/10/13',
    ),
    const CurrencyModel(
      id: '3',
      nameAr: 'يورو',
      nameEn: 'Euro',
      creator: 'Gateway Tech Team',
      symbol: '€',
      createdAt: '2025/10/13',
    ),
    const CurrencyModel(
      id: '1',
      nameAr: 'الجنيه المصري',
      nameEn: 'Egyptian Pound',
      creator: 'النظام',
      symbol: 'ج.م',
      createdAt: '2025/05/21',
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
    final filteredCurrencies = _currencies.where((c) {
      if (query.isEmpty) return true;
      return c.nameAr.contains(query) ||
          c.nameEn.toLowerCase().contains(query) ||
          c.symbol.contains(query) ||
          c.creator.toLowerCase().contains(query) ||
          c.id.contains(query);
    }).toList();

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
          isAr ? 'العملات' : 'Currencies',
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            // Top Banner Card (مساحة العمل / العملات + إضافة عملة جديدة)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: bannerBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131A31) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Icon(
                      Icons.monetization_on_outlined,
                      size: 22,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مساحة العمل  /  العملات' : 'Workspace  /  Currencies',
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
                              isAr ? 'العملات' : 'Currencies',
                              style: TextStyle(
                                fontSize: 18,
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
                              isAr ? '${_currencies.length} الإجمالي' : '${_currencies.length} Total',
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
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Page Size Dropdown
                        PopupMenuButton<int>(
                          initialValue: _pageSize,
                          onSelected: (val) {
                            setState(() {
                              _pageSize = val;
                            });
                          },
                          color: isDark ? const Color(0xFF131A31) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: borderColor),
                          ),
                          itemBuilder: (context) => [5, 10, 20, 50].map((size) {
                            return PopupMenuItem<int>(
                              value: size,
                              child: Text(
                                isAr ? '$size عناصر' : '$size items',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                            );
                          }).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1426) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isAr ? 'كل $_pageSize' : 'Show $_pageSize',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Search Input Field (Expanded to prevent any overflow on mobile)
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                              decoration: InputDecoration(
                                hintText: isAr ? 'ابحث عن عملة' : 'Search currency',
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
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        horizontalMargin: 20,
                        columnSpacing: 30,
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
                              isAr ? 'المنشئ' : 'Creator',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              isAr ? 'الرمز' : 'Symbol',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              isAr ? 'تاريخ الإنشاء' : 'Creation Date',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                        ],
                        rows: filteredCurrencies.map((c) {
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
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.brandNavy,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.creator,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                                    c.symbol,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.gold : AppColors.brandNavy,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.createdAt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                                  ),
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
