import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../cubits/theme/theme_cubit.dart';
import '../cubits/locale/locale_cubit.dart';

class ThemeLangBar extends StatelessWidget {
  const ThemeLangBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme Toggle Button (Sun / Moon)
        InkWell(
          onTap: () => context.read<ThemeCubit>().toggleTheme(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 18,
              color: isDark ? AppColors.darkText : AppColors.brandNavy,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Language Pill
        PopupMenuButton<String>(
          initialValue: locale,
          onSelected: (val) {
            context.read<LocaleCubit>().setLocale(val);
          },
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  Text('🇺🇸', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text('English', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'ar',
              child: Row(
                children: [
                  Text('🇸🇦', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text('عربي', style: TextStyle(fontSize: 14, fontFamily: 'Cairo')),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale == 'ar' ? '🇸🇦' : '🇺🇸',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  locale.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
