import 'dart:convert';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String keyToken = 'auth_token';
  static const String keyUser = 'auth_user';
  static const String keyTheme = 'app_theme_mode';
  static const String keyLocale = 'app_locale';
  static const String keyCurrency = 'app_currency';
  static const String keyUnit = 'app_area_unit';
  static const String keyProjects = 'saved_feasibility_projects';
  static const String keyOnboarding = 'onboarding_completed';
  static const String keyIsGuest = 'is_guest_mode';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // Onboarding
  bool isOnboardingCompleted() => _prefs.getBool(keyOnboarding) ?? false;
  Future<bool> setOnboardingCompleted(bool completed) =>
      _prefs.setBool(keyOnboarding, completed);

  // Guest Mode
  bool isGuestMode() => _prefs.getBool(keyIsGuest) ?? false;
  Future<bool> setGuestMode(bool isGuest) => _prefs.setBool(keyIsGuest, isGuest);

  // Auth Token
  String? getToken() => _prefs.getString(keyToken);
  Future<bool> setToken(String token) => _prefs.setString(keyToken, token);
  Future<bool> clearToken() => _prefs.remove(keyToken);

  // User details
  Map<String, dynamic>? getUser() {
    final userJson = _prefs.getString(keyUser);
    if (userJson == null) return null;
    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> setUser(Map<String, dynamic> user) =>
      _prefs.setString(keyUser, jsonEncode(user));

  Future<bool> clearUser() async {
    await _prefs.remove(keyUser);
    await _prefs.remove(keyIsGuest);
    return true;
  }

  // Theme (dark / light)
  String getThemeMode() => _prefs.getString(keyTheme) ?? 'dark';
  Future<bool> setThemeMode(String theme) => _prefs.setString(keyTheme, theme);

  // Locale (en / ar - defaults to device system language)
  String getLocale() {
    final saved = _prefs.getString(keyLocale);
    if (saved != null) return saved;

    try {
      final systemLang =
          ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      if (systemLang.startsWith('ar')) {
        return 'ar';
      }
    } catch (_) {}
    return 'en';
  }
  Future<bool> setLocale(String locale) => _prefs.setString(keyLocale, locale);

  // Currency (SAR, AED, USD, EGP, QAR, KWD)
  String getCurrency() => _prefs.getString(keyCurrency) ?? 'SAR';
  Future<bool> setCurrency(String currency) => _prefs.setString(keyCurrency, currency);

  // Area unit (sqm, sqft)
  String getUnit() => _prefs.getString(keyUnit) ?? 'sqm';
  Future<bool> setUnit(String unit) => _prefs.setString(keyUnit, unit);

  // Saved Projects
  List<Map<String, dynamic>> getSavedProjects() {
    final raw = _prefs.getString(keyProjects);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveProjects(List<Map<String, dynamic>> projects) =>
      _prefs.setString(keyProjects, jsonEncode(projects));
}
