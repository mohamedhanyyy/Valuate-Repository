import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/animations/fade_slide_entrance.dart';
import '../../widgets/valuate_logo.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          locale == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy',
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
                            Icons.shield_outlined,
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
                                    ? 'حماية خصوصية بياناتك المالية'
                                    : 'Data Privacy & Security Standard',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                locale == 'ar'
                                    ? 'آخر تحديث: سبتمبر 2026 • إصدار 1.2'
                                    : 'Last Updated: September 2026 • Version 1.2',
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
                        ? 'تلتزم منصة فاليوإيت (Valuate) بحماية سرية دراسات الجدوى والبيانات المالية لعملائنا في منطقة الشرق الأوسط وشمال أفريقيا.'
                        : 'Valuate Intelligence Suite is dedicated to preserving the absolute confidentiality and security of our clients financial and feasibility modeling data across the MENA region.',
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

            // Policy Sections
            if (locale == 'ar') ...[
              _buildSectionCard(
                icon: Icons.data_usage_rounded,
                title: '1. البيانات التي نقوم بجمعها',
                content:
                    'نقوم بجمع البيانات الضرورية لتقديم خدمات الحساب ونمذجة الجدوى العقارية بدقة، وتشمل:\n'
                    '• بيانات الحساب: الاسم الكامل، البريد الإلكتروني، اسم الشركة، ورقم الهاتف.\n'
                    '• بيانات المشاريع العقارية: مساحات الأراضي، معاملات البناء (FAR)، تكاليف الإنشاء، أسعار البيع المتوقعة، والعملات المعتمدة.\n'
                    '• بيانات الاستخدام والتقارير: ملفات دراسات الجدوى المحفوظة والتقارير التنفيذية المصدرة.',
                isDark: isDark,
                delayMs: 100,
              ),
              _buildSectionCard(
                icon: Icons.lock_outline_rounded,
                title: '2. كيفية استخدام وحماية البيانات',
                content:
                    'تُستخدم البيانات فقط لتمكينك من تشغيل النماذج المالية وحفظ سيناريوهات المشروعات. نطبق أعلى معايير الأمان والتشفير (AES-256 و TLS 1.3) لضمان عدم وصول أي طرف ثالث غير مصرح له إلى أرقام دراسات الجدوى الخاصة بك.',
                isDark: isDark,
                delayMs: 180,
              ),
              _buildSectionCard(
                icon: Icons.pie_chart_outline_rounded,
                title: '3. سرية النماذج والتقييمات المالية',
                content:
                    'تعتبر دراسات الجدوى وأرقام التكاليف والأرباح التقديرية ملكاً حصرياً للمستخدم. لا تقوم المنصة بمشاركة أو بيع أي بيانات مالية مخصصة لأي جهة إعلانية أو استثمارية خارجية.',
                isDark: isDark,
                delayMs: 260,
              ),
              _buildSectionCard(
                icon: Icons.cloud_done_outlined,
                title: '4. التخزين السحابي والنسخ الاحتياطي',
                content:
                    'يتم تخزين بيانات المحفظة محلياً وسحابياً عبر خوادم آمنة معتمدة. يمكنك حذف أو تعديل أو تصدير بيانات مشاريعك في أي وقت مباشرة من خلال لوحة التحكم.',
                isDark: isDark,
                delayMs: 340,
              ),
              _buildSectionCard(
                icon: Icons.contact_support_outlined,
                title: '5. التواصل ومسؤول حماية البيانات',
                content:
                    'إذا كانت لديك أي استفسارات أو طلبات تتعلق بخصوصية بياناتك، يمكنك التواصل مع فريق الدعم وحماية البيانات عبر البريد: privacy@valuate-suite.com',
                isDark: isDark,
                delayMs: 420,
              ),
            ] else ...[
              _buildSectionCard(
                icon: Icons.data_usage_rounded,
                title: '1. Information We Collect',
                content:
                    'We collect the minimal required information to deliver accurate real estate financial modeling and account capabilities:\n'
                    '• Account Credentials: Name, corporate email, company entity, phone number.\n'
                    '• Project & Feasibility Parameters: Land areas, FAR factors, construction capex, anticipated sales prices, and currency preferences.\n'
                    '• Workspace & Dossier Data: Saved feasibility models and generated executive reports.',
                isDark: isDark,
                delayMs: 100,
              ),
              _buildSectionCard(
                icon: Icons.lock_outline_rounded,
                title: '2. Data Usage & Encryption Standards',
                content:
                    'Your data is exclusively utilized to run financial algorithms, calculate metrics (ROI, IRR, TDC), and store scenarios. We enforce enterprise-grade AES-256 and TLS 1.3 encryption protocols across storage and transmission.',
                isDark: isDark,
                delayMs: 180,
              ),
              _buildSectionCard(
                icon: Icons.pie_chart_outline_rounded,
                title: '3. Financial Confidentiality',
                content:
                    'All feasibility studies, yield projections, and cost estimates remain strictly your confidential intellectual property. Valuate never sells, monetizes, or shares proprietary developer data with third-party brokers or advertisers.',
                isDark: isDark,
                delayMs: 260,
              ),
              _buildSectionCard(
                icon: Icons.cloud_done_outlined,
                title: '4. Cloud Storage & Data Sovereignty',
                content:
                    'Portfolio records are maintained in secured cloud infrastructure compliant with regional data sovereignty regulations. You maintain the right to export, modify, or permanently purge any project records at any time.',
                isDark: isDark,
                delayMs: 340,
              ),
              _buildSectionCard(
                icon: Icons.contact_support_outlined,
                title: '5. Contact & Privacy Inquiries',
                content:
                    'For any questions regarding our data privacy framework or to exercise your data rights, contact our Data Protection Officer at privacy@valuate-suite.com.',
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
