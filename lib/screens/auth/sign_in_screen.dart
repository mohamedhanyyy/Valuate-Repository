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
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: kDebugMode ? 'mohamedfcis2000@gmail.com' : null,
  );

  final _passwordController = TextEditingController(
    text: kDebugMode ? 'rgmeigmero2W@edgmorer' : null,
  );
  bool _keepLoggedIn = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
        email: _emailController.text,
        password: _passwordController.text,
        remember: _keepLoggedIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShellScreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              AppSnackBar.showError(context, message: state.message);
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Action Bar (Theme + Language)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValuateLogo(height: 32, isDark: isDark),
                              const ThemeLangBar(),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(height: 12),

                          // Sign In Form Card
                          Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('signIn', locale: locale),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.get('signInLead', locale: locale),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        CustomTextField(
                          label: AppStrings.get('emailLabel', locale: locale),
                          hintText: AppStrings.get(
                            'emailPlaceholder',
                            locale: locale,
                          ),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextFaint
                                : AppColors.lightTextFaint,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppStrings.get(
                                'fieldRequired',
                                locale: locale,
                              );
                            }
                            if (!val.contains('@')) {
                              return AppStrings.get(
                                'invalidEmail',
                                locale: locale,
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          label: AppStrings.get(
                            'passwordLabel',
                            locale: locale,
                          ),
                          hintText: AppStrings.get(
                            'passwordPlaceholder',
                            locale: locale,
                          ),
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextFaint
                                : AppColors.lightTextFaint,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppStrings.get(
                                'fieldRequired',
                                locale: locale,
                              );
                            }
                            if (val.length < 6) {
                              return AppStrings.get(
                                'passwordLength',
                                locale: locale,
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  setState(() {
                                    _keepLoggedIn = !_keepLoggedIn;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _keepLoggedIn,
                                        activeColor: AppColors.primaryBlue,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        side: BorderSide(
                                          color: isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder,
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _keepLoggedIn = val ?? true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        AppStrings.get(
                                          'keepLoggedIn',
                                          locale: locale,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.lightTextMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.get(
                                  'forgotPassword',
                                  locale: locale,
                                ),
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Submit Button
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return PrimaryButton(
                              text: AppStrings.get('signIn', locale: locale),
                              isLoading: state is AuthLoading,
                              onPressed: _submit,
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // Sign Up Link
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${AppStrings.get('dontHaveAccount', locale: locale)} ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppStrings.get('signUp', locale: locale),
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
                const SizedBox(height: 10),

                // Legal Links Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkTextFaint
                              : AppColors.lightTextFaint,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '•',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkTextFaint
                              : AppColors.lightTextFaint,
                        ),
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
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkTextFaint
                              : AppColors.lightTextFaint,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
