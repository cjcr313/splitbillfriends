import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Comenzamos con el Dark Theme por defecto porque es moderno
  AppThemeMode _currentMode = AppThemeMode.dark;

  AppThemeMode get currentMode => _currentMode;

  ThemeData get currentThemeData {
    switch (_currentMode) {
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.neon:
        return AppTheme.neonTheme;
    }
  }

  void setThemeMode(AppThemeMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  /// Cambia al siguiente tema en secuencia para el botón de prueba temporal
  void cycleTheme() {
    if (_currentMode == AppThemeMode.light) {
      setThemeMode(AppThemeMode.dark);
    } else if (_currentMode == AppThemeMode.dark) {
      setThemeMode(AppThemeMode.neon);
    } else {
      setThemeMode(AppThemeMode.light);
    }
  }
}
