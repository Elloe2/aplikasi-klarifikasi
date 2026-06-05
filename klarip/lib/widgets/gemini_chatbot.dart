import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gemini_analysis.dart';
import '../models/saved_analysis.dart';
import '../providers/saved_analysis_provider.dart';
import '../theme/app_theme.dart';
import '../models/search_result.dart';
import 'gemini_logo.dart';

/// Widget untuk menampilkan analisis Gemini AI
/// Meng-handle berbagai state: loading, kosong, error, dan sukses.
class GeminiChatbot extends StatelessWidget {
  final GeminiAnalysis? analysis;
  final List<SearchResult>? results; // Add results parameter
  final bool isLoading;
  final VoidCallback? onRetry;

  const GeminiChatbot({
    super.key,
    this.analysis,
    this.results, // Accept results
    this.isLoading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan icon Gemini
            Row(
              children: [
                const GeminiLogo(size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Fact-Checker',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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

            // Content berdasarkan status
            if (isLoading) ...[
              _buildLoadingState(context),
            ] else if (analysis == null) ...[
              _buildEmptyState(context),
            ] else if (!analysis!.success) ...[
              _buildErrorState(context),
            ] else ...[
              _buildAnalysisResult(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Tampilan saat Gemini masih memproses analisis klaim
  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primarySeedColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Menganalisis klaim...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.subduedGray),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'AI sedang memeriksa kebenaran klaim ini',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.mutedGray),
        ),
      ],
    );
  }

  /// Tampilan default ketika belum ada analisis yang bisa ditampilkan
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.psychology_outlined, color: AppTheme.mutedGray, size: 32),
        const SizedBox(height: 8),
        Text(
          'AI Fact-Checker siap menganalisis',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.subduedGray),
        ),
        const SizedBox(height: 4),
        Text(
          'Masukkan klaim untuk mendapatkan analisis AI',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.mutedGray),
        ),
      ],
    );
  }

  /// Tampilan error ketika analisis gagal atau diblokir
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
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.mutedGray),
        ),
      ],
    );
  }

  /// Tampilan utama ketika analisis sukses dan siap dibaca
  Widget _buildAnalysisResult(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verdict and Confidence Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Verdict Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: analysis!.verdictColor.withValues(alpha: 0.2),
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
                    analysis!.verdictDisplayText,
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

        // Explanation
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

        // Analysis (baru)
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

        // === ACTION BUTTON ===
        // Tombol simpan besar di bagian bawah agar mudah dijangkau
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSaveDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySeedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              // Import providers dynamically to avoid cyclic imports if possible,
              // or ensure generic implementation.
              // Utilizing a callback approach or direct provider access if safe.
              _saveAnalysis(context, noteController.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _saveAnalysis(BuildContext context, String note) {
    try {
      // Debug: Log how many search results we're saving
      debugPrint('=== SAVING ANALYSIS ===');
      debugPrint('Claim: ${analysis!.claim}');
      debugPrint('Results count: ${results?.length ?? 0}');
      if (results != null) {
        for (var r in results!) {
          debugPrint('  - ${r.title} (${r.link})');
        }
      }

      // Create structured JSON to store both AI analysis and search results
      final Map<String, dynamic> structuredData = {
        'ai_analysis': analysis!.analysis,
        'search_results': results?.map((r) => r.toMap()).toList() ?? [],
      };

      debugPrint(
        'Structured JSON search_results count: ${(structuredData['search_results'] as List).length}',
      );

      final savedAnalysis = SavedAnalysis(
        title: 'Analisis Fakta: ${analysis!.claim}',
        claim: analysis!.claim,
        verdict: analysis!.verdict,
        explanation: analysis!.explanation,
        confidence: analysis!.confidence,
        userNote: note,
        sourceUrl: analysis!.sources,
        analysis: jsonEncode(structuredData), // Store as JSON string
        savedAt: DateTime.now(),
      );

      context.read<SavedAnalysisProvider>().addAnalysis(savedAnalysis);

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
      debugPrint('Save failed: $e');
    }
  }
}
