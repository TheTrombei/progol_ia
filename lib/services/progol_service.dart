import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiniela_model.dart';

/// Servicio encargado de la sincronización, descarga desde GitHub raw,
/// almacenamiento en caché local y fallback offline.
class ProgolService extends ChangeNotifier {
  // URL por defecto del archivo raw en GitHub.
  // Puede ser sobreescrita por el usuario en la app o al cambiar esta constante.
  static const String defaultRawUrl =
      'https://raw.githubusercontent.com/TheTrombei/progol_ia/main/progol_data.json';

  static const String _cacheKey = 'progol_cached_data_v1';
  static const String _urlPrefKey = 'progol_custom_raw_url';
  static const String _lastUpdatePrefKey = 'progol_last_fetch_timestamp';

  ProgolDataResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentUrl = defaultRawUrl;
  DateTime? _lastSyncTime;

  ProgolDataResponse? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentUrl => _currentUrl;
  DateTime? get lastSyncTime => _lastSyncTime;

  ProgolService() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUrl = prefs.getString(_urlPrefKey) ?? defaultRawUrl;
    
    final lastTimeStr = prefs.getString(_lastUpdatePrefKey);
    if (lastTimeStr != null) {
      _lastSyncTime = DateTime.tryParse(lastTimeStr);
    }

    // 1. Cargar caché inmediatamente para UI instantánea
    await _loadFromLocalCache();

    // 2. Si aún no hay datos, cargar los del asset bundled
    if (_data == null) {
      await _loadFromAsset();
    }

    // 3. Sincronizar automáticamente en segundo plano con la nube
    fetchQuinielas();
  }

  /// Carga datos desde SharedPreferences
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJsonStr = prefs.getString(_cacheKey);
      if (cachedJsonStr != null && cachedJsonStr.isNotEmpty) {
        final decoded = json.decode(cachedJsonStr) as Map<String, dynamic>;
        _data = ProgolDataResponse.fromJson(decoded);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ProgolService] Error al leer caché local: $e');
    }
  }

  /// Carga datos iniciales empaquetados en los assets de la app
  Future<void> _loadFromAsset() async {
    try {
      final assetStr = await rootBundle.loadString('assets/progol_data.json');
      final decoded = json.decode(assetStr) as Map<String, dynamic>;
      _data = ProgolDataResponse.fromJson(decoded);
      notifyListeners();
    } catch (e) {
      debugPrint('[ProgolService] Error al leer asset por defecto: $e');
    }
  }

  /// Descarga los datos más recientes desde el Raw de GitHub
  Future<bool> fetchQuinielas({bool isManual = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Agregar parámetro de tiempo para evitar caché de CDN de GitHub
      final uri = Uri.parse('$_currentUrl?t=${DateTime.now().millisecondsSinceEpoch}');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final rawBody = utf8.decode(response.bodyBytes);
        final decoded = json.decode(rawBody) as Map<String, dynamic>;
        
        final parsed = ProgolDataResponse.fromJson(decoded);
        _data = parsed;
        _lastSyncTime = DateTime.now();

        // Guardar en caché persistente SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, rawBody);
        await prefs.setString(_lastUpdatePrefKey, _lastSyncTime!.toIso8601String());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Servidor respondió con código ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ProgolService] Fallo de red: $e');
      _errorMessage = 'No se pudo conectar con GitHub. Mostrando datos locales.';
      
      // Si la memoria está vacía, asegurar que al menos la caché o asset esté cargado
      if (_data == null) {
        await _loadFromLocalCache();
        if (_data == null) await _loadFromAsset();
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Permite actualizar la URL del archivo raw si el usuario usa otro repositorio
  Future<void> updateRawUrl(String newUrl) async {
    if (newUrl.trim().isEmpty) return;
    _currentUrl = newUrl.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlPrefKey, _currentUrl);
    notifyListeners();
    await fetchQuinielas(isManual: true);
  }

  /// Restablece la URL por defecto
  Future<void> resetToDefaultUrl() async {
    _currentUrl = defaultRawUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlPrefKey);
    notifyListeners();
    await fetchQuinielas(isManual: true);
  }
}
