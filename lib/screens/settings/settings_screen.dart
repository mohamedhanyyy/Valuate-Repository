import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/dialogs/logout_dialog.dart';
import '../account/change_password_screen.dart';
import '../account/profile_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<String> _currencies = const ['SAR', 'AED', 'USD', 'EGP', 'QAR', 'KWD'];
  final List<String> _units = const ['sqm', 'sqft'];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final authState = context.watch<AuthCubit>().state;

    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        title: Text(
          AppStrings.get('navSettings', locale: locale),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Header Card (clickable to profile)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.brandBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (user?.firstName.isNotEmpty ?? false)
                              ? user!.firstName[0].toUpperCase()
                              : 'V',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName.isNotEmpty ?? false ? user!.fullName : 'mohamed hany',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.companyName.isNotEmpty ?? false
                                ? user!.companyName
                                : 'testeing',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'mohamedfcis2000@gmail.com',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account & Security Section
            _sectionHeader(
              locale == 'ar' ? 'الحساب والأمان' : 'Account & Security',
              isDark,
            ),
            const SizedBox(height: 10),

            Material(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _settingTile(
                    icon: Icons.person_outline_rounded,
                    title: locale == 'ar' ? 'الملف الشخصي' : 'Profile',
                    subtitle: locale == 'ar' ? 'تعديل البيانات الشخصية والشركة' : 'Manage personal & company details',
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),

                  _divider(isDark),
                  _settingTile(
                    icon: Icons.lock_outline_rounded,
                    title: locale == 'ar' ? 'كلمة المرور' : 'Password',
                    subtitle: locale == 'ar' ? 'تغيير كلمة المرور وتأمين الحساب' : 'Update password & secure account',
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preferences Section
            _sectionHeader(
              locale == 'ar' ? 'التفضيلات والإعدادات المالية' : 'Preferences & Financial Units',
              isDark,
            ),
            const SizedBox(height: 10),

            Material(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Dark Mode Switch
                  _settingTile(
                    icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    title: AppStrings.get('darkMode', locale: locale),
                    isDark: isDark,
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeTrackColor: AppColors.primaryBlue,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                    ),
                  ),
                  _divider(isDark),

                  // Language Selector
                  _settingTile(
                    icon: Icons.language_rounded,
                    title: AppStrings.get('language', locale: locale),
                    isDark: isDark,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: locale,
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('🇺🇸 English', style: TextStyle(fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text('🇸🇦 عربي', style: TextStyle(fontSize: 13, fontFamily: 'Cairo')),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) context.read<LocaleCubit>().setLocale(val);
                        },
                      ),
                    ),
                  ),
                  _divider(isDark),

                  // Currency Selector
                  _settingTile(
                    icon: Icons.currency_exchange_rounded,
                    title: AppStrings.get('currency', locale: locale),
                    isDark: isDark,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: user?.preferredCurrency ?? 'SAR',
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        items: _currencies.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<AuthCubit>().updateUserPreferences(currency: val);
                          }
                        },
                      ),
                    ),
                  ),
                  _divider(isDark),

                  // Unit Selector (sqm vs sqft)
                  _settingTile(
                    icon: Icons.square_foot_rounded,
                    title: AppStrings.get('unit', locale: locale),
                    isDark: isDark,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: user?.preferredUnit ?? 'sqm',
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        items: _units.map((u) {
                          return DropdownMenuItem(
                            value: u,
                            child: Text(
                              AppStrings.get(u, locale: locale),
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<AuthCubit>().updateUserPreferences(unit: val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About & System
            _sectionHeader(AppStrings.get('about', locale: locale), isDark),
            const SizedBox(height: 10),

            Material(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [

                   _settingTile(
                    icon: Icons.description_outlined,
                    title: AppStrings.get('termsOfService', locale: locale),
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      );

                    },
                  ),
                  _divider(isDark),
                  _settingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: AppStrings.get('privacyPolicy', locale: locale),
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            InkWell(
              onTap: () {
                LogoutConfirmationDialog.show(
                  context,
                  locale: locale,
                  isDark: isDark,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get('signOut', locale: locale),
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryBlue),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
    );
  }
}
