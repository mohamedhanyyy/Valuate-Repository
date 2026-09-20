import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/common/app_snack_bar.dart';
import 'currency_screen.dart';

class CreateCurrencyScreen extends StatefulWidget {
  const CreateCurrencyScreen({super.key});

  @override
  State<CreateCurrencyScreen> createState() => _CreateCurrencyScreenState();
}

class _CreateCurrencyScreenState extends State<CreateCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arabicTitleController = TextEditingController();
  final _englishTitleController = TextEditingController();
  final _arabicSymbolController = TextEditingController();
  final _englishSymbolController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _arabicTitleController.dispose();
    _englishTitleController.dispose();
    _arabicSymbolController.dispose();
    _englishSymbolController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _isLoading = false);

      if (mounted) {
        final isAr = context.read<LocaleCubit>().state == 'ar';
        final newCurrency = CurrencyModel(
          id: '${DateTime.now().millisecondsSinceEpoch % 1000}',
          nameAr: _arabicTitleController.text.trim(),
          nameEn: _englishTitleController.text.trim().isNotEmpty
              ? _englishTitleController.text.trim()
              : _arabicTitleController.text.trim(),
          creator: 'Gateway Tech Team',
          symbol: _arabicSymbolController.text.trim().isNotEmpty
              ? _arabicSymbolController.text.trim()
              : _englishSymbolController.text.trim(),
          createdAt: '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}',
        );

        AppSnackBar.showSuccess(
          context,
          message: isAr ? 'تمت إضافة العملة بنجاح!' : 'Currency created successfully!',
        );

        Navigator.pop(context, newCurrency);
      }
    }
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
    final inputBg = isDark ? const Color(0xFF0F1426) : const Color(0xFFF8FAFC);

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
          isAr ? 'إضافة عملة' : 'Create Currency',
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Banner Card (مساحة العمل / العملات - إضافة عملة)
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
                            isAr ? 'مساحة العمل  /  العملات' : 'Workspace  /  Currencies',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isAr ? 'إضافة عملة' : 'Create Currency',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.brandNavy,
                            ),
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
                          Icons.monetization_on_outlined,
                          size: 22,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: العنوان العربي & العنوان الإنجليزي
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 540) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Arabic Title
                                  Expanded(
                                    child: _buildFormField(
                                      label: isAr ? 'العنوان العربي' : 'Arabic Title',
                                      hintText: isAr ? 'العنوان العربي' : 'Arabic Title',
                                      controller: _arabicTitleController,
                                      isDark: isDark,
                                      inputBg: inputBg,
                                      borderColor: borderColor,
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? (isAr ? 'العنوان العربي مطلوب' : 'Arabic title is required')
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // English Title
                                  Expanded(
                                    child: _buildFormField(
                                      label: isAr ? 'العنوان الإنجليزي' : 'English Title',
                                      hintText: isAr ? 'العنوان الإنجليزي' : 'English Title',
                                      controller: _englishTitleController,
                                      isDark: isDark,
                                      inputBg: inputBg,
                                      borderColor: borderColor,
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? (isAr ? 'العنوان الإنجليزي مطلوب' : 'English title is required')
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildFormField(
                                    label: isAr ? 'العنوان العربي' : 'Arabic Title',
                                    hintText: isAr ? 'العنوان العربي' : 'Arabic Title',
                                    controller: _arabicTitleController,
                                    isDark: isDark,
                                    inputBg: inputBg,
                                    borderColor: borderColor,
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? (isAr ? 'العنوان العربي مطلوب' : 'Arabic title is required')
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFormField(
                                    label: isAr ? 'العنوان الإنجليزي' : 'English Title',
                                    hintText: isAr ? 'العنوان الإنجليزي' : 'English Title',
                                    controller: _englishTitleController,
                                    isDark: isDark,
                                    inputBg: inputBg,
                                    borderColor: borderColor,
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? (isAr ? 'العنوان الإنجليزي مطلوب' : 'English title is required')
                                        : null,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Row 2: الرمز العربي & الرمز الإنجليزي
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 540) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Arabic Symbol
                                  Expanded(
                                    child: _buildFormField(
                                      label: isAr ? 'الرمز العربي' : 'Arabic Symbol',
                                      hintText: isAr ? 'الرمز العربي' : 'Arabic Symbol',
                                      controller: _arabicSymbolController,
                                      isDark: isDark,
                                      inputBg: inputBg,
                                      borderColor: borderColor,
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? (isAr ? 'الرمز العربي مطلوب' : 'Arabic symbol is required')
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // English Symbol
                                  Expanded(
                                    child: _buildFormField(
                                      label: isAr ? 'الرمز الإنجليزي' : 'English Symbol',
                                      hintText: isAr ? 'الرمز الإنجليزي' : 'English Symbol',
                                      controller: _englishSymbolController,
                                      isDark: isDark,
                                      inputBg: inputBg,
                                      borderColor: borderColor,
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? (isAr ? 'الرمز الإنجليزي مطلوب' : 'English symbol is required')
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildFormField(
                                    label: isAr ? 'الرمز العربي' : 'Arabic Symbol',
                                    hintText: isAr ? 'الرمز العربي' : 'Arabic Symbol',
                                    controller: _arabicSymbolController,
                                    isDark: isDark,
                                    inputBg: inputBg,
                                    borderColor: borderColor,
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? (isAr ? 'الرمز العربي مطلوب' : 'Arabic symbol is required')
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFormField(
                                    label: isAr ? 'الرمز الإنجليزي' : 'English Symbol',
                                    hintText: isAr ? 'الرمز الإنجليزي' : 'English Symbol',
                                    controller: _englishSymbolController,
                                    isDark: isDark,
                                    inputBg: inputBg,
                                    borderColor: borderColor,
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? (isAr ? 'الرمز الإنجليزي مطلوب' : 'English symbol is required')
                                        : null,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 28),

                        // Submit Button (إرسال)
                        Align(
                          alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB), // Rich Blue
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isAr ? 'إرسال' : 'Submit',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isDark,
    required Color inputBg,
    required Color borderColor,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
              fontSize: 13.5,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
