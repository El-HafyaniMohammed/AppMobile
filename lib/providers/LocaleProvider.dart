import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('fr');

  LocaleProvider() {
    _loadLocaleFromStorage();
  }

  Locale get locale => _locale;

  Future<void> _loadLocaleFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLocaleCode = prefs.getString(_localeKey);
    
    if (storedLocaleCode != null) {
      _locale = Locale(storedLocaleCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    // Persist locale selection
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  // Supported locales for easy reference
  static List<Locale> get supportedLocales => [
    const Locale('fr'),
    const Locale('en'),
    const Locale('ar'),
    const Locale('es'),
  ];

  // Helper method to get language name
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'العربية';
      case 'es': return 'Español';
      default: return locale.languageCode;
    }
  }
}