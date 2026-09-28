import 'package:flutter/material.dart';
import 'storage_service.dart';

class LocalizationService extends ChangeNotifier {
  final StorageService _storageService;
  Locale _currentLocale;

  LocalizationService(this._storageService)
      : _currentLocale = Locale(_storageService.getSelectedLanguage());

  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('ta'), // Tamil
  ];

  String getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'ta':
        return 'தமிழ் (Tamil)';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> changeLocale(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;
    _currentLocale = Locale(languageCode);
    await _storageService.setSelectedLanguage(languageCode);
    notifyListeners();
  }
}
