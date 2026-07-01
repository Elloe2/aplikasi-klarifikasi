// ==============================================================================
// WIDGET: KARTU HASIL PENCARIAN (SEARCH RESULT CARD) - KLARIP
// ==============================================================================
// File ini mengimplementasikan widget kustom [SearchResultCard].
// Widget ini bertugas merender setiap item rujukan berita yang ditemukan oleh
// Google Custom Search Engine (CSE).
//
// FITUR UTAMA CARD:
// 1. **Formatting Social Media Link**: Mendeteksi tautan mentah dan menyederhanakannya
//    (misal: "instagram.com/p/..." diubah menjadi label cantik "Postingan di Instagram").
// 2. **Relative Time Calculator**: Menghitung selisih waktu publikasi berita dari saat ini
//    secara real-time (misal: "2 hari yang lalu" atau "15 jam yang lalu").
// 3. **Image Network Loader**: Dilengkapi loading fallback (ikon placeholder)
//    dan error handling jika URL gambar thumbnail berita rusak/tidak dapat dimuat.
// 4. **Interaksi Aksi**:
//    - "Buka sumber": Membuka URL artikel berita di browser HP eksternal.
//    - "Salin tautan": Menyalin URL ke clipboard HP untuk dibagikan.
// ==============================================================================

import 'package:flutter/material.dart'; // Paket komponen UI Flutter
import '../models/search_result.dart'; // Model data representasi artikel berita Google CSE
import '../theme/app_theme.dart'; // Warna dan gradasi tema gelap Klarip

/// Kartu visual untuk merender detail satu rujukan artikel berita.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.result, // Objek model SearchResult berisi judul, tautan, snippet, dll
    required this.onOpen, // Callback pemicu untuk membuka URL di browser HP
    required this.onCopy, // Callback pemicu menyalin URL ke clipboard
    this.onSave,
    this.showSaveButton = true,
  });

  final SearchResult result;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onCopy;
  final VoidCallback? onSave;
  final bool showSaveButton;

  // ==========================================================================
  // HELPER METODE: FORMATING DISPLAY LINK MEDIA SOSIAL
  // ==========================================================================
  /// Mendeteksi domain link dan menyulapnya menjadi teks penjelasan lokal yang rapi.
  String _formatSocialMediaLink(String displayLink) {
    final lowerLink = displayLink.toLowerCase();

    if (lowerLink.contains('instagram.com')) {
      return 'Postingan di Instagram';
    } else if (lowerLink.contains('facebook.com') ||
        lowerLink.contains('fb.com')) {
      return 'Postingan di Facebook';
    } else if (lowerLink.contains('twitter.com') ||
        lowerLink.contains('x.com')) {
      return 'Postingan di X (Twitter)';
    } else if (lowerLink.contains('youtube.com') ||
        lowerLink.contains('youtu.be')) {
      return 'Postingan di YouTube';
    } else if (lowerLink.contains('reddit.com')) {
      return 'Postingan di Reddit';
    } else if (lowerLink.contains('tiktok.com')) {
      return 'Postingan di TikTok';
    } else if (lowerLink.contains('linkedin.com')) {
      return 'Postingan di LinkedIn';
    } else if (lowerLink.contains('threads.net')) {
      return 'Postingan di Threads';
    }

    return displayLink; // Kembalikan domain aslinya jika bukan media sosial umum
  }

  // ==========================================================================
  // HELPER METODE: KALKULASI WAKTU RELATIF (RELATIVE TIME)
  // ==========================================================================
  /// Mengukur jarak waktu terbit berita terhadap waktu lokal sekarang (Time Difference).
  String _getRelativeTime(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date); // Hitung selisih waktu

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // ==========================================================================
  // TAMPILAN UTAMA (BUILD METHOD)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient, // Latar gradasi gelap yang elegan
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === GAMBAR THUMBNAIL BERITA ===
                // Ditampilkan di kiri jika artikel memiliki image URL valid dari Google CSE
                if (result.thumbnail != null && result.thumbnail!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      result.thumbnail!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      // Penanganan error: Sembunyikan jika URL gambar rusak
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                      // Penanganan loading: Tampilkan ikon placeholder abu selama loading
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.white38,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),

                // Spasi antara thumbnail gambar dan informasi teks
                if (result.thumbnail != null && result.thumbnail!.isNotEmpty)
                  const SizedBox(width: 16),

                // === KONTEN TEKS INFORMASI BERITA ===
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul berita
                      Text(
                        result.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Badge domain portal berita (displayLink)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFECE3), // Warna beige netral agar kontras
                                borderRadius: BorderRadius.circular(999), // Pill shape border
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.public,
                                    size: 16,
                                    color: Color(0xFF4A70A9),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _formatSocialMediaLink(result.displayLink),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                            color: const Color(0xFF4A70A9),
                                            fontWeight: FontWeight.w600,
                                          ),
                                      overflow: TextOverflow.ellipsis, // Potong teks jika domain terlalu lebar
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Waktu relatif penerbitan berita (italic text)
                      if (_getRelativeTime(result.publishedDate).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Text(
                            _getRelativeTime(result.publishedDate),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Cuplikan isi berita singkat (Snippet)
                      Text(
                        result.snippet,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // === BARIS TOMBOL INTERAKSI (ACTION BUTTONS) ===
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                // Tombol "Buka sumber"
                OutlinedButton.icon(
                  onPressed: result.link.isEmpty
                      ? null
                      : () => onOpen(result.link),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    minimumSize: const Size(120, 44),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Buka sumber'),
                ),

                // Tombol "Salin tautan"
                OutlinedButton.icon(
                  onPressed: result.link.isEmpty
                      ? null
                      : () => onCopy(result.link),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    minimumSize: const Size(120, 44),
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Salin tautan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

