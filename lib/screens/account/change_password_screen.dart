import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/common/app_snack_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController(text: kDebugMode ? 'rgmeigmero2W@edgmorer' : null);
  final _newPasswordController = TextEditingController(text: kDebugMode ? 'rgmeigmero2W@edgmorer' : null);
  final _confirmPasswordController = TextEditingController(text: kDebugMode ? 'rgmeigmero2W@edgmorer' : null);

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() => _isLoading = false);

      if (mounted) {
        final isAr = context.read<LocaleCubit>().state == 'ar';
        AppSnackBar.showSuccess(
          context,
          message: isAr ? 'تم تغيير كلمة المرور بنجاح!' : 'Password updated successfully!',
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final isAr = locale == 'ar';
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated
        ? (authState.user.isGuest
            ? (isAr ? 'مستخدم ضيف' : 'Guest User')
            : authState.user.fullName)
        : (isAr ? 'مستخدم ضيف' : 'Guest User');

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
          isAr ? 'تغيير كلمة المرور' : 'Change Password',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          // User Name Pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Banner Card (مساحة العمل / الملف الشخصي - تغيير كلمة المرور)
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
                            isAr ? 'مساحة العمل / الملف الشخصي' : 'Workspace / Profile',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isAr ? 'تغيير كلمة المرور' : 'Change Password',
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
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 22,
                          color: isDark ? Colors.white70 : AppColors.brandNavy,
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
                        // Field 1: كلمة المرور القديمة*
                        _buildFieldLabel(isAr ? 'كلمة المرور القديمة' : 'Old Password', isDark),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _oldPasswordController,
                          hintText: isAr ? 'كلمة المرور القديمة' : 'Old Password',
                          obscure: _obscureOld,
                          onToggleObscure: () => setState(() => _obscureOld = !_obscureOld),
                          isDark: isDark,
                          inputBg: inputBg,
                          borderColor: borderColor,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? (isAr ? 'يرجى إدخال كلمة المرور القديمة' : 'Old password is required')
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Field 2: كلمة مرور جديدة*
                        _buildFieldLabel(isAr ? 'كلمة مرور جديدة' : 'New Password', isDark),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: isAr ? 'كلمة مرور جديدة' : 'New Password',
                          obscure: _obscureNew,
                          onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                          isDark: isDark,
                          inputBg: inputBg,
                          borderColor: borderColor,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return isAr ? 'يرجى إدخال كلمة المرور الجديدة' : 'New password is required';
                            }
                            if (v.length < 6) {
                              return isAr ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف' : 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Field 3: تأكيد كلمة المرور*
                        _buildFieldLabel(isAr ? 'تأكيد كلمة المرور' : 'Confirm Password', isDark),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          isDark: isDark,
                          inputBg: inputBg,
                          borderColor: borderColor,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return isAr ? 'يرجى تأكيد كلمة المرور' : 'Confirm password is required';
                            }
                            if (v != _newPasswordController.text) {
                              return isAr ? 'كلمة المرور غير متطابقة' : 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Submit Button (إرسال)
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB), // Blue button as in screenshot
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
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

  Widget _buildFieldLabel(String label, bool isDark) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        children: const [
          TextSpan(
            text: '*',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required bool isDark,
    required Color inputBg,
    required Color borderColor,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
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
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
          ),
          onPressed: onToggleObscure,
        ),
      ),
    );
  }
}
