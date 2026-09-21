import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/common/app_snack_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/theme_lang_bar.dart';
import '../../widgets/valuate_logo.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../main_shell_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: kDebugMode ? 'Mohamed' : null);
  final _lastNameController = TextEditingController(text: kDebugMode ? 'Hany' : null);
  final _emailController = TextEditingController(text: kDebugMode ? 'mohamedfcis2000@gmail.com' : null);
  final _companyController = TextEditingController(text: kDebugMode ? 'Valuate Inc' : null);
  final _phoneController = TextEditingController(text: kDebugMode ? '+201145330378' : null);
  final _passwordController = TextEditingController(text: kDebugMode ? 'rgmeigmero2W@edgmorer' : null);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            companyName: _companyController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: ValuateLogo(height: 28, isDark: isDark),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: ThemeLangBar(),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShellScreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              AppSnackBar.showError(
                context,
                message: state.message,
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('getStarted', locale: locale),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get('createAccount', locale: locale),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.get('freeTrialNote', locale: locale),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: AppStrings.get('firstNameLabel', locale: locale),
                            hintText: AppStrings.get('firstNamePlaceholder', locale: locale),
                            controller: _firstNameController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppStrings.get('fieldRequired', locale: locale)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: AppStrings.get('lastNameLabel', locale: locale),
                            hintText: AppStrings.get('lastNamePlaceholder', locale: locale),
                            controller: _lastNameController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppStrings.get('fieldRequired', locale: locale)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Email
                    CustomTextField(
                      label: AppStrings.get('emailLabel', locale: locale),
                      hintText: 'you@company.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        size: 18,
                        color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? AppStrings.get('invalidEmail', locale: locale)
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Company Name
                    CustomTextField(
                      label: AppStrings.get('companyLabel', locale: locale),
                      hintText: AppStrings.get('companyPlaceholder', locale: locale),
                      controller: _companyController,
                      prefixIcon: Icon(
                        Icons.business_outlined,
                        size: 18,
                        color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppStrings.get('fieldRequired', locale: locale)
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Phone Number
                    CustomTextField(
                      label: AppStrings.get('phoneLabel', locale: locale),
                      hintText: AppStrings.get('phonePlaceholder', locale: locale),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppStrings.get('fieldRequired', locale: locale)
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    CustomTextField(
                      label: AppStrings.get('passwordLabel', locale: locale),
                      hintText: AppStrings.get('createPasswordPlaceholder', locale: locale),
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? AppStrings.get('passwordLength', locale: locale)
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          text: AppStrings.get('createAccount', locale: locale),
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Terms & Privacy Clickable Note
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          locale == 'ar'
                              ? 'بالنقر على "إنشاء الحساب"، أنت توافق على '
                              : 'By clicking "Create your account", you agree to our ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsOfServiceScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.get('termsOfService', locale: locale),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          locale == 'ar' ? ' و ' : ' and ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.get('privacyPolicy', locale: locale),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Already have account
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${AppStrings.get('alreadyHaveAccount', locale: locale)} ',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              AppStrings.get('signIn', locale: locale),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
