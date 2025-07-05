import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  final List<Language> languages = [
    Language('Bahasa Indonesia', 'ID'),
    Language('English', 'EN'),
    Language('中文', 'CN'),
  ];

  String language = "EN";
  bool isLoading = false;

  LanguageProvider() {
    loadLanguageToPrefs();
  }

  Future<void> saveLanguageToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<void> loadLanguageToPrefs() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('language');
    language = encoded!;
    isLoading = false;
    notifyListeners();
  }

  void switchLanguage(String lang) {
    language = lang;
    saveLanguageToPrefs();
    notifyListeners();
  }
}

class Language {
  Language(this.label, this.value);
  final String label;
  final String value;
}
