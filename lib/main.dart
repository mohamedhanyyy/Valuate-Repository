import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/services/preferences_service.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/locale/locale_cubit.dart';

import 'cubits/market/market_cubit.dart';
import 'cubits/projects/projects_cubit.dart';
import 'cubits/theme/theme_cubit.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'widgets/common/app_snack_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesService = await PreferencesService.init();
  final dioClient = DioClient(preferencesService: preferencesService);

  runApp(
    ValuateApp(preferencesService: preferencesService, dioClient: dioClient),
  );
}

class ValuateApp extends StatelessWidget {
  final PreferencesService preferencesService;
  final DioClient dioClient;

  const ValuateApp({
    super.key,
    required this.preferencesService,
    required this.dioClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(preferencesService)),
        BlocProvider(create: (_) => LocaleCubit(preferencesService)),
        BlocProvider(
          create: (_) => AuthCubit(
            dioClient: dioClient,
            preferencesService: preferencesService,
          )..checkAuthStatus(),
        ),

        BlocProvider(
          create: (_) => ProjectsCubit(
            preferencesService: preferencesService,
            dioClient: dioClient,
          )..loadProjects(),
        ),
        BlocProvider(create: (_) => MarketCubit()..loadBenchmarks()),
      ],
      child: _ValuateAppView(preferencesService: preferencesService),
    );
  }
}

class _ValuateAppView extends StatelessWidget {
  final PreferencesService preferencesService;

  const _ValuateAppView({required this.preferencesService});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return MaterialApp(
      navigatorKey: AppSnackBar.navigatorKey,
      title: 'Valuate — Real Estate Intelligence',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.getLightTheme(locale: locale),
      darkTheme: AppTheme.getDarkTheme(locale: locale),
      locale: Locale(locale),
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (!preferencesService.isOnboardingCompleted()) {
            return OnboardingScreen(preferencesService: preferencesService);
          }
          if (state is Authenticated) {
            return const MainShellScreen();
          }
          return const SignInScreen();
        },
      ),
    );
  }
}
