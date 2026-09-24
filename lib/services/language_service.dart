import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _prefKey = 'app_language_code';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get currentLanguageName =>
      languageNames[_currentLocale.languageCode] ?? 'English';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'ta': 'தமிழ்',
    'hi': 'हिन्दी',
  };

  static const Map<String, String> languageSubtitles = {
    'en': 'English (Default)',
    'ta': 'Tamil (தமிழ்)',
    'hi': 'Hindi (हिन्दी)',
  };

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && languageNames.containsKey(savedCode)) {
        _currentLocale = Locale(savedCode);
        notifyListeners();
      }
    } catch (_) {
      // Fall back to English if storage read fails
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!languageNames.containsKey(newLocale.languageCode)) return;
    if (_currentLocale.languageCode == newLocale.languageCode) return;

    _currentLocale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (_) {}
  }
}
