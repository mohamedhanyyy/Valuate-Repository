import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/preferences_service.dart';

class LocaleCubit extends Cubit<String> {
  final PreferencesService preferencesService;

  LocaleCubit(this.preferencesService)
      : super(preferencesService.getLocale());

  void toggleLocale() {
    final next = state == 'en' ? 'ar' : 'en';
    setLocale(next);
  }

  void setLocale(String locale) {
    preferencesService.setLocale(locale);
    emit(locale);
  }

  bool get isArabic => state == 'ar';
}
