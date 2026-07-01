// ==============================================================================
// WIDGET: DAFTAR DETAIL SIKAP SUMBER (SOURCE DETAILS LIST) - KLARIP
// ==============================================================================
// File ini mengimplementasikan widget kustom [SourceDetailsList] dan [_SourceDetailCard].
// Widget ini berfungsi merender daftar analisis sikap (stance) dari setiap artikel berita
// yang dirujuk oleh Gemini AI.
//
// DETAIL DETAIL KARTU RUJUKAN:
// Setiap artikel berita rujukan dianalisis oleh Gemini AI dan diklasifikasikan menjadi:
// 1. **SUPPORT**: Artikel mendukung kebenaran klaim (Warna Hijau).
// 2. **OPPOSE**: Artikel menentang/membantah klaim (Warna Merah).
// 3. **NEUTRAL**: Artikel membahas secara netral/tidak berpihak (Warna Jingga/Kuning).
//
// STRUKTUR DATA TIAP RUJUKAN:
// - `index`: Nomor urut artikel rujukan (sinkron dengan [SearchResultCard]).
// - `reasoning`: Penjelasan logis mengapa artikel tersebut diklasifikasikan ke stance tertentu.
// - `quote`: Kutipan langsung kalimat dari isi berita sebagai bukti otentik.
// ==============================================================================

import 'package:flutter/material.dart'; // Paket komponen UI Flutter
import '../models/source_analysis.dart'; // Model representasi klasifikasi sikap rujukan berita
import '../theme/app_theme.dart'; // Konstanta warna tema gelap aplikasi

/// Widget utama untuk merender kumpulan detail analisis sikap berita rujukan.
class SourceDetailsList extends StatelessWidget {
  /// Kumpulan objek rujukan yang lolos dari parsing json Gemini
  final List<SourceAnalysis> sources;

  const SourceDetailsList({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada rujukan sama sekali, sembunyikan widget
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul header daftar detail rujukan
        Text(
          'Detail Sumber (${sources.length})',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Gunakan ListView.separated untuk menyusun daftar secara vertikal dengan rapi
        ListView.separated(
          shrinkWrap: true, // Cegah error unbounded height di dalam SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Scroll dikontrol oleh widget parent
          itemCount: sources.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8), // Jarak antar item rujukan
          itemBuilder: (context, index) {
            final source = sources[index];
            return _SourceDetailCard(source: source); // Render card detail masing-masing rujukan
          },
        ),
      ],
    );
  }
}

/// Widget internal (private class) untuk merender satu kotak detail sikap rujukan.
class _SourceDetailCard extends StatelessWidget {
  final SourceAnalysis source;

  const _SourceDetailCard({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        // Border diwarnai sesuai klasifikasi sikap rujukan
        border: Border.all(
          color: _getStanceColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === BARIS HEADER: BADGE NOMOR URUT & SIKAP (STANCE) ===
          Row(
            children: [
              // Kotak nomor index rujukan
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getStanceColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${source.index}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Teks nama sikap (misal: "Mendukung Klaim", "Membantah Klaim")
              Expanded(
                child: Text(
                  source.stanceText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getStanceColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // === PENJELASAN LOGIS / PENALARAN (REASONING) ===
          Text(
            source.reasoning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.subduedGray,
              height: 1.4,
            ),
          ),

          // === BUKTI KUTIPAN LANGSUNG (QUOTE) ===
          // Hanya dirender jika AI berhasil mengekstrak kutipan penting dari artikel berita
          if (source.hasQuote) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
                // Border garis tegak di sebelah kiri (left border style)
                border: Border(
                  left: BorderSide(color: _getStanceColor(), width: 3),
                ),
              ),
              child: Text(
                '"${source.quote}"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedGray,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER METODE: MENDAPATKAN WARNA BERDASARKAN SIKAP (STANCE COLOR)
  // ==========================================================================
  Color _getStanceColor() {
    switch (source.stance) {
      case 'SUPPORT':
        return const Color(0xFF10B981); // Hijau untuk yang mendukung fakta/klaim
      case 'OPPOSE':
        return const Color(0xFFEF4444); // Merah untuk yang membantah/menolak fakta
      case 'NEUTRAL':
        return const Color(0xFFF59E0B); // Jingga/Kuning untuk rujukan berita netral
      default:
        return Colors.grey;
    }
  }
}

