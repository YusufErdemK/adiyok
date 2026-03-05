import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _aiEnabledKey = 'ai_enabled';
  static const String _groqTokenKey = 'groq_token';

  bool _darkMode = false;
  bool _aiEnabled = false;
  String _groqToken = '';

  bool get darkMode => _darkMode;
  bool get aiEnabled => _aiEnabled;
  String get groqToken => _groqToken;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _aiEnabled = prefs.getBool(_aiEnabledKey) ?? false;
    _groqToken = prefs.getString(_groqTokenKey) ?? '';

    if (_aiEnabled && _groqToken.trim().isEmpty) {
      _aiEnabled = false;
      await prefs.setBool(_aiEnabledKey, false);
    }

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setAiEnabled(bool value) async {
    if (value && _groqToken.trim().isEmpty) {
      return;
    }

    _aiEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiEnabledKey, value);
  }

  Future<void> setGroqToken(String value) async {
    _groqToken = value.trim();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groqTokenKey, _groqToken);
  }
}
