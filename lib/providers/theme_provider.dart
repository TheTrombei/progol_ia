import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/artistic_palettes.dart';

class ThemeProvider extends ChangeNotifier {
  ArtisticPalette _currentPalette = ArtisticPalette.allPalettes.first;
  bool _isDark = true;
  double _poeticFontSize = 18.0;
  String _geminiApiKey = '';
  bool _isInitialized = false;

  ArtisticPalette get currentPalette => _currentPalette;
  bool get isDark => _isDark;
  double get poeticFontSize => _poeticFontSize;
  String get geminiApiKey => _geminiApiKey;
  bool get hasGeminiKey => _geminiApiKey.trim().isNotEmpty;
  bool get isInitialized => _isInitialized;

  ThemeData get themeData => _currentPalette.buildTheme(isDark: _isDark);

  Future<void> init() async {
    final paletteName = await StorageService.loadPaletteName();
    _isDark = await StorageService.loadIsDark();
    _geminiApiKey = await StorageService.loadGeminiApiKey();
    _poeticFontSize = await StorageService.loadPoeticFontSize();

    final match = ArtisticPalette.allPalettes.firstWhere(
      (p) => p.type.name.toLowerCase() == paletteName.toLowerCase(),
      orElse: () => ArtisticPalette.allPalettes.first,
    );
    _currentPalette = match;
    _isInitialized = true;
    notifyListeners();
  }

  void setPalette(ArtisticPalette palette) {
    _currentPalette = palette;
    StorageService.savePaletteName(palette.type.name);
    notifyListeners();
  }

  void toggleThemeMode() {
    _isDark = !_isDark;
    StorageService.saveIsDark(_isDark);
    notifyListeners();
  }

  void setIsDark(bool value) {
    _isDark = value;
    StorageService.saveIsDark(_isDark);
    notifyListeners();
  }

  void setPoeticFontSize(double size) {
    _poeticFontSize = size.clamp(14.0, 30.0);
    StorageService.savePoeticFontSize(_poeticFontSize);
    notifyListeners();
  }

  void setGeminiApiKey(String key) {
    _geminiApiKey = key.trim();
    StorageService.saveGeminiApiKey(_geminiApiKey);
    notifyListeners();
  }
}
