/// ============================================================================
/// CUSTOM PROMPT PROVIDER - KLARIP FRONTEND
/// ============================================================================
/// Provider untuk mengelola custom prompt instruksi analisis Gemini AI.
/// User bisa mengkustomisasi bagian "TUGAS ANDA" dari prompt yang dikirim
/// ke Gemini AI, dengan batasan:
/// - Poin 1-3 (instruksi utama) bisa diedit bebas
/// - Poin 4 (verdict): nama verdict TERKUNCI, hanya deskripsi yang bisa diedit
///
/// Fitur:
/// - Simpan/baca custom instructions dari SharedPreferences
/// - Reset ke instruksi default
/// - Verdict names (DIDUKUNG_DATA, dll) selalu terkunci
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// === CUSTOM PROMPT PROVIDER ===
class CustomPromptProvider extends ChangeNotifier {
  // === STORAGE KEYS ===
  static const String _keyMainInstructions = 'prompt_main_instructions';
  static const String _keyVerdictDidukung = 'prompt_verdict_didukung';
  static const String _keyVerdictTidakDidukung =
      'prompt_verdict_tidak_didukung';
  static const String _keyVerdictVerifikasi = 'prompt_verdict_verifikasi';

  // === DEFAULT VALUES ===
  static const String defaultMainInstructions =
      '1. Periksa apakah setiap sumber benar-benar berkaitan (RELEVAN) dengan isi klaim.\n'
      '2. Identifikasi sumber yang mendukung (PRO) dan sumber yang membantah (KONTRA) terhadap klaim.\n'
      '3. Bandingkan informasi antara satu sumber dengan sumber lainnya untuk melihat konsistensi data.';

  static const String defaultVerdictDidukung =
      'Jika mayoritas sumber relevan mendukung klaim.';
  static const String defaultVerdictTidakDidukung =
      'Jika mayoritas sumber relevan membantah klaim (hoaks).';
  static const String defaultVerdictVerifikasi =
      'Jika data kontradiktif atau tidak cukup bukti.';

  // === INTERNAL STATE ===
  String _mainInstructions = defaultMainInstructions;
  String _verdictDidukung = defaultVerdictDidukung;
  String _verdictTidakDidukung = defaultVerdictTidakDidukung;
  String _verdictVerifikasi = defaultVerdictVerifikasi;
  bool _isLoading = true;

  // === GETTERS ===
  String get mainInstructions => _mainInstructions;
  String get verdictDidukung => _verdictDidukung;
  String get verdictTidakDidukung => _verdictTidakDidukung;
  String get verdictVerifikasi => _verdictVerifikasi;
  bool get isLoading => _isLoading;

  /// Menggabungkan semua bagian menjadi instruksi lengkap untuk prompt Gemini.
  /// Verdict names (DIDUKUNG_DATA, dll) SELALU terkunci.
  String get customInstructions {
    return '$_mainInstructions\n'
        '4. Tentukan verdict:\n'
        '   - DIDUKUNG_DATA: $_verdictDidukung\n'
        '   - TIDAK_DIDUKUNG_DATA: $_verdictTidakDidukung\n'
        '   - MEMERLUKAN_VERIFIKASI: $_verdictVerifikasi';
  }

  /// Cek apakah ada bagian yang diubah dari default
  bool get isUsingCustom {
    return _mainInstructions.trim() != defaultMainInstructions.trim() ||
        _verdictDidukung.trim() != defaultVerdictDidukung.trim() ||
        _verdictTidakDidukung.trim() != defaultVerdictTidakDidukung.trim() ||
        _verdictVerifikasi.trim() != defaultVerdictVerifikasi.trim();
  }

  // === CONSTRUCTOR ===
  CustomPromptProvider() {
    _loadFromStorage();
  }

  // === LOAD DARI STORAGE ===
  Future<void> _loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _mainInstructions =
          prefs.getString(_keyMainInstructions) ?? defaultMainInstructions;
      _verdictDidukung =
          prefs.getString(_keyVerdictDidukung) ?? defaultVerdictDidukung;
      _verdictTidakDidukung =
          prefs.getString(_keyVerdictTidakDidukung) ??
          defaultVerdictTidakDidukung;
      _verdictVerifikasi =
          prefs.getString(_keyVerdictVerifikasi) ?? defaultVerdictVerifikasi;
    } catch (e) {
      debugPrint('CustomPromptProvider: Error loading: $e');
      _mainInstructions = defaultMainInstructions;
      _verdictDidukung = defaultVerdictDidukung;
      _verdictTidakDidukung = defaultVerdictTidakDidukung;
      _verdictVerifikasi = defaultVerdictVerifikasi;
    }

    _isLoading = false;
    notifyListeners();
  }

  // === UPDATE INSTRUKSI ===
  Future<void> updateInstructions({
    required String mainInstructions,
    required String verdictDidukung,
    required String verdictTidakDidukung,
    required String verdictVerifikasi,
  }) async {
    _mainInstructions = mainInstructions.trim();
    _verdictDidukung = verdictDidukung.trim();
    _verdictTidakDidukung = verdictTidakDidukung.trim();
    _verdictVerifikasi = verdictVerifikasi.trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMainInstructions, _mainInstructions);
      await prefs.setString(_keyVerdictDidukung, _verdictDidukung);
      await prefs.setString(_keyVerdictTidakDidukung, _verdictTidakDidukung);
      await prefs.setString(_keyVerdictVerifikasi, _verdictVerifikasi);
    } catch (e) {
      debugPrint('CustomPromptProvider: Error saving: $e');
    }

    notifyListeners();
  }

  // === RESET KE DEFAULT ===
  Future<void> resetToDefault() async {
    _mainInstructions = defaultMainInstructions;
    _verdictDidukung = defaultVerdictDidukung;
    _verdictTidakDidukung = defaultVerdictTidakDidukung;
    _verdictVerifikasi = defaultVerdictVerifikasi;

    try {
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
