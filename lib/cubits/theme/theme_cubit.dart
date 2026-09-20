import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/preferences_service.dart';

class ThemeCubit extends Cubit<bool> {
  final PreferencesService preferencesService;

  // true = isDarkMode, false = isLightMode
  ThemeCubit(this.preferencesService)
      : super(preferencesService.getThemeMode() == 'dark');

  void toggleTheme() {
    final newMode = !state;
    preferencesService.setThemeMode(newMode ? 'dark' : 'light');
    emit(newMode);
  }

  void setDarkMode(bool isDark) {
    preferencesService.setThemeMode(isDark ? 'dark' : 'light');
    emit(isDark);
  }
}
