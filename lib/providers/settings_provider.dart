import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _aiEnabledKey = 'ai_enabled';
  static const String _groqApiKeyKey = 'groq_api_key';

  bool _darkMode = false;
  bool _aiEnabled = false;
  String _groqApiKey = '';

  bool get darkMode => _darkMode;
  bool get aiEnabled => _aiEnabled;
  String get groqApiKey => _groqApiKey;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _aiEnabled = prefs.getBool(_aiEnabledKey) ?? false;
    _groqApiKey = prefs.getString(_groqApiKeyKey) ?? '';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setAiEnabled(bool value) async {
    _aiEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiEnabledKey, value);
  }

  Future<void> setGroqApiKey(String value) async {
    _groqApiKey = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groqApiKeyKey, value);
  }
}
