// ==============================================================================
// WIDGET: GEMINI CHATBOT (AI FACT-CHECKER DISPLAY) - KLARIP
// ==============================================================================
// File ini bertanggung jawab menampilkan hasil analisis kebenaran klaim
// yang dihasilkan oleh kecerdasan buatan (Gemini AI) berdasarkan artikel berita
// pendukung yang dikumpulkan oleh Google Custom Search Engine (CSE).
//
// ALUR LOGIKA UI:
// Widget ini mengontrol visualisasi 4 status (state) yang berbeda:
// 1. **isLoading (Loading State)**: Spinner berputar saat API mendownload data.
// 2. **analysis == null (Empty State)**: Panduan awal sebelum pencarian dilakukan.
// 3. **analysis.success == false (Error State)**: Banner kegagalan API/koneksi.
// 4. **Success State**: Tampilan terstruktur berisi verdict (DIDUKUNG / TIDAK
//    DIDUKUNG / VERIFIKASI), ringkasan penjelasan, analisis mendalam, dan tombol
//    menyimpan ke SQLite.
//
// FORMAT PENYIMPANAN DATA (STRUCTURED JSON):
// Saat tombol "Simpan ke Koleksi" ditekan, widget ini mengemas:
// - `analysis.analysis` (teks analisis mendalam AI)
// - `results` (daftar tautan berita mentah dari Google CSE)
// Menjadi satu kesatuan teks ter-serialize JSON string sebelum disimpan ke
// kolom tabel SQLite `analysis`. Ini disebut pola *EAV (Entity-Attribute-Value) Hybrid*.
// ==============================================================================

import 'dart:convert'; // Untuk melakukan serialisasi/deserialisasi objek ke JSON string
import 'package:flutter/material.dart'; // Paket komponen UI Material Flutter
import 'package:provider/provider.dart'; // State management Provider untuk berinteraksi dengan database
import '../models/gemini_analysis.dart'; // Model data analisis hasil respon Gemini AI
import '../models/saved_analysis.dart'; // Model data untuk record tabel SQLite riwayat
import '../providers/saved_analysis_provider.dart'; // Provider pengontrol CRUD SQLite riwayat
import '../theme/app_theme.dart'; // Konsistensi pewarnaan tema gelap Klarip
import '../models/search_result.dart'; // Model artikel berita Google CSE
import 'gemini_logo.dart'; // Widget kustom untuk menggambar animasi logo Gemini AI

/// Widget kustom untuk menampilkan wadah analisis Gemini AI.
/// Bersifat StatelessWidget karena seluruh state datanya di-supply dari luar (SearchPage).
class GeminiChatbot extends StatelessWidget {
  /// Objek hasil analisis kebenaran dari Gemini AI (null jika belum mencari)
  final GeminiAnalysis? analysis;

  /// Daftar berita artikel dari Google CSE yang dijadikan rujukan/sumber rujukan
  final List<SearchResult>? results;

  /// Penanda status sedang menanti respon API
  final bool isLoading;

  /// Callback fungsi untuk mencoba ulang request pencarian jika gagal
  final VoidCallback? onRetry;

  const GeminiChatbot({
    super.key,
    this.analysis,
    this.results,
    this.isLoading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceElevated, // Warna latar abu gelap dari tema
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === KOP HEADER: LOGO & JUDUL ===
            Row(
              children: [
                const GeminiLogo(size: 32), // Logo gemerlap khas Gemini AI
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Fact-Checker',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        'Powered by Gemini AI',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.subduedGray,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol refresh/coba lagi hanya muncul jika terjadi kegagalan sistem
                if (onRetry != null && analysis != null && !analysis!.success)
                  IconButton(
                    onPressed: onRetry,
                    icon: const Icon(
                      Icons.refresh,
                      color: AppTheme.primarySeedColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // === PERCABANGAN KONDISI STATE UI ===
            if (isLoading) ...[
              _buildLoadingState(context), // Status 1: Loading
            ] else if (analysis == null) ...[
              _buildEmptyState(context), // Status 2: Kosong
            ] else if (!analysis!.success) ...[
              _buildErrorState(context), // Status 3: Error
            ] else ...[
              _buildAnalysisResult(context), // Status 4: Sukses Analisis
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // VIEW STATUS 1: SEDANG LOADING (_buildLoadingState)
  // ==========================================================================
  /// Tampilan saat Gemini masih memproses analisis klaim di latar belakang.
  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primarySeedColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Menganalisis klaim...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.subduedGray),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'AI sedang memeriksa kebenaran klaim ini',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedGray),
        ),
      ],
    );
  }

  // ==========================================================================
  // VIEW STATUS 2: BELUM ADA PENCARIAN (_buildEmptyState)
  // ==========================================================================
  /// Tampilan awal pemandu pengguna sebelum mengetik kata kunci.
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.psychology_outlined, color: AppTheme.mutedGray, size: 32),
        const SizedBox(height: 8),
        Text(
          'AI Fact-Checker siap menganalisis',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.subduedGray),
        ),
        const SizedBox(height: 4),
        Text(
          'Masukkan klaim untuk mendapatkan analisis AI',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedGray),
        ),
      ],
    );
  }

  // ==========================================================================
  // VIEW STATUS 3: GAGAL REQUEST API (_buildErrorState)
  // ==========================================================================
  /// Tampilan peringatan ketika Gemini mengembalikan respons gagal.
  Widget _buildErrorState(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red.withValues(alpha: 0.7),
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'Gagal menganalisis klaim',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.red.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          analysis?.error ?? 'Terjadi kesalahan saat menganalisis',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedGray),
        ),
      ],
    );
  }

  // ==========================================================================
  // VIEW STATUS 4: SUKSES MENAMPILKAN HASIL (_buildAnalysisResult)
  // ==========================================================================
  /// Membangun layout visual hasil analisis kebenaran klaim (Verdict & Ringkasan).
  Widget _buildAnalysisResult(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === BARIS BADGE HASIL VERDICT ===
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: analysis!.verdictColor.withValues(alpha: 0.2), // Latar transparan tipis sesuai warna verdict
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: analysis!.verdictColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    analysis!.verdictIcon,
                    size: 18,
                    color: analysis!.verdictColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    analysis!.verdictDisplayText, // "DIDUKUNG DATA", "TIDAK DIDUKUNG DATA", atau "MEMERLUKAN VERIFIKASI"
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: analysis!.verdictColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // === RINGKASAN PENJELASAN ===
        Text(
          'Penjelasan:',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          analysis!.explanation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // === ANALISIS REFERENSI DETIL (JIKA ADA) ===
        if (analysis!.analysis.isNotEmpty &&
            analysis!.analysis != 'Tidak ada analisis tersedia') ...[
          Text(
            'Analisis Mendalam:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primarySeedColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primarySeedColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              analysis!.analysis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // === TOMBOL UTAMA SIMPAN DATA (CRUD CREATE) ===
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSaveDialog(context), // Tampilkan popup form catatan saat diklik
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySeedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            icon: const Icon(Icons.bookmark_add),
            label: const Text(
              'Simpan ke Koleksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // METODE: FORM CATATAN TAMBAHAN RIWAYAT
  // ==========================================================================
  /// Dialog pop-up interaktif untuk mengisi catatan pribadi (userNote)
  /// sebelum akhirnya disimpan permanen di database SQLite lokal.
  void _showSaveDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Simpan Analisis',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambahkan catatan pribadi untuk analisis ini (opsional):',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Contoh: Perlu dicek lagi ke website resmi...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Pemicu eksekusi penyimpanan fisik
              _saveAnalysis(context, noteController.text);
              Navigator.pop(context); // Tutup dialog setelah berhasil diproses
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METODE: PROSES SIMPAN PERMANEN DATABASE LOKAL
  // ==========================================================================
  /// Menyusun objek [SavedAnalysis] terintegrasi.
  /// Memadukan hasil analisis AI dan kumpulan artikel referensi menjadi string JSON tunggal.
  void _saveAnalysis(BuildContext context, String note) {
    try {
      debugPrint('=== MENYIMPAN ANALISIS ===');
      debugPrint('Klaim: ${analysis!.claim}');
      debugPrint('Jumlah Artikel CSE: ${results?.length ?? 0}');

      // 1. Susun map data terstruktur (Structured JSON)
      final Map<String, dynamic> structuredData = {
        'ai_analysis': analysis!.analysis,
        'search_results': results?.map((r) => r.toMap()).toList() ?? [],
      };

      // 2. Buat objek penampung model riwayat
      final savedAnalysis = SavedAnalysis(
        title: 'Analisis Fakta: ${analysis!.claim}',
        claim: analysis!.claim,
        verdict: analysis!.verdict,
        explanation: analysis!.explanation,
        confidence: analysis!.confidence,
        userNote: note, // Catatan pribadi hasil input manual pengguna
        sourceUrl: analysis!.sources,
        analysis: jsonEncode(structuredData), // Encode Map menjadi String tunggal untuk disimpan di SQLite
        savedAt: DateTime.now(), // Waktu penyimpanan lokal saat ini
      );

      // 3. Masukkan ke database lokal melalui provider SavedAnalysisProvider
      context.read<SavedAnalysisProvider>().addAnalysis(savedAnalysis);

      // 4. Berikan visual snackbar konfirmasi sukses ke pengguna
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Berhasil disimpan ke koleksi (${results?.length ?? 0} sumber)',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal menyimpan riwayat ke SQLite: $e');
    }
  }
}

