import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('pt', 'BR'); // Default to PT-BR
  
  Locale get currentLocale => _currentLocale;
  
  // Language options with their display names and flag emojis
  static const Map<String, Map<String, String>> supportedLanguages = {
    'pt_BR': {
      'name': 'Português (Brasil)',
      'flag': '🇧🇷',
      'languageCode': 'pt',
      'countryCode': 'BR',
    },
    'pt_PT': {
      'name': 'Português (Portugal)',
      'flag': '🇵🇹',
      'languageCode': 'pt',
      'countryCode': 'PT',
    },
    'pt_AO': {
      'name': 'Português (Angola)',
      'flag': '🇦🇴',
      'languageCode': 'pt',
      'countryCode': 'AO',
    },
    'en': {
      'name': 'English',
      'flag': '🇺🇸',
      'languageCode': 'en',
      'countryCode': '',
    },
    'fr': {
      'name': 'Français',
      'flag': '🇫🇷',
      'languageCode': 'fr',
      'countryCode': '',
    },
    'es': {
      'name': 'Español',
      'flag': '🇪🇸',
      'languageCode': 'es',
      'countryCode': '',
    },
    'ru': {
      'name': 'Русский',
      'flag': '🇷🇺',
      'languageCode': 'ru',
      'countryCode': '',
    },
    'zh': {
      'name': '中文',
      'flag': '🇨🇳',
      'languageCode': 'zh',
      'countryCode': '',
    },
  };
  
  // Initialize the service and load saved locale
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null && supportedLanguages.containsKey(savedLocale)) {
      final languageData = supportedLanguages[savedLocale]!;
      _currentLocale = Locale(
        languageData['languageCode']!,
        languageData['countryCode']!.isEmpty ? null : languageData['countryCode'],
      );
      notifyListeners();
    }
  }
  
  // Change the current locale
  Future<void> setLocale(String languageKey) async {
    print('LocalizationService: setLocale called with $languageKey');
    if (!supportedLanguages.containsKey(languageKey)) {
      print('LocalizationService: Language key $languageKey not supported');
      return;
    }
    
    final languageData = supportedLanguages[languageKey]!;
    final newLocale = Locale(
      languageData['languageCode']!,
      languageData['countryCode']!.isEmpty ? null : languageData['countryCode'],
    );
    
    print('LocalizationService: Current locale: $_currentLocale, New locale: $newLocale');
    
    _currentLocale = newLocale;
    print('LocalizationService: Locale changed to $_currentLocale');
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageKey);
    print('LocalizationService: Saved to preferences: $languageKey');
    
    print('LocalizationService: Calling notifyListeners()');
    notifyListeners();
    print('LocalizationService: notifyListeners() called');
  }
  
  // Get current language key
  String getCurrentLanguageKey() {
    print('getCurrentLanguageKey: Current locale is $_currentLocale');
    print('getCurrentLanguageKey: Language code: ${_currentLocale.languageCode}, Country code: ${_currentLocale.countryCode}');
    
    for (final entry in supportedLanguages.entries) {
      final data = entry.value;
      final languageCode = data['languageCode']!;
      final countryCode = data['countryCode']!;
      
      print('Checking $entry.key: languageCode=$languageCode, countryCode=$countryCode');
      
      // Para idiomas sem código de país (en, fr, es, ru, zh)
      if (countryCode.isEmpty) {
        if (languageCode == _currentLocale.languageCode && _currentLocale.countryCode == null) {
          print('Match found for ${entry.key} (no country code)');
          return entry.key;
        }
      } else {
        // Para idiomas com código de país (pt_BR, pt_PT, pt_AO)
        if (languageCode == _currentLocale.languageCode && countryCode == _currentLocale.countryCode) {
          print('Match found for ${entry.key} (with country code)');
          return entry.key;
        }
      }
    }
    
    print('No match found, returning default pt_BR');
    return 'pt_BR'; // Default fallback
  }
  
  // Get language display name
  String getLanguageName(String languageKey) {
    return supportedLanguages[languageKey]?['name'] ?? 'Unknown';
  }
  
  // Get language flag emoji
  String getLanguageFlag(String languageKey) {
    return supportedLanguages[languageKey]?['flag'] ?? '🏳️';
  }
  
  // Get all supported language keys
  List<String> getSupportedLanguageKeys() {
    return supportedLanguages.keys.toList();
  }
}