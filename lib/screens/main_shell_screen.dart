import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../cubits/locale/locale_cubit.dart';
import '../cubits/theme/theme_cubit.dart';
import '../widgets/valuate_logo.dart';
import 'auth/sign_in_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'projects/projects_list_screen.dart';
import 'settings/settings_screen.dart';
import 'workspace/consolidations_screen.dart';
import 'workspace/countries_screen.dart';
import 'workspace/reports_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProjectsListScreen(
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final isGuest = authState is Authenticated ? authState.user.isGuest : false;
    final userName = authState is Authenticated
        ? (authState.user.isGuest
            ? (locale == 'ar' ? 'مستخدم ضيف' : 'Guest User')
            : authState.user.fullName)
        : (locale == 'ar' ? 'مستخدم ضيف' : 'Guest User');
    final userEmail = authState is Authenticated && !authState.user.isGuest
        ? authState.user.email
        : (locale == 'ar' ? 'وضع الاستكشاف (زائر)' : 'Guest / Explore Mode');
    final userAvatar = authState is Authenticated ? authState.user.avatarPath : null;
    final hasAvatar = userAvatar != null && userAvatar.isNotEmpty && File(userAvatar).existsSync();

    return Drawer(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValuateLogo(height: 28, isDark: isDark),
                      if (hasAvatar)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.brandBlue,
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            File(userAvatar),
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
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
                  if (isGuest) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.login_rounded,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              locale == 'ar'
                                  ? 'تسجيل الدخول / إنشاء حساب'
                                  : 'Sign In / Register',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Drawer Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [


                  _drawerSectionTitle(locale == 'ar' ? 'مساحة العمل' : 'Workspace', isDark),
                  _drawerItem(
                    icon: Icons.dashboard_outlined,
                    title: locale == 'ar' ? 'لوحة التحكم والملخص' : 'Dashboard Overview',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.description_outlined,
                    title: locale == 'ar' ? 'التقارير التنفيذية' : 'Reports',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportsScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.account_tree_outlined,
                    title: locale == 'ar' ? 'التجميع والدمج المالي' : 'Consolidations',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConsolidationsScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.public_rounded,
                    title: locale == 'ar' ? 'الدول' : 'Countries',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CountriesScreen(),
                        ),
                      );
                    },
                  ),

                  _drawerSectionTitle(locale == 'ar' ? 'الإعدادات' : 'Settings', isDark),
                  _drawerItem(
                    icon: Icons.settings_outlined,
                    title: locale == 'ar' ? 'الإعدادات' : 'Settings',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
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
        leading: Icon(icon, size: 20, color: iconColor ?? (isSelected ? AppColors.primaryBlue : null)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryBlue : null,
          ),
        ),
        dense: true,
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}
