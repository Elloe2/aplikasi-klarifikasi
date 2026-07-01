// ==============================================================================
// GEMINI API PROVIDER - KLARIP
// ==============================================================================
// File ini mengelola SEMUA HAL yang berkaitan dengan API key Gemini AI.
//
// APA ITU API KEY?
// API key adalah "kode akses rahasia" yang diberikan oleh Google kepada pengguna
// yang mendaftar di Google AI Studio (aistudio.google.com). Tanpa API key yang valid,
// aplikasi tidak bisa menghubungi Gemini AI untuk menganalisis klaim.
//
// MENGAPA PERLU PROVIDER KHUSUS UNTUK API KEY?
// Karena informasi API key perlu bisa diakses dari BANYAK tempat di aplikasi:
// - SearchPage (saat mengirim klaim ke Gemini)
// - SettingsPage (saat pengguna melihat/mengubah API key)
// - Widget statistik (saat menampilkan jumlah penggunaan)
// Dengan Provider, satu perubahan langsung diketahui semua pihak.
//
// APA YANG DIKELOLA:
// 1. Menyimpan dan membaca API key dari SharedPreferences
// 2. Melacak statistik penggunaan (total & harian)
// 3. Mendeteksi error (quota habis, API key tidak valid)
// 4. Menyembunyikan API key di UI (masking: AIza...KiGtA)
// ==============================================================================
library;

import 'package:flutter/material.dart'; // Untuk ChangeNotifier dan debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // Penyimpanan lokal key-value

/// Provider yang mengelola seluruh siklus hidup (lifecycle) Gemini API Key.
/// Mewarisi ChangeNotifier sehingga widget bisa "mendengarkan" perubahan.
class GeminiApiProvider extends ChangeNotifier {
  // ==========================================================================
  // KUNCI PENYIMPANAN (STORAGE KEYS)
  // ==========================================================================
  // Ini adalah nama-nama "laci" di SharedPreferences tempat data disimpan.
  // Analoginya seperti label pada folder: setiap data punya nama folder sendiri.
  static const String _keyApiKey = 'gemini_api_key';         // API key aktif
  static const String _keyUsageCount = 'gemini_usage_count'; // Total penggunaan
  static const String _keyLastUsed = 'gemini_last_used';     // Waktu terakhir dipakai
  static const String _keyLastError = 'gemini_last_error';   // Error terakhir
  static const String _keyDailyUsage = 'gemini_daily_usage'; // Penggunaan hari ini
  static const String _keyDailyDate = 'gemini_daily_date';   // Tanggal hitung harian

  // ==========================================================================
  // API KEY DEFAULT BAWAAN APLIKASI
  // ==========================================================================
  // Ini adalah API key yang sudah tertanam di aplikasi sejak awal.
  // Digunakan jika pengguna belum memasukkan API key miliknya sendiri.
  // Format dimulai dengan 'AQ.' (API key generasi baru dari Google AI Studio)
  static const String _defaultApiKey =
      'AQ.Ab8RN6IcqiuL6ib9m5jUUG4zsDbafkI9BtkWfekTAmsKWh345Q';

  // ==========================================================================
  // DATA INTERNAL (STATE)
  // ==========================================================================
  // Variabel-variabel ini menyimpan data aktif di memori saat aplikasi berjalan.
  // Prefiks '_' menandakan bahwa variabel ini PRIVATE (hanya bisa diubah dari dalam kelas ini).
  String _apiKey = _defaultApiKey;  // API key yang sedang aktif digunakan
  int _totalUsageCount = 0;          // Total berapa kali API sudah dipanggil
  int _dailyUsageCount = 0;          // Berapa kali API dipanggil HARI INI
  String _dailyDate = '';            // Tanggal terakhir penghitung harian direset
  DateTime? _lastUsedTime;           // Kapan terakhir kali API dipanggil
  String? _lastError;                // Pesan error terakhir dari API (null = tidak ada error)
  bool _isKeyExpired = false;        // true = API key sudah tidak bisa dipakai
  bool _isLoading = true;            // true = sedang memuat data dari penyimpanan

  // ==========================================================================
  // GETTERS (PROPERTI PUBLIK YANG BISA DIBACA WIDGET)
  // ==========================================================================
  // Ini adalah "jendela" dari data privat. Widget di luar class hanya boleh
  // MEMBACA data ini, tidak bisa mengubahnya langsung.

  /// API key yang sedang aktif digunakan untuk memanggil Gemini AI
  String get apiKey => _apiKey;

  /// Total berapa kali API Gemini telah dipanggil sejak aplikasi pertama diinstal
  int get totalUsageCount => _totalUsageCount;

  /// Berapa kali API Gemini dipanggil hari ini (direset setiap tengah malam)
  int get dailyUsageCount => _dailyUsageCount;

  /// Kapan terakhir kali API Gemini berhasil dipanggil
  DateTime? get lastUsedTime => _lastUsedTime;

  /// Pesan error terakhir dari API. null jika tidak ada error.
  String? get lastError => _lastError;

  /// true jika API key sudah tidak bisa digunakan (quota habis atau key tidak valid)
  bool get isKeyExpired => _isKeyExpired;

  /// true jika provider sedang memuat data dari penyimpanan (belum siap digunakan)
  bool get isLoading => _isLoading;

  /// true jika pengguna sudah menggunakan API key kustom (bukan bawaan aplikasi)
  bool get isUsingCustomKey => _apiKey != _defaultApiKey;

  /// API key yang sudah disembunyikan sebagian untuk ditampilkan di UI.
  /// Contoh: 'AIzaSyAF...KiGtA' (hanya awal dan akhir yang terlihat)
  /// Ini untuk menjaga kerahasiaan API key dari tampilan layar.
  String get maskedApiKey {
    if (_apiKey.length <= 12) return '****'; // Terlalu pendek, sembunyikan semua
    // Tampilkan 8 karakter pertama + '...' + 4 karakter terakhir
    return '${_apiKey.substring(0, 8)}...${_apiKey.substring(_apiKey.length - 4)}';
  }

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================
  /// Saat GeminiApiProvider pertama kali dibuat (saat app dibuka),
  /// langsung muat data yang tersimpan dari SharedPreferences.
  GeminiApiProvider() {
    _loadFromStorage(); // Muat API key dan statistik dari penyimpanan HP
  }

  // ==========================================================================
  // MEMUAT DATA DARI PENYIMPANAN LOKAL
  // ==========================================================================
  /// Membaca semua data tersimpan dari SharedPreferences ke dalam memori.
  /// Dipanggil SATU KALI saat provider pertama dibuat.
  ///
  /// Yang dimuat:
  /// 1. API key yang terakhir disimpan pengguna
  /// 2. Statistik penggunaan (total dan harian)
  /// 3. Waktu penggunaan terakhir
  /// 4. Error terakhir (jika ada)
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners(); // Beritahu widget: sedang loading

    try {
      final prefs = await SharedPreferences.getInstance(); // Buka penyimpanan

      // Baca API key. Jika belum pernah disimpan, gunakan default.
      _apiKey = prefs.getString(_keyApiKey) ?? _defaultApiKey;

      // Baca statistik penggunaan. Default 0 jika belum ada data.
      _totalUsageCount = prefs.getInt(_keyUsageCount) ?? 0;
      _dailyUsageCount = prefs.getInt(_keyDailyUsage) ?? 0;
      _dailyDate = prefs.getString(_keyDailyDate) ?? '';
      _lastError = prefs.getString(_keyLastError);

      // Baca waktu penggunaan terakhir dan ubah dari String ke DateTime
      final lastUsedStr = prefs.getString(_keyLastUsed);
      if (lastUsedStr != null) {
        _lastUsedTime = DateTime.tryParse(lastUsedStr); // Null jika format salah
      }

      // Reset penghitung harian jika hari ini sudah berbeda dari tanggal terakhir dicatat
      // Contoh: jika terakhir dicatat '2024-01-15' tapi hari ini '2024-01-16', maka reset ke 0
      final today = DateTime.now().toIso8601String().substring(0, 10); // Format: 'YYYY-MM-DD'
      if (_dailyDate != today) {
        _dailyUsageCount = 0;
        _dailyDate = today;
        await prefs.setInt(_keyDailyUsage, 0);
        await prefs.setString(_keyDailyDate, today);
      }

      // Reset status expired saat memuat data baru (fresh start)
      _isKeyExpired = false;
    } catch (e) {
      debugPrint('GeminiApiProvider: Error loading from storage: $e');
    }

    _isLoading = false;
    notifyListeners(); // Beritahu widget: loading selesai, data siap
  }

  // ==========================================================================
  // MENGGANTI API KEY
  // ==========================================================================
  /// Mengganti API key dengan kunci baru yang dimasukkan pengguna di Pengaturan.
  ///
  /// Yang terjadi saat dipanggil:
  /// 1. Validasi: tidak boleh kosong
  /// 2. Simpan key baru ke memori
  /// 3. Reset status error (key baru belum pernah dicoba)
  /// 4. Simpan key baru ke SharedPreferences (permanen, tidak hilang saat app ditutup)
  /// 5. Beritahu widget bahwa ada perubahan
  ///
  /// [newKey] -- API key baru yang ingin digunakan
  Future<void> updateApiKey(String newKey) async {
    final trimmedKey = newKey.trim(); // Hapus spasi di awal/akhir
    if (trimmedKey.isEmpty) return; // Tidak lakukan apa-apa jika kosong

    _apiKey = trimmedKey;
    _isKeyExpired = false; // Reset: key baru dianggap belum expired
    _lastError = null; // Hapus pesan error lama

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, trimmedKey); // Simpan permanen
      await prefs.remove(_keyLastError); // Hapus error lama dari penyimpanan
    } catch (e) {
      debugPrint('GeminiApiProvider: Error saving API key: $e');
    }

    notifyListeners(); // Widget yang mendengarkan akan diperbarui
  }

  /// Mengembalikan API key ke default bawaan aplikasi.
  /// Berguna jika pengguna ingin kembali menggunakan key bawaan
  /// setelah mencoba key milik sendiri.
  Future<void> resetToDefaultKey() async {
    await updateApiKey(_defaultApiKey); // Gunakan fungsi updateApiKey
  }

  // ==========================================================================
  // MENCATAT PENGGUNAAN API
  // ==========================================================================
  /// Dipanggil SETIAP KALI API Gemini berhasil digunakan (oleh GeminiService).
  /// Menambah counter harian dan total, lalu menyimpannya.
  Future<void> recordUsage() async {
    _totalUsageCount++;  // Tambah total
    _dailyUsageCount++;  // Tambah harian
    _lastUsedTime = DateTime.now(); // Catat waktu sekarang

    // Jika hari sudah berganti sejak terakhir dicatat, reset penghitung harian
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_dailyDate != today) {
      _dailyUsageCount = 1; // Mulai dari 1 (bukan 0) karena ini sudah pemakaian pertama hari ini
      _dailyDate = today;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // Simpan semua statistik terbaru ke penyimpanan
      await prefs.setInt(_keyUsageCount, _totalUsageCount);
      await prefs.setInt(_keyDailyUsage, _dailyUsageCount);
      await prefs.setString(_keyDailyDate, _dailyDate);
      await prefs.setString(_keyLastUsed, _lastUsedTime!.toIso8601String());
    } catch (e) {
      debugPrint('GeminiApiProvider: Error saving usage: $e');
    }

    notifyListeners(); // Perbarui widget statistik di UI
  }

  // ==========================================================================
  // MENCATAT ERROR API
  // ==========================================================================
  /// Dipanggil ketika API Gemini mengembalikan error.
  /// Jika error berkaitan dengan quota atau API key, otomatis menandai
  /// bahwa key sudah tidak bisa dipakai (_isKeyExpired = true).
  ///
  /// Kode error yang ditandai sebagai "key expired":
  /// - 400 Bad Request: permintaan bermasalah (sering karena format key salah)
  /// - 403 Forbidden: key diblokir atau tidak memiliki izin
  /// - 429 Too Many Requests: quota harian/per-menit sudah habis
  Future<void> recordError(int statusCode, String errorMessage) async {
    _lastError = errorMessage; // Simpan pesan error di memori

    // Tandai key sebagai "tidak bisa dipakai" untuk error terkait key/quota
    if (statusCode == 400 || statusCode == 403 || statusCode == 429) {
      _isKeyExpired = true;
      // UI akan menampilkan peringatan agar pengguna mengganti API key
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastError, errorMessage); // Simpan error ke penyimpanan
    } catch (e) {
      debugPrint('GeminiApiProvider: Error saving error: $e');
    }

    notifyListeners(); // Widget akan menampilkan indikator error
  }

  /// Menghapus status error (misalnya setelah pengguna mengganti API key).
  /// Dipanggil dari SettingsPage saat pengguna menekan "Hapus Error" atau sejenisnya.
  void clearError() {
    _isKeyExpired = false;
    _lastError = null;
    notifyListeners();
  }

  // ==========================================================================
  // RESET STATISTIK
  // ==========================================================================
  /// Mengatur ulang SEMUA statistik penggunaan ke nol.
  /// Berguna jika pengguna ingin mulai mencatat dari awal.
  Future<void> resetUsageStats() async {
    // Reset semua variabel di memori
    _totalUsageCount = 0;
    _dailyUsageCount = 0;
    _lastUsedTime = null;
    _lastError = null;
    _isKeyExpired = false;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    _dailyDate = today;

    try {
      final prefs = await SharedPreferences.getInstance();
      // Hapus semua data statistik dari penyimpanan
      await prefs.setInt(_keyUsageCount, 0);
      await prefs.setInt(_keyDailyUsage, 0);
      await prefs.setString(_keyDailyDate, today);
      await prefs.remove(_keyLastUsed);    // Hapus waktu penggunaan terakhir
      await prefs.remove(_keyLastError);   // Hapus pesan error terakhir
    } catch (e) {
      debugPrint('GeminiApiProvider: Error resetting stats: $e');
    }

    notifyListeners();
  }

  // ==========================================================================
  // FORMAT WAKTU PENGGUNAAN TERAKHIR
  // ==========================================================================
  /// Mengubah waktu penggunaan terakhir (_lastUsedTime) menjadi teks yang
  /// mudah dibaca manusia untuk ditampilkan di UI.
  ///
  /// Contoh output:
  /// - "Baru saja" (kurang dari 1 menit)
  /// - "15 menit yang lalu"
  /// - "3 jam yang lalu"
  /// - "2 hari yang lalu"
  /// - "15/1/2024" (lebih dari 7 hari)
  String get lastUsedDisplay {
    if (_lastUsedTime == null) return 'Belum pernah digunakan';

    final now = DateTime.now();
    final diff = now.difference(_lastUsedTime!); // Selisih waktu sekarang - terakhir dipakai

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

    // Jika lebih dari seminggu, tampilkan tanggal lengkap
    return '${_lastUsedTime!.day}/${_lastUsedTime!.month}/${_lastUsedTime!.year}';
  }
}
