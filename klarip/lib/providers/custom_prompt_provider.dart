// ==============================================================================
// CUSTOM PROMPT PROVIDER - KLARIP
// ==============================================================================
// File ini mengelola instruksi analisis yang dikirimkan ke Gemini AI.
//
// APA ITU PROMPT?
// Prompt adalah "instruksi" atau "perintah" yang dikirimkan ke Gemini AI
// bersama klaim yang ingin diverifikasi. Prompt memberitahu AI:
// - Apa yang harus dilakukan (analisis klaim berdasarkan sumber)
// - Bagaimana menentukan verdict (DIDUKUNG, TIDAK DIDUKUNG, MEMERLUKAN VERIFIKASI)
// - Format jawaban yang diharapkan (JSON)
//
// MENGAPA PROMPT BISA DIKUSTOMISASI?
// Pengguna bisa mengubah instruksi analisis agar AI lebih fokus pada aspek
// tertentu. Misalnya: lebih ketat, lebih permisif, atau menggunakan kriteria
// khusus yang relevan dengan kebutuhan verifikasi pengguna.
//
// BATASAN KUSTOMISASI:
// Nama verdict (DIDUKUNG_DATA, TIDAK_DIDUKUNG_DATA, MEMERLUKAN_VERIFIKASI)
// TIDAK BISA diubah karena kode aplikasi bergantung pada nilai persis ini.
// Hanya DESKRIPSI kapan verdict tersebut digunakan yang bisa diubah.
//
// STRUKTUR PROMPT YANG DIKIRIM KE GEMINI:
// Bagian 1 (Bisa diedit): "1. Periksa apakah sumber relevan..."
//                          "2. Identifikasi sumber yang mendukung/menentang..."
//                          "3. Bandingkan informasi antar sumber..."
// Bagian 2 (Terkunci):    "4. Tentukan verdict:"
//                          "   - DIDUKUNG_DATA: [deskripsi yang bisa diedit]"
//                          "   - TIDAK_DIDUKUNG_DATA: [deskripsi yang bisa diedit]"
//                          "   - MEMERLUKAN_VERIFIKASI: [deskripsi yang bisa diedit]"
// ==============================================================================
library;

import 'package:flutter/material.dart'; // Untuk ChangeNotifier
import 'package:shared_preferences/shared_preferences.dart'; // Penyimpanan lokal

/// Provider yang mengelola instruksi kustom analisis untuk Gemini AI.
/// Pengguna dapat mengubah instruksi dari menu Pengaturan > Prompt AI.
class CustomPromptProvider extends ChangeNotifier {
  // ==========================================================================
  // KUNCI PENYIMPANAN (STORAGE KEYS)
  // ==========================================================================
  // Nama-nama "laci" di SharedPreferences untuk menyimpan kustomisasi prompt.
  static const String _keyMainInstructions = 'prompt_main_instructions';    // Instruksi utama (poin 1-3)
  static const String _keyVerdictDidukung = 'prompt_verdict_didukung';      // Deskripsi verdict DIDUKUNG
  static const String _keyVerdictTidakDidukung = 'prompt_verdict_tidak_didukung'; // Deskripsi TIDAK_DIDUKUNG
  static const String _keyVerdictVerifikasi = 'prompt_verdict_verifikasi';  // Deskripsi MEMERLUKAN_VERIFIKASI

  // ==========================================================================
  // INSTRUKSI DEFAULT (BAWAAN APLIKASI)
  // ==========================================================================
  // Ini adalah instruksi yang digunakan jika pengguna belum pernah mengubahnya.
  // Dirancang untuk memberikan hasil analisis yang seimbang dan objektif.

  /// Instruksi utama: panduan bagaimana AI harus menganalisis sumber (poin 1-3)
  static const String defaultMainInstructions =
      '1. Periksa apakah setiap sumber benar-benar berkaitan (RELEVAN) dengan isi klaim.\n'
      '2. Identifikasi sumber yang mendukung (PRO) dan sumber yang membantah (KONTRA) terhadap klaim.\n'
      '3. Bandingkan informasi antara satu sumber dengan sumber lainnya untuk melihat konsistensi data.';

  /// Deskripsi kapan verdict DIDUKUNG_DATA digunakan
  static const String defaultVerdictDidukung =
      'Jika mayoritas sumber relevan mendukung klaim.';

  /// Deskripsi kapan verdict TIDAK_DIDUKUNG_DATA digunakan
  static const String defaultVerdictTidakDidukung =
      'Jika mayoritas sumber relevan membantah klaim (hoaks).';

  /// Deskripsi kapan verdict MEMERLUKAN_VERIFIKASI digunakan
  static const String defaultVerdictVerifikasi =
      'Jika data kontradiktif atau tidak cukup bukti.';

  // ==========================================================================
  // DATA INTERNAL (STATE)
  // ==========================================================================
  String _mainInstructions = defaultMainInstructions;
  String _verdictDidukung = defaultVerdictDidukung;
  String _verdictTidakDidukung = defaultVerdictTidakDidukung;
  String _verdictVerifikasi = defaultVerdictVerifikasi;
  bool _isLoading = true;

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  /// Instruksi utama analisis (poin 1-3 dalam prompt)
  String get mainInstructions => _mainInstructions;

  /// Deskripsi untuk verdict DIDUKUNG_DATA
  String get verdictDidukung => _verdictDidukung;

  /// Deskripsi untuk verdict TIDAK_DIDUKUNG_DATA
  String get verdictTidakDidukung => _verdictTidakDidukung;

  /// Deskripsi untuk verdict MEMERLUKAN_VERIFIKASI
  String get verdictVerifikasi => _verdictVerifikasi;

  /// true jika sedang memuat data dari penyimpanan
  bool get isLoading => _isLoading;

  /// Menggabungkan semua bagian menjadi SATU teks instruksi lengkap yang
  /// akan dikirimkan ke Gemini AI sebagai bagian dari prompt.
  ///
  /// PENTING: Nama verdict (DIDUKUNG_DATA, dll.) SELALU terkunci.
  /// Hanya deskripsinya yang bisa dikustomisasi pengguna.
  ///
  /// Contoh output:
  /// "1. Periksa apakah setiap sumber relevan..."
  /// "4. Tentukan verdict:"
  /// "   - DIDUKUNG_DATA: Jika mayoritas sumber mendukung klaim."
  String get customInstructions {
    return '$_mainInstructions\n'
        '4. Tentukan verdict:\n'
        '   - DIDUKUNG_DATA: $_verdictDidukung\n'         // DIDUKUNG_DATA TERKUNCI
        '   - TIDAK_DIDUKUNG_DATA: $_verdictTidakDidukung\n' // TIDAK_DIDUKUNG_DATA TERKUNCI
        '   - MEMERLUKAN_VERIFIKASI: $_verdictVerifikasi'; // MEMERLUKAN_VERIFIKASI TERKUNCI
  }

  /// Mengecek apakah pengguna sudah mengubah instruksi dari nilai default.
  /// Berguna untuk menampilkan badge/indikator "Custom" di UI Pengaturan.
  bool get isUsingCustom {
    return _mainInstructions.trim() != defaultMainInstructions.trim() ||
        _verdictDidukung.trim() != defaultVerdictDidukung.trim() ||
        _verdictTidakDidukung.trim() != defaultVerdictTidakDidukung.trim() ||
        _verdictVerifikasi.trim() != defaultVerdictVerifikasi.trim();
  }

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================
  CustomPromptProvider() {
    _loadFromStorage(); // Muat instruksi tersimpan saat provider dibuat
  }

  // ==========================================================================
  // MEMUAT DARI PENYIMPANAN
  // ==========================================================================
  /// Membaca instruksi kustom yang tersimpan di SharedPreferences.
  /// Jika belum ada yang tersimpan, gunakan instruksi default.
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Baca setiap bagian instruksi. Gunakan default jika belum pernah disimpan.
      _mainInstructions =
          prefs.getString(_keyMainInstructions) ?? defaultMainInstructions;
      _verdictDidukung =
          prefs.getString(_keyVerdictDidukung) ?? defaultVerdictDidukung;
      _verdictTidakDidukung =
          prefs.getString(_keyVerdictTidakDidukung) ?? defaultVerdictTidakDidukung;
      _verdictVerifikasi =
          prefs.getString(_keyVerdictVerifikasi) ?? defaultVerdictVerifikasi;
    } catch (e) {
      // Jika terjadi error saat membaca, gunakan semua nilai default
      debugPrint('CustomPromptProvider: Error loading: $e');
      _mainInstructions = defaultMainInstructions;
      _verdictDidukung = defaultVerdictDidukung;
      _verdictTidakDidukung = defaultVerdictTidakDidukung;
      _verdictVerifikasi = defaultVerdictVerifikasi;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==========================================================================
  // MEMPERBARUI INSTRUKSI
  // ==========================================================================
  /// Menyimpan instruksi kustom baru yang dimasukkan pengguna di Pengaturan.
  ///
  /// Semua parameter wajib diisi (required) karena semua bagian prompt
  /// harus selalu ada untuk menghasilkan instruksi yang valid.
  ///
  /// [mainInstructions]       -- Poin 1-3 instruksi analisis
  /// [verdictDidukung]        -- Deskripsi kapan memilih DIDUKUNG_DATA
  /// [verdictTidakDidukung]   -- Deskripsi kapan memilih TIDAK_DIDUKUNG_DATA
  /// [verdictVerifikasi]      -- Deskripsi kapan memilih MEMERLUKAN_VERIFIKASI
  Future<void> updateInstructions({
    required String mainInstructions,
    required String verdictDidukung,
    required String verdictTidakDidukung,
    required String verdictVerifikasi,
  }) async {
    // Simpan ke memori (trim() untuk menghapus spasi tidak perlu)
    _mainInstructions = mainInstructions.trim();
    _verdictDidukung = verdictDidukung.trim();
    _verdictTidakDidukung = verdictTidakDidukung.trim();
    _verdictVerifikasi = verdictVerifikasi.trim();

    try {
      // Simpan permanen ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMainInstructions, _mainInstructions);
      await prefs.setString(_keyVerdictDidukung, _verdictDidukung);
      await prefs.setString(_keyVerdictTidakDidukung, _verdictTidakDidukung);
      await prefs.setString(_keyVerdictVerifikasi, _verdictVerifikasi);
    } catch (e) {
      debugPrint('CustomPromptProvider: Error saving: $e');
    }

    notifyListeners(); // Beritahu widget bahwa instruksi berhasil diperbarui
  }

  // ==========================================================================
  // RESET KE DEFAULT
  // ==========================================================================
  /// Mengembalikan semua instruksi ke nilai bawaan aplikasi.
  /// Juga menghapus semua data tersimpan dari SharedPreferences.
  Future<void> resetToDefault() async {
    // Reset ke nilai default di memori
    _mainInstructions = defaultMainInstructions;
    _verdictDidukung = defaultVerdictDidukung;
    _verdictTidakDidukung = defaultVerdictTidakDidukung;
    _verdictVerifikasi = defaultVerdictVerifikasi;

    try {
      // Hapus data kustom dari penyimpanan (sehingga next load pakai default)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyMainInstructions);
      await prefs.remove(_keyVerdictDidukung);
      await prefs.remove(_keyVerdictTidakDidukung);
      await prefs.remove(_keyVerdictVerifikasi);
    } catch (e) {
      debugPrint('CustomPromptProvider: Error resetting: $e');
    }

    notifyListeners();
  }
}
