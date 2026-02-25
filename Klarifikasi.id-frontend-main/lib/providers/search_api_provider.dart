/// ============================================================================
/// SEARCH API PROVIDER - KLARIFIKASI.ID FRONTEND
/// ============================================================================
/// Provider untuk mengelola Google Custom Search Engine API Key & CX secara
/// dinamis. Fitur:
/// - Simpan/baca API key & CX dari SharedPreferences
/// - Track penggunaan API (jumlah panggilan & waktu terakhir digunakan)
/// - Deteksi error quota/invalid API key
/// - Notifikasi pop-up ketika API key habis/tidak valid
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// === SEARCH API PROVIDER ===
/// ChangeNotifier yang mengelola seluruh lifecycle Google CSE API Key & CX.
class SearchApiProvider extends ChangeNotifier {
  // === STORAGE KEYS ===
  static const String _keyApiKey = 'cse_api_key';
  static const String _keyCx = 'cse_cx';
  static const String _keyUsageCount = 'cse_usage_count';
  static const String _keyLastUsed = 'cse_last_used';
  static const String _keyLastError = 'cse_last_error';
  static const String _keyDailyUsage = 'cse_daily_usage';
  static const String _keyDailyDate = 'cse_daily_date';

  // === DEFAULT VALUES ===
  static const String _defaultApiKey =
      'AIzaSyAFOdoaMwgurnjfnhGKn5GFy6_m2HKiGtA';
  static const String _defaultCx = '6242f5825dedb4b59';

  // === INTERNAL STATE ===
  String _apiKey = _defaultApiKey;
  String _cx = _defaultCx;
  int _totalUsageCount = 0;
  int _dailyUsageCount = 0;
  String _dailyDate = '';
  DateTime? _lastUsedTime;
  String? _lastError;
  bool _isKeyExpired = false;
  bool _isLoading = true;

  // === GETTERS ===
  /// API key aktif yang sedang digunakan
  String get apiKey => _apiKey;

  /// Search Engine ID (CX) aktif
  String get cx => _cx;

  /// Total berapa kali API dipanggil sejak pertama kali diinstal
  int get totalUsageCount => _totalUsageCount;

  /// Jumlah penggunaan API hari ini
  int get dailyUsageCount => _dailyUsageCount;

  /// Waktu terakhir API dipanggil
  DateTime? get lastUsedTime => _lastUsedTime;

  /// Error terakhir dari API
  String? get lastError => _lastError;

  /// Apakah API key sudah tidak bisa dipakai (expired/quota habis)
  bool get isKeyExpired => _isKeyExpired;

  /// Apakah masih loading data dari storage
  bool get isLoading => _isLoading;

  /// Cek apakah menggunakan API key custom (bukan default)
  bool get isUsingCustomKey => _apiKey != _defaultApiKey;

  /// Cek apakah menggunakan CX custom (bukan default)
  bool get isUsingCustomCx => _cx != _defaultCx;

  /// API key yang di-mask untuk ditampilkan di UI
  String get maskedApiKey {
    if (_apiKey.length <= 12) return '****';
    return '${_apiKey.substring(0, 8)}...${_apiKey.substring(_apiKey.length - 4)}';
  }

  /// CX yang di-mask untuk ditampilkan di UI
  String get maskedCx {
    if (_cx.length <= 8) return '****';
    return '${_cx.substring(0, 4)}...${_cx.substring(_cx.length - 4)}';
  }

  // === CONSTRUCTOR ===
  SearchApiProvider() {
    _loadFromStorage();
  }

  // === LOAD DATA DARI STORAGE ===
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _apiKey = prefs.getString(_keyApiKey) ?? _defaultApiKey;
      _cx = prefs.getString(_keyCx) ?? _defaultCx;
      _totalUsageCount = prefs.getInt(_keyUsageCount) ?? 0;
      _dailyUsageCount = prefs.getInt(_keyDailyUsage) ?? 0;
      _dailyDate = prefs.getString(_keyDailyDate) ?? '';
      _lastError = prefs.getString(_keyLastError);

      final lastUsedStr = prefs.getString(_keyLastUsed);
      if (lastUsedStr != null) {
        _lastUsedTime = DateTime.tryParse(lastUsedStr);
      }

      // Reset daily counter jika hari sudah berganti
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (_dailyDate != today) {
        _dailyUsageCount = 0;
        _dailyDate = today;
        await prefs.setInt(_keyDailyUsage, 0);
        await prefs.setString(_keyDailyDate, today);
      }

      _isKeyExpired = false;
    } catch (e) {
      debugPrint('SearchApiProvider: Error loading from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // === UPDATE API KEY ===
  Future<void> updateApiKey(String newKey) async {
    final trimmedKey = newKey.trim();
    if (trimmedKey.isEmpty) return;

    _apiKey = trimmedKey;
    _isKeyExpired = false;
    _lastError = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, trimmedKey);
      await prefs.remove(_keyLastError);
    } catch (e) {
      debugPrint('SearchApiProvider: Error saving API key: $e');
    }

    notifyListeners();
  }

  // === UPDATE CX ===
  Future<void> updateCx(String newCx) async {
    final trimmedCx = newCx.trim();
    if (trimmedCx.isEmpty) return;

    _cx = trimmedCx;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCx, trimmedCx);
    } catch (e) {
      debugPrint('SearchApiProvider: Error saving CX: $e');
    }

    notifyListeners();
  }

  // === RESET KE DEFAULT ===
  Future<void> resetToDefault() async {
    _apiKey = _defaultApiKey;
    _cx = _defaultCx;
    _isKeyExpired = false;
    _lastError = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, _defaultApiKey);
      await prefs.setString(_keyCx, _defaultCx);
      await prefs.remove(_keyLastError);
    } catch (e) {
      debugPrint('SearchApiProvider: Error resetting to default: $e');
    }

    notifyListeners();
  }

  // === RECORD PENGGUNAAN ===
  Future<void> recordUsage() async {
    _totalUsageCount++;
    _dailyUsageCount++;
    _lastUsedTime = DateTime.now();

    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_dailyDate != today) {
      _dailyUsageCount = 1;
      _dailyDate = today;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUsageCount, _totalUsageCount);
      await prefs.setInt(_keyDailyUsage, _dailyUsageCount);
      await prefs.setString(_keyDailyDate, _dailyDate);
      await prefs.setString(_keyLastUsed, _lastUsedTime!.toIso8601String());
    } catch (e) {
      debugPrint('SearchApiProvider: Error saving usage: $e');
    }

    notifyListeners();
  }

  // === RECORD ERROR ===
  Future<void> recordError(int statusCode, String errorMessage) async {
    _lastError = errorMessage;

    if (statusCode == 400 || statusCode == 403 || statusCode == 429) {
      _isKeyExpired = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastError, errorMessage);
    } catch (e) {
      debugPrint('SearchApiProvider: Error saving error: $e');
    }

    notifyListeners();
  }

  // === CLEAR ERROR STATE ===
  void clearError() {
    _isKeyExpired = false;
    _lastError = null;
    notifyListeners();
  }

  // === RESET STATISTIK ===
  Future<void> resetUsageStats() async {
    _totalUsageCount = 0;
    _dailyUsageCount = 0;
    _lastUsedTime = null;
    _lastError = null;
    _isKeyExpired = false;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    _dailyDate = today;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUsageCount, 0);
      await prefs.setInt(_keyDailyUsage, 0);
      await prefs.setString(_keyDailyDate, today);
      await prefs.remove(_keyLastUsed);
      await prefs.remove(_keyLastError);
    } catch (e) {
      debugPrint('SearchApiProvider: Error resetting stats: $e');
    }

    notifyListeners();
  }

  // === FORMAT WAKTU TERAKHIR DIGUNAKAN ===
  String get lastUsedDisplay {
    if (_lastUsedTime == null) return 'Belum pernah digunakan';

    final now = DateTime.now();
    final diff = now.difference(_lastUsedTime!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

    return '${_lastUsedTime!.day}/${_lastUsedTime!.month}/${_lastUsedTime!.year}';
  }
}
