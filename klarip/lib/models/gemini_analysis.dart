// ==============================================================================
// PENJELASAN UNTUK SIDANG: MODEL GEMINI ANALYSIS
// ==============================================================================
// Bapak/Ibu Penguji, file ini adalah Model (Struktur Data) untuk menangkap balasan
// dari Google Gemini AI. Berbeda dengan aplikasi chat biasa yang membalas dengan
// teks paragraf panjang, AI di sistem ini *dipaksa* membalas dengan format
// terstruktur (JSON) agar UI bisa menampilkan warna dan ikon yang tepat.
//
// STRUKTUR VERDICT (KESIMPULAN):
// 1. DIDUKUNG_DATA         -> Mayoritas berita referensi membenarkan klaim.
//                             (UI akan menampilkannya dengan warna Hijau & Icon Centang)
// 2. TIDAK_DIDUKUNG_DATA   -> Mayoritas berita referensi membantah klaim (Hoaks).
//                             (UI akan menampilkannya dengan warna Merah & Icon Silang)
// 3. MEMERLUKAN_VERIFIKASI -> Berita saling bertentangan / buktinya abu-abu.
//                             (UI akan menampilkannya dengan warna Kuning & Icon Tanya)
//
// KONSEP PARSING API:
// Kelas ini memiliki `fromJson`, yang bertugas mengubah teks balasan AI
// menjadi objek yang dimengerti oleh Flutter (Dart).
// ==============================================================================

import 'package:flutter/material.dart'; // Untuk Color dan IconData

/// Model data yang merepresentasikan hasil analisis dari Google Gemini AI.
/// Berisi verdict (kesimpulan), penjelasan singkat, analisis mendalam,
/// dan berbagai getter helper untuk tampilan UI.
class GeminiAnalysis {
  /// Status keberhasilan: true jika Gemini berhasil menjawab, false jika error
  final bool success;

  /// Verdict analisis -- satu dari tiga nilai:
  /// 'DIDUKUNG_DATA', 'TIDAK_DIDUKUNG_DATA', atau 'MEMERLUKAN_VERIFIKASI'
  final String verdict;

  /// Penjelasan ringkas (2-3 kalimat) tentang kesimpulan analisis
  final String explanation;

  /// Analisis mendalam (4-5 kalimat) tentang kaitan antar sumber berita
  final String analysis;

  /// Tingkat keyakinan analisis: 'tinggi', 'sedang', atau 'rendah'
  final String confidence;

  /// Daftar domain sumber yang digunakan Gemini dalam analisis
  /// Contoh: "kompas.com, detik.com, antaranews.com"
  final String sources;

  /// Teks klaim asli yang dianalisis (disimpan agar bisa ditampilkan di UI)
  final String claim;

  /// Pesan error jika analisis gagal (null jika berhasil)
  final String? error;

  /// true = analisis ini adalah respons error/fallback (bukan analisis AI sungguhan)
  /// false = analisis nyata dari Gemini AI
  final bool isFallback;

  /// Constructor utama untuk membuat objek GeminiAnalysis.
  const GeminiAnalysis({
    required this.success,
    required this.verdict,
    required this.explanation,
    required this.analysis,
    required this.confidence,
    required this.sources,
    required this.claim,
    this.error,
    this.isFallback = false,
  });

  /// Factory constructor untuk membuat GeminiAnalysis dari Map JSON.
  /// Digunakan jika data analisis disimpan atau dikirim dalam format JSON.
  factory GeminiAnalysis.fromJson(Map<String, dynamic> json) {
    return GeminiAnalysis(
      success: json['success'] ?? false,
      verdict: _ensureString(json['verdict']) ?? 'MEMERLUKAN_VERIFIKASI',
      explanation: _ensureString(json['explanation']) ?? 'Tidak ada penjelasan tersedia',
      analysis: _ensureString(json['analysis']) ?? 'Tidak ada analisis tersedia',
      confidence: _ensureString(json['confidence']) ?? 'rendah',
      sources: _ensureString(json['sources']) ?? '',
      claim: _ensureString(json['claim']) ?? '',
      error: _ensureString(json['error']),
      isFallback: json['is_fallback'] ?? false,
    );
  }

  /// Helper: Memastikan nilai dari JSON adalah String.
  /// Menangani kasus di mana Gemini kadang mengembalikan List alih-alih String.
  static String? _ensureString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value; // Sudah String, langsung kembalikan
    if (value is List) return value.join(' '); // List -> gabungkan dengan spasi
    return value.toString(); // Tipe lain -> konversi ke String
  }

  /// Mengubah objek GeminiAnalysis menjadi Map JSON.
  /// Berguna jika ingin menyimpan atau mengirimkan data analisis.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'verdict': verdict,
      'explanation': explanation,
      'analysis': analysis,
      'confidence': confidence,
      'sources': sources,
      'claim': claim,
      'is_fallback': isFallback,
      if (error != null) 'error': error, // Tambahkan error hanya jika tidak null
    };
  }

  // ==========================================================================
  // GETTER HELPER UNTUK TAMPILAN UI
  // ==========================================================================
  // Getter di bawah ini memudahkan widget dalam menampilkan data dengan format
  // yang sesuai -- tanpa perlu mengulang logika if/switch di setiap widget.

  /// Status analisis dalam teks bahasa Indonesia
  String get status {
    if (!success) return 'Gagal';
    return 'Berhasil';
  }

  /// Verdict dalam format teks yang mudah dibaca manusia
  /// Mengubah format konstanta ('DIDUKUNG_DATA') menjadi judul ('Didukung Data')
  String get verdictDisplay {
    switch (verdict) {
      case 'DIDUKUNG_DATA':
        return 'Didukung Data';
      case 'TIDAK_DIDUKUNG_DATA':
        return 'Tidak Didukung Data';
      case 'MEMERLUKAN_VERIFIKASI':
        return 'Memerlukan Verifikasi';
      case 'ERROR':
        return 'Error - AI Tidak Tersedia';
      default:
        return verdict;
    }
  }

  /// Confidence dalam format teks yang mudah dibaca
  String get confidenceDisplay {
    switch (confidence.toLowerCase()) {
      case 'tinggi':
        return 'Tinggi';
      case 'sedang':
        return 'Sedang';
      case 'rendah':
        return 'Rendah';
      default:
        return confidence;
    }
  }

  /// Kelas CSS untuk pewarnaan (digunakan jika dirender di web)
  String get verdictColorClass {
    switch (verdict) {
      case 'DIDUKUNG_DATA':
        return 'success'; // Hijau
      case 'TIDAK_DIDUKUNG_DATA':
        return 'danger'; // Merah
      case 'MEMERLUKAN_VERIFIKASI':
        return 'warning'; // Kuning
      default:
        return 'info';
    }
  }

  /// Alias untuk verdictDisplay (untuk kompatibilitas kode lama)
  String get verdictDisplayText => verdictDisplay;

  /// Alias untuk confidenceDisplay (untuk kompatibilitas kode lama)
  String get confidenceDisplayText => confidenceDisplay;

  /// Warna Flutter (Color) yang sesuai dengan verdict.
  /// Digunakan untuk mewarnai badge/chip verdict di UI.
  Color get verdictColor {
    switch (verdict) {
      case 'DIDUKUNG_DATA':
        return const Color(0xFF10B981); // Hijau -> klaim didukung data
      case 'TIDAK_DIDUKUNG_DATA':
        return const Color(0xFFEF4444); // Merah -> klaim tidak didukung (hoaks)
      case 'MEMERLUKAN_VERIFIKASI':
        return const Color(0xFFF59E0B); // Kuning/oranye -> perlu verifikasi lebih lanjut
      case 'ERROR':
        return const Color(0xFF7F1D1D); // Merah gelap -> error sistem
      default:
        return const Color(0xFF3B82F6); // Biru -> default
    }
  }

  /// Ikon yang mewakili verdict.
  /// Digunakan sebagai ikon visual di samping teks verdict.
  IconData get verdictIcon {
    switch (verdict) {
      case 'DIDUKUNG_DATA':
        return Icons.check_circle; // Centang -> positif/benar
      case 'TIDAK_DIDUKUNG_DATA':
        return Icons.cancel; // Silang -> negatif/hoaks
      case 'MEMERLUKAN_VERIFIKASI':
        return Icons.help_outline; // Tanda tanya -> tidak pasti
      case 'ERROR':
        return Icons.error_outline; // Tanda seru -> error
      default:
        return Icons.info;
    }
  }

  /// Warna untuk tingkat keyakinan (confidence).
  Color get confidenceColor {
    switch (confidence.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFF10B981); // Hijau -> keyakinan tinggi
      case 'sedang':
        return const Color(0xFFF59E0B); // Kuning -> keyakinan sedang
      case 'rendah':
        return const Color(0xFFEF4444); // Merah -> keyakinan rendah
      default:
        return const Color(0xFF6B7280); // Abu-abu -> tidak diketahui
    }
  }
}
