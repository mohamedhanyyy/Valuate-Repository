import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../cubits/locale/locale_cubit.dart';
import '../cubits/theme/theme_cubit.dart';
import '../widgets/dialogs/logout_dialog.dart';
import '../widgets/valuate_logo.dart';
import 'account/change_password_screen.dart';
import 'account/currency_screen.dart';
import 'account/profile_screen.dart';
import 'calculator/feasibility_calculator_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/terms_of_service_screen.dart';
import 'projects/projects_list_screen.dart';
import 'settings/settings_screen.dart';
import 'workspace/consolidations_screen.dart';
import 'workspace/countries_screen.dart';
import 'workspace/create_project_wizard_screen.dart';
import 'workspace/reports_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.fullName : 'mohamed hany';
    final userEmail = authState is Authenticated ? authState.user.email : 'mohamedfcis2000@gmail.com';

    final screens = [
      DashboardScreen(onTabChange: _onTabSelect),
      const FeasibilityCalculatorScreen(),
      ProjectsListScreen(onNavigateTab: _onTabSelect),
      const CountriesScreen(),
      const SettingsScreen(),
      const ReportsScreen(),
      const ConsolidationsScreen(),
    ];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValuateLogo(height: 28, isDark: isDark),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _drawerSectionTitle(locale == 'ar' ? 'نظرة عامة' : 'Overview', isDark),
                    _drawerItem(
                      icon: Icons.dashboard_outlined,
                      title: locale == 'ar' ? 'الرئيسية' : 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(0);
                      },
                    ),

                    _drawerSectionTitle(locale == 'ar' ? 'مساحة العمل' : 'Workspace', isDark),
                    _drawerItem(
                      icon: Icons.folder_outlined,
                      title: locale == 'ar' ? 'المشاريع' : 'Projects',
                      isSelected: _currentIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(2);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.add_circle_outline_rounded,
                      title: locale == 'ar' ? 'إضافة مشروع جديد' : 'Add new project',
                      isSelected: false,
                      iconColor: AppColors.gold,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateProjectWizardScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.calculate_outlined,
                      title: locale == 'ar' ? 'حاسبة الجدوى' : 'Feasibility Calculator',
                      isSelected: _currentIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(1);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.description_outlined,
                      title: locale == 'ar' ? 'التقارير' : 'Reports',
                      isSelected: _currentIndex == 5,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(5);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.account_tree_outlined,
                      title: locale == 'ar' ? 'التجميع والدمج' : 'Consolidations',
                      isSelected: _currentIndex == 6,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(6);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.public_rounded,
                      title: locale == 'ar' ? 'الدول' : 'Countries',
                      isSelected: _currentIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(3);
                      },
                    ),

                    _drawerSectionTitle(locale == 'ar' ? 'الحساب' : 'Account', isDark),
                    _drawerItem(
                      icon: Icons.person_outline_rounded,
                      title: locale == 'ar' ? 'الملف الشخصي' : 'Profile',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.currency_exchange_rounded,
                      title: locale == 'ar' ? 'العملات' : 'Currency',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CurrencyScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.lock_outline_rounded,
                      title: locale == 'ar' ? 'كلمة المرور' : 'Password',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.settings_outlined,
                      title: locale == 'ar' ? 'الإعدادات' : 'Settings',
                      isSelected: _currentIndex == 4,
                      onTap: () {
                        Navigator.pop(context);
                        _onTabSelect(4);
                      },
                    ),

                    _drawerSectionTitle(locale == 'ar' ? 'الشروط والسياسات' : 'Legal & Policies', isDark),
                    _drawerItem(
                      icon: Icons.gavel_rounded,
                      title: AppStrings.get('termsOfService', locale: locale),
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.get('privacyPolicy', locale: locale),
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
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

              // Drawer Footer (Sign out)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorderSoft,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    LogoutConfirmationDialog.show(
                      context,
                      locale: locale,
                      isDark: isDark,
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        locale == 'ar' ? 'تسجيل الخروج' : 'Sign out',
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
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
            onTap: _onTabSelect,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.gold,
            unselectedItemColor: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, height: 1.4),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, height: 1.4),
            selectedFontSize: 11.5,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.dashboard_outlined, size: 22),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.dashboard_rounded, size: 22, color: AppColors.gold),
                ),
                label: AppStrings.get('navDashboard', locale: locale),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.calculate_outlined, size: 22),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calculate_rounded, size: 22, color: AppColors.gold),
                ),
                label: AppStrings.get('navCalculator', locale: locale),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.folder_outlined, size: 22),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_rounded, size: 22, color: AppColors.gold),
                ),
                label: AppStrings.get('navProjects', locale: locale),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.trending_up_rounded, size: 22),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.query_stats_rounded, size: 22, color: AppColors.gold),
                ),
                label: AppStrings.get('navMarket', locale: locale),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.settings_outlined, size: 22),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings_rounded, size: 22, color: AppColors.gold),
                ),
                label: AppStrings.get('navSettings', locale: locale),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, size: 20, color: iconColor ?? (isSelected ? AppColors.gold : null)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.gold : null,
          ),
        ),
        dense: true,
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}
