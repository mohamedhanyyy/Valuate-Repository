import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  final List<Map<String, String>> _currenciesList = const [
    {'id': '1', 'name': 'Saudi Riyal', 'symbol': 'SAR', 'creator': 'System', 'flag': '🇸🇦'},
    {'id': '2', 'name': 'UAE Dirham', 'symbol': 'AED', 'creator': 'System', 'flag': '🇦🇪'},
    {'id': '3', 'name': 'US Dollar', 'symbol': 'USD', 'creator': 'System', 'flag': '🇺🇸'},
    {'id': '4', 'name': 'Egyptian Pound', 'symbol': 'EGP', 'creator': 'System', 'flag': '🇪🇬'},
    {'id': '5', 'name': 'Qatari Riyal', 'symbol': 'QAR', 'creator': 'System', 'flag': '🇶🇦'},
    {'id': '6', 'name': 'Kuwaiti Dinar', 'symbol': 'KWD', 'creator': 'System', 'flag': '🇰🇼'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final activeCurrency = authState is Authenticated ? authState.user.preferredCurrency : 'SAR';

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
          locale == 'ar' ? 'العملات المالية' : 'Currencies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        itemCount: _currenciesList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _currenciesList[index];
          final isSelected = item['symbol'] == activeCurrency;

          return InkWell(
            onTap: () {
              context.read<AuthCubit>().updateUserPreferences(currency: item['symbol']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Currency updated to ${item['name']} (${item['symbol']})'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(item['flag'] ?? '🌐', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        Text(

                          
                          'Code: ${item['symbol']} • Created by ${item['creator']}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
