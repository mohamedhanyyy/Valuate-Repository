import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/valuate_logo.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

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
          locale == 'ar' ? 'شروط الخدمة' : 'Terms of Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: ValuateLogo(height: 22, isDark: isDark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            FadeSlideEntrance(
              duration: const Duration(milliseconds: 450),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkBrandBg1, AppColors.darkBrandBg2]
                        : [AppColors.lightBrandBg1, AppColors.lightBrandBg2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
                            color: AppColors.gold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale == 'ar'
                                    ? 'اتفاقية الاستخدام والخدمة'
                                    : 'Terms of Use & Service Agreement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                locale == 'ar'
                                    ? 'سارية المفعول اعتباراً من سبتمبر 2026'
                                    : 'Effective Date: September 2026',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      locale == 'ar'
                          ? 'تحكم هذه الشروط استخدامك لمنصة وتطبيقات فاليوإيت (Valuate) المتخصصة في دراسات الجدوى والنمذجة المالية العقارية.'
                          : 'These Terms govern your access to and use of the Valuate Real Estate Feasibility Suite, financial tools, and intelligence APIs.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Terms Sections
            if (locale == 'ar') ...[
              _buildSectionCard(
                icon: Icons.verified_user_outlined,
                title: '1. قبول الشروط والحسابات',
                content:
                    'بإنشاء حساب على منصة فاليوإيت، فإنك تقر وتوافق على الالتزام الكامل بهذه الشروط. يتحمل المستخدم مسؤولية الحفاظ على سرية بيانات تسجيل الدخول الخاصة به.',
                isDark: isDark,
                delayMs: 100,
              ),
              _buildSectionCard(
                icon: Icons.account_balance_outlined,
                title: '2. إخلاء المسؤولية المالية والاستثمارية',
                content:
                    'توفر المنصة أدوات نمذجة وحسابات تقديرية (مثل ROI و IRR والتكلفة الإجمالية TDC وسيناريوهات الحساسية) لمساعدة المطورين والمستثمرين في اتخاذ القرار. لا تعتبر هذه النتائج مشورة مالية أو قانونية ملزمة أو ضماناً للأرباح المستقبلية.',
                isDark: isDark,
                delayMs: 180,
              ),
              _buildSectionCard(
                icon: Icons.copyright_rounded,
                title: '3. حقوق الملكية الفكرية',
                content:
                    'جميع خوارزميات الحساب، وتصميمات واجهات المستخدم، ومؤشرات السوق الإقليمية، والعلامات التجارية لـ Valuate محمية بموجب قوانين الملكية الفكرية وحقوق النشر الدولية.',
                isDark: isDark,
                delayMs: 260,
              ),
              _buildSectionCard(
                icon: Icons.assignment_outlined,
                title: '4. استخدام دراسات الجدوى والتقارير',
                content:
                    'يمنح المستخدم ترخيصاً كاملاً لاستخدام وتصدير ومشاركة التقارير ودراسات الجدوى المنشأة داخل حسابه مع شركائه والمؤسسات التمويلية.',
                isDark: isDark,
                delayMs: 340,
              ),
              _buildSectionCard(
                icon: Icons.rule_rounded,
                title: '5. التعديل وإنهاء الخدمة',
                content:
                    'يحق لمنصة فاليوإيت تعديل أو تحديث هذه الشروط عند الضرورة، وسيتم إخطار المستخدمين بأي تغييرات جوهرية عبر البريد الإلكتروني أو داخل التطبيق.',
                isDark: isDark,
                delayMs: 420,
              ),
            ] else ...[
              _buildSectionCard(
                icon: Icons.verified_user_outlined,
                title: '1. Acceptance of Terms & Account Integrity',
                content:
                    'By creating an account or accessing Valuate, you represent that you have the authority to bind yourself or your corporate entity to these Terms. You are responsible for safeguarding your credentials.',
                isDark: isDark,
                delayMs: 100,
              ),
              _buildSectionCard(
                icon: Icons.account_balance_outlined,
                title: '2. Financial & Investment Disclaimer',
                content:
                    'Calculations generated by Valuate (including TDC, ROI, IRR, MOIC, Breakeven, and Cashflow Phasing) are algorithmic projections designed for decision-support modeling. They do not constitute formal investment underwriting or certified financial guarantees.',
                isDark: isDark,
                delayMs: 180,
              ),
              _buildSectionCard(
                icon: Icons.copyright_rounded,
                title: '3. Intellectual Property Rights',
                content:
                    'All financial engines, software architecture, regional benchmark indices, UI design systems, and Valuate trademarks are protected by international intellectual property laws.',
                isDark: isDark,
                delayMs: 260,
              ),
              _buildSectionCard(
                icon: Icons.assignment_outlined,
                title: '4. Deliverables & Commercial Reports',
                content:
                    'You retain 100% ownership of your customized feasibility studies, cashflow models, and exported PDF executive dossiers, with full license to present them to lenders, equity funds, and stakeholders.',
                isDark: isDark,
                delayMs: 340,
              ),
              _buildSectionCard(
                icon: Icons.rule_rounded,
                title: '5. Service Modifications & Termination',
                content:
                    'We reserve the right to upgrade algorithms, amend features, or update terms with reasonable notice. You may terminate your subscription or delete your account at any time.',
                isDark: isDark,
                delayMs: 420,
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
    required int delayMs,
  }) {
    return FadeSlideEntrance(
      delay: Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 480),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
