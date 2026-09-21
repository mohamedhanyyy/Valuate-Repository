import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/preferences_service.dart';
import '../../cubits/locale/locale_cubit.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skyline_widget.dart';
import '../../widgets/theme_lang_bar.dart';
import '../../widgets/valuate_logo.dart';
import '../auth/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final PreferencesService preferencesService;

  const OnboardingScreen({super.key, required this.preferencesService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await widget.preferencesService.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    final slides = [
      _OnboardingSlideData(
        tag: locale == 'ar'
            ? 'ذكاء الاستثمار العقاري'
            : 'REAL ESTATE INTELLIGENCE',
        title: AppStrings.get('brandTagline', locale: locale),
        description: AppStrings.get('brandDescription', locale: locale),
        visual: _buildFeasibilityVisual(isDark, locale),
      ),
      _OnboardingSlideData(
        tag: locale == 'ar'
            ? 'حاسبة القرار والسيناريوهات'
            : 'PRECISION RISK & SENSITIVITY',
        title: locale == 'ar'
            ? 'نمذجة مالية متقدمة واختبار فوري للحساسية والمخاطر'
            : 'Automated Feasibility Engine & Dynamic Stress Testing',
        description: locale == 'ar'
            ? 'احسب عوائد الـ ROI والـ IRR ومضاعف الملكية MOIC لحظياً، واختبر السيناريوهات المتفائلة والمتحفظة لتجنب المخاطر.'
            : 'Instantly calculate ROI, IRR, MOIC, profit margins, and dynamic Bear/Base/Bull sensitivity scenarios.',
        visual: _buildCalculatorVisual(isDark, locale),
      ),
      _OnboardingSlideData(
        tag: locale == 'ar'
            ? 'المحافظ المجمعة وبيانات السوق'
            : 'PORTFOLIO & LIVE BENCHMARKS',
        title: locale == 'ar'
            ? 'إدارة متكاملة للمحافظ الاستثمارية ومؤشرات أسواق الشرق الأوسط'
            : 'Consolidated Multi-Asset Portfolios & Regional Intelligence',
        description: locale == 'ar'
            ? 'تتبع جميع تكاليفك وإيراداتك في لوحة مركزية واحدة، مع مؤشرات تكاليف البناء المباشرة لأسواق السعودية والإمارات ومصر وقطر.'
            : 'Track costs, revenues, and sales across consolidated assets with live construction cost benchmarks for KSA, UAE, Egypt, and Qatar.',
        visual: _buildMarketVisual(isDark, locale),
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Bar (Logo + Theme/Lang + Skip)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValuateLogo(height: 32, isDark: isDark),
                  Row(
                    children: [
                      const ThemeLangBar(),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          locale == 'ar' ? 'تخطي' : 'Skip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // PageView Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Visual Container
                          slide.visual,
                          const SizedBox(height: 24),

                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkAccent.withValues(alpha: 0.15)
                                  : AppColors.lightAccent.withValues(
                                      alpha: 0.12,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              slide.tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Title
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Controls (Pills + CTA)
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryBlue
                          : (isDark
                                ? AppColors.darkBorderSoft
                                : AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              PrimaryButton(
                text: _currentPage == slides.length - 1
                    ? (locale == 'ar'
                          ? 'ابدأ الآن / تسجيل الدخول'
                          : 'Get Started / Sign In')
                    : (locale == 'ar' ? 'التالي' : 'Next'),
                backgroundColor: AppColors.primaryBlue,
                onPressed: () {
                  if (_currentPage < slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeasibilityVisual(bool isDark, String locale) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkBrandBg1, AppColors.darkBrandBg2]
              : [AppColors.lightBrandBg1, AppColors.lightBrandBg2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorderSoft : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SkylineWidget(height: 85, isDark: isDark),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricPill(
                label: 'ROI',
                value: '58.2%',
                color: AppColors.success,
                isDark: isDark,
              ),
              _metricPill(
                label: 'IRR',
                value: '21.7%',
                color: AppColors.primaryBlue,
                isDark: isDark,
              ),
              _metricPill(
                label: 'MOIC',
                value: '1.58x',
                color: AppColors.purple,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorVisual(bool isDark, String locale) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Verdict Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      locale == 'ar'
                          ? 'قرار استثماري: مجدي (GO)'
                          : 'Verdict: GO (Viable)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                Text(
                  '94 / 100',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Sensitivity Scenarios preview
          Row(
            children: [
              Expanded(
                child: _scenarioMiniCard(
                  title: locale == 'ar' ? 'متحفظ (-10%)' : 'Bear (-10%)',
                  roi: '42.1%',
                  color: AppColors.danger,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _scenarioMiniCard(
                  title: locale == 'ar' ? 'أساسي' : 'Base Case',
                  roi: '58.2%',
                  color: AppColors.primaryBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _scenarioMiniCard(
                  title: locale == 'ar' ? 'متفائل (+10%)' : 'Bull (+10%)',
                  roi: '74.8%',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketVisual(bool isDark, String locale) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'ar'
                    ? 'مؤشرات أسواق الشرق الأوسط الحية'
                    : 'Live MENA Regional Benchmarks',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const Icon(Icons.public_rounded, color: AppColors.primaryBlue, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          _marketRow(
            '🇸🇦 الرياض / الرياض',
            '3,450 SAR/m²',
            '+4.2%',
            AppColors.success,
            isDark,
          ),
          const SizedBox(height: 6),
          _marketRow(
            '🇦🇪 دبي / دبي',
            '4,200 AED/m²',
            '+3.8%',
            AppColors.success,
            isDark,
          ),
          const SizedBox(height: 6),
          _marketRow(
            '🇪🇬 القاهرة / التجمع',
            '32,500 EGP/m²',
            '+8.5%',
            AppColors.primaryBlue,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _metricPill({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scenarioMiniCard({
    required String title,
    required String roi,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceHover
            : AppColors.lightSurfaceHover,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            roi,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _marketRow(
    String name,
    String cost,
    String change,
    Color badgeColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceHover
            : AppColors.lightSurfaceHover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          Row(
            children: [
              Text(
                cost,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  final String tag;
  final String title;
  final String description;
  final Widget visual;

  _OnboardingSlideData({
    required this.tag,
    required this.title,
    required this.description,
    required this.visual,
  });
}
