/// ============================================================================
/// GEMINI API PROVIDER - KLARIFIKASI.ID FRONTEND
/// ============================================================================
/// Provider untuk mengelola Gemini API Key secara dinamis.
/// Fitur:
/// - Simpan/baca API key dari SharedPreferences
/// - Track penggunaan API (jumlah panggilan & waktu terakhir digunakan)
/// - Deteksi error quota/invalid API key
/// - Notifikasi pop-up ketika API key habis/tidak valid
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// === GEMINI API PROVIDER ===
/// ChangeNotifier yang mengelola seluruh lifecycle Gemini API Key.
class GeminiApiProvider extends ChangeNotifier {
  // === STORAGE KEYS ===
  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyUsageCount = 'gemini_usage_count';
  static const String _keyLastUsed = 'gemini_last_used';
  static const String _keyLastError = 'gemini_last_error';
  static const String _keyDailyUsage = 'gemini_daily_usage';
  static const String _keyDailyDate = 'gemini_daily_date';

  // === DEFAULT API KEY ===
  static const String _defaultApiKey =
      'AIzaSyAnD4JUB291cnSR1sghyQTD6Q4gSrzBQ_4';

  // === INTERNAL STATE ===
  String _apiKey = _defaultApiKey;
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

  /// API key yang di-mask untuk ditampilkan di UI
  String get maskedApiKey {
    if (_apiKey.length <= 12) return '****';
    return '${_apiKey.substring(0, 8)}...${_apiKey.substring(_apiKey.length - 4)}';
  }

  // === CONSTRUCTOR ===
  GeminiApiProvider() {
    _loadFromStorage();
  }

  // === LOAD DATA DARI STORAGE ===
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _apiKey = prefs.getString(_keyApiKey) ?? _defaultApiKey;
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

      // Reset expired state jika user baru ganti key
      _isKeyExpired = false;
    } catch (e) {
      debugPrint('GeminiApiProvider: Error loading from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // === UPDATE API KEY ===
  /// Mengganti API key dengan key baru.
  /// Otomatis reset error state karena key baru belum dicoba.
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
      debugPrint('GeminiApiProvider: Error saving API key: $e');
    }

    notifyListeners();
  }

  // === RESET KE DEFAULT KEY ===
  /// Mengembalikan API key ke default bawaan aplikasi.
  Future<void> resetToDefaultKey() async {
    await updateApiKey(_defaultApiKey);
  }

  // === RECORD PENGGUNAAN ===
  /// Dipanggil setiap kali API Gemini berhasil digunakan.
  Future<void> recordUsage() async {
    _totalUsageCount++;
    _dailyUsageCount++;
    _lastUsedTime = DateTime.now();

    // Reset daily jika hari berganti
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
      debugPrint('GeminiApiProvider: Error saving usage: $e');
    }

    notifyListeners();
  }

  // === RECORD ERROR ===
  /// Dipanggil ketika API Gemini mengembalikan error.
  /// Jika error terkait quota atau API key invalid, otomatis set isKeyExpired.
  Future<void> recordError(int statusCode, String errorMessage) async {
    _lastError = errorMessage;

    // Deteksi error quota habis atau API key tidak valid
    if (statusCode == 400 || statusCode == 403 || statusCode == 429) {
      _isKeyExpired = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastError, errorMessage);
    } catch (e) {
      debugPrint('GeminiApiProvider: Error saving error: $e');
    }

    notifyListeners();
  }

  // === CLEAR ERROR STATE ===
  /// Reset error state (misalnya setelah user mengganti API key).
  void clearError() {
    _isKeyExpired = false;
    _lastError = null;
    notifyListeners();
  }

  // === RESET STATISTIK ===
  /// Reset semua statistik penggunaan ke nol.
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
      debugPrint('GeminiApiProvider: Error resetting stats: $e');
    }

    notifyListeners();
  }

  // === FORMAT WAKTU TERAKHIR DIGUNAKAN ===
  /// Mengembalikan string yang user-friendly untuk waktu terakhir digunakan.
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
