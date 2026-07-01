// ==============================================================================
// SEARCH API PROVIDER - KLARIP
// ==============================================================================
// File ini mengelola API key dan CX (Search Engine ID) untuk Google Custom
// Search Engine (CSE) — layanan pencarian khusus dari Google.
//
// APA ITU GOOGLE CUSTOM SEARCH ENGINE (CSE)?
// CSE adalah mesin pencari yang bisa dikonfigurasi untuk mencari hanya pada
// website-website tertentu. Misalnya: "cari hanya di detik.com, kompas.com,
// dan tempo.co". Ini digunakan agar pencarian klaim di Klarip hanya menemukan
// hasil dari sumber berita terpercaya Indonesia.
//
// PERBEDAAN DENGAN GeminiApiProvider:
// - GeminiApiProvider: API key BISA diganti pengguna
// - SearchApiProvider: API key dan CX TIDAK BISA diganti (terkunci ke default)
//   Ini karena CSE sudah dikonfigurasi khusus untuk sumber berita Indonesia.
//
// APA YANG DIKELOLA:
// 1. Menyediakan API key CSE dan CX ke SearchApi saat pencarian dilakukan
// 2. Melacak statistik penggunaan (total & harian)
// 3. Mendeteksi error quota/key tidak valid
// ==============================================================================
library;

import 'package:flutter/material.dart'; // Untuk ChangeNotifier
import 'package:shared_preferences/shared_preferences.dart'; // Penyimpanan lokal

/// Provider yang mengelola Google Custom Search Engine API Key dan CX.
/// Berbeda dengan GeminiApiProvider, API key dan CX di sini TIDAK bisa diubah
/// oleh pengguna karena sudah terikat dengan konfigurasi CSE yang spesifik.
class SearchApiProvider extends ChangeNotifier {
  // ==========================================================================
  // KUNCI PENYIMPANAN (STORAGE KEYS)
  // ==========================================================================
  // Nama-nama "laci" di SharedPreferences untuk menyimpan data statistik.
  static const String _keyUsageCount = 'cse_usage_count';   // Total penggunaan
  static const String _keyLastUsed = 'cse_last_used';       // Waktu terakhir dipakai
  static const String _keyLastError = 'cse_last_error';     // Error terakhir
  static const String _keyDailyUsage = 'cse_daily_usage';   // Penggunaan hari ini
  static const String _keyDailyDate = 'cse_daily_date';     // Tanggal hitung harian

  // ==========================================================================
  // NILAI DEFAULT (TERKUNCI)
  // ==========================================================================
  // Ini adalah nilai yang TIDAK BISA DIUBAH pengguna.
  //
  // _defaultApiKey: API key Google Cloud untuk mengakses Custom Search JSON API
  //                 Format: dimulai dengan 'AIzaSy' (standar Google Cloud)
  //
  // _defaultCx: Search Engine ID — identifikasi mesin pencari kustom yang sudah
  //             dikonfigurasi di https://programmablesearchengine.google.com
  //             Berisi daftar website sumber berita Indonesia yang dicari
  static const String _defaultApiKey = 'AIzaSyAFOdoaMwgurnjfnhGKn5GFy6_m2HKiGtA';
  static const String _defaultCx = '6242f5825dedb4b59';

  // ==========================================================================
  // DATA INTERNAL (STATE)
  // ==========================================================================
  String _apiKey = _defaultApiKey;  // API key aktif (selalu sama dengan default)
  String _cx = _defaultCx;          // CX aktif (selalu sama dengan default)
  int _totalUsageCount = 0;          // Total berapa kali CSE sudah dipanggil
  int _dailyUsageCount = 0;          // Berapa kali CSE dipanggil HARI INI
  String _dailyDate = '';            // Tanggal terakhir penghitung harian direset
  DateTime? _lastUsedTime;           // Kapan terakhir kali CSE dipanggil
  String? _lastError;                // Pesan error terakhir dari CSE
  bool _isKeyExpired = false;        // true = CSE API tidak bisa dipakai
  bool _isLoading = true;            // true = sedang memuat data

  // ==========================================================================
  // GETTERS (PROPERTI PUBLIK)
  // ==========================================================================

  /// API key CSE yang aktif digunakan
  String get apiKey => _apiKey;

  /// Search Engine ID (CX) yang aktif digunakan
  String get cx => _cx;

  /// Total penggunaan CSE sejak pertama kali diinstal
  int get totalUsageCount => _totalUsageCount;

  /// Penggunaan CSE hari ini
  int get dailyUsageCount => _dailyUsageCount;

  /// Kapan terakhir kali CSE dipanggil
  DateTime? get lastUsedTime => _lastUsedTime;

  /// Pesan error terakhir dari CSE. null jika tidak ada error.
  String? get lastError => _lastError;

  /// true jika CSE API tidak bisa digunakan
  bool get isKeyExpired => _isKeyExpired;

  /// true jika sedang memuat data dari penyimpanan
  bool get isLoading => _isLoading;

  /// Selalu false karena Search API tidak bisa menggunakan key kustom
  bool get isUsingCustomKey => false;

  /// Selalu false karena CX tidak bisa diubah pengguna
  bool get isUsingCustomCx => false;

  /// API key yang sudah disembunyikan sebagian untuk ditampilkan di UI
  String get maskedApiKey {
    if (_apiKey.length <= 12) return '****';
    return '${_apiKey.substring(0, 8)}...${_apiKey.substring(_apiKey.length - 4)}';
  }

  /// CX yang sudah disembunyikan sebagian untuk ditampilkan di UI
  String get maskedCx {
    if (_cx.length <= 8) return '****';
    return '${_cx.substring(0, 4)}...${_cx.substring(_cx.length - 4)}';
  }

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================
  /// Saat SearchApiProvider pertama kali dibuat, langsung muat statistik
  /// penggunaan dari penyimpanan lokal.
  SearchApiProvider() {
    _loadFromStorage();
  }

  // ==========================================================================
  // MEMUAT DATA DARI PENYIMPANAN
  // ==========================================================================
  /// Membaca statistik penggunaan dari SharedPreferences.
  /// CATATAN: API key dan CX SELALU menggunakan default, tidak dibaca dari storage.
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // PENTING: API key dan CX SELALU default, tidak bisa diubah
      _apiKey = _defaultApiKey;
      _cx = _defaultCx;

      // Muat statistik penggunaan dari penyimpanan
      _totalUsageCount = prefs.getInt(_keyUsageCount) ?? 0;
      _dailyUsageCount = prefs.getInt(_keyDailyUsage) ?? 0;
      _dailyDate = prefs.getString(_keyDailyDate) ?? '';
      _lastError = prefs.getString(_keyLastError);

      // Ubah waktu terakhir digunakan dari String ke DateTime
      final lastUsedStr = prefs.getString(_keyLastUsed);
      if (lastUsedStr != null) {
        _lastUsedTime = DateTime.tryParse(lastUsedStr);
      }

      // Reset penghitung harian jika hari sudah berganti
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (_dailyDate != today) {
        _dailyUsageCount = 0;
        _dailyDate = today;
        await prefs.setInt(_keyDailyUsage, 0);
        await prefs.setString(_keyDailyDate, today);
      }

      _isKeyExpired = false; // Reset status expired saat load
    } catch (e) {
      debugPrint('SearchApiProvider: Error loading from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // CATATAN DESAIN:
  // updateApiKey() dan updateCx() SENGAJA tidak dibuat.
  // Search API key dan CX selalu terkunci ke nilai default.

  // ==========================================================================
  // MENCATAT PENGGUNAAN
  // ==========================================================================
  /// Dipanggil setiap kali Google CSE berhasil digunakan (oleh SearchApi).
  /// Menambah counter penggunaan harian dan total, lalu menyimpannya.
  Future<void> recordUsage() async {
    _totalUsageCount++;
    _dailyUsageCount++;
    _lastUsedTime = DateTime.now();

    // Reset penghitung harian jika hari sudah berganti
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

  // ==========================================================================
  // MENCATAT ERROR
  // ==========================================================================
  /// Dipanggil ketika Google CSE mengembalikan error HTTP.
  /// Kode 400/403/429 menyebabkan status "expired" menyala.
  Future<void> recordError(int statusCode, String errorMessage) async {
    _lastError = errorMessage;

    // Tandai sebagai expired untuk error terkait key/quota
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

  /// Membersihkan status error (reset setelah pengguna mengakui error)
  void clearError() {
    _isKeyExpired = false;
    _lastError = null;
    notifyListeners();
  }

  // ==========================================================================
  // RESET STATISTIK
  // ==========================================================================
  /// Mengatur ulang semua statistik penggunaan ke nol
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

  // ==========================================================================
  // FORMAT WAKTU TERAKHIR DIGUNAKAN
  // ==========================================================================
  /// Mengubah waktu terakhir penggunaan menjadi teks ramah pengguna
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
