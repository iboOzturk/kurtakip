import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String themeKey = 'isDarkMode';
  final _isDarkMode = false.obs;
  final SharedPreferences _prefs;

  ThemeController(this._prefs) {
    _loadThemeFromPrefs();
  }

  bool get isDarkMode => _isDarkMode.value;

  void _loadThemeFromPrefs() {
    _isDarkMode.value = _prefs.getBool(themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _prefs.setBool(themeKey, _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
} 