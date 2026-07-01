// ==============================================================================
// PENJELASAN UNTUK SIDANG: SAVED PAGE (HALAMAN KOLEKSI / RIWAYAT)
// ==============================================================================
// Bapak/Ibu Penguji, file `saved_page.dart` ini mengatur tampilan halaman "Koleksi".
// Di halaman inilah seluruh riwayat penelusuran hoax pengguna disimpan secara lokal.
//
// FITUR UNGGULAN YANG BISA DIJELASKAN SAAT SIDANG:
// 1. **Daftar Koleksi**: Mengambil data dari SQLite (Database Lokal). Kelebihannya,
//    pengguna bisa melihat riwayat meskipun sedang tidak ada koneksi internet (Offline Mode).
// 2. **Ekspor & Impor (Backup)**: Aplikasi bisa mengekspor database SQLite menjadi
//    file `.json` dan membagikannya ke WhatsApp/Google Drive. Jika user ganti HP,
//    mereka tinggal mengimpor file `.json` tersebut agar riwayatnya kembali (Restore).
//    Algoritma impor kami juga otomatis memblokir "Data Duplikat" agar tidak ganda.
// 3. **CRUD (Create, Read, Update, Delete)**: Di halaman ini, pengguna bisa:
//    - Read: Membaca ulang hasil analisis AI.
//    - Update: Menambah catatan/kesimpulan pribadi (Personal Note) pada riwayat tersebut.
//    - Delete: Menghapus riwayat yang dirasa tidak penting.
// 4. **Optimistic UI (Fitur Favorit)**: Ketika tombol bintang ditekan, UI langsung 
//    berubah warna seketika tanpa menunggu loading dari database. Ini membuat
//    aplikasi terasa sangat cepat (Responsif).
// ==============================================================================

import 'dart:convert'; // Untuk encoding/decoding JSON saat export dan import
import 'dart:io'; // Operasi input/output file pada sistem operasi
import 'package:flutter/material.dart'; // Komponen desain Material UI Flutter
import 'package:flutter/services.dart'; // Untuk mengakses Clipboard HP (salin teks)
import 'package:provider/provider.dart'; // State management Provider untuk sinkronisasi state
import 'package:url_launcher/url_launcher.dart'; // Membuka link browser eksternal
import 'package:share_plus/share_plus.dart'; // Berbagi berkas via dialog sharing HP
import 'package:file_picker/file_picker.dart'; // Mengakses explorer HP untuk pilih file
import 'package:path_provider/path_provider.dart'; // Mendapatkan path direktori sistem HP
import '../models/saved_analysis.dart'; // Model data riwayat analisis
import '../models/search_result.dart'; // Model data satu artikel hasil pencarian
import '../providers/saved_analysis_provider.dart'; // Provider pengelola riwayat analisis
import '../theme/app_theme.dart'; // Pengaturan warna dan tema aplikasi
import '../widgets/search_result_card.dart'; // Card kustom untuk menampilkan artikel sumber

/// Widget halaman koleksi (SavedPage) yang menampilkan riwayat analisis tersimpan.
/// Ditampilkan sebagai Tab 2 pada HomeShell.
class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
    // Memuat data riwayat dari database saat halaman pertama kali dibuka.
    // Future.microtask digunakan agar pemanggilan loadAnalyses dilakukan tepat
    // setelah frame pertama selesai dibangun (tidak menghambat rendering awal).
    final provider = context.read<SavedAnalysisProvider>();
    Future.microtask(() => provider.loadAnalyses());
  }

  // ==========================================================================
  // METODE: EKSPOR RIWAYAT (EXPORT BACKUP)
  // ==========================================================================
  /// Mengambil semua riwayat analisis pengguna, mengonversinya menjadi format JSON,
  /// menyimpannya ke dalam file temporer di memori HP, dan memicu dialog berbagi HP.
  Future<void> _exportHistory() async {
    final provider = context.read<SavedAnalysisProvider>();

    // Validasi: Jika tidak ada riwayat sama sekali, batalkan ekspor.
    if (provider.analyses.isEmpty) {
      _showSnackBar('Tidak ada data untuk diekspor', isError: true);
      return;
    }

    try {
      // 1. Konversi daftar riwayat di memori menjadi format teks JSON yang rapi
      final jsonString = provider.exportToJson();

      // 2. Dapatkan direktori folder temporer yang disediakan oleh sistem operasi HP
      final tempDir = await getTemporaryDirectory();
      
      // 3. Buat nama file unik menggunakan format timestamp (waktu saat ini)
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-') // Karakter ':' ilegal untuk nama file di beberapa OS
          .split('.')
          .first;
      final fileName = 'klarip_backup_$timestamp.json';
      
      // 4. Tulis file JSON tersebut secara fisik ke memori HP
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // 5. Buka dialog share sistem operasi HP agar file JSON tersebut bisa dikirim
      //    lewat WhatsApp, Email, Drive, atau disimpan di file manager.
      final xFile = XFile(file.path, mimeType: 'application/json');
      final result = await Share.shareXFiles(
        [xFile],
        subject: 'Backup Klarip - ${provider.analyses.length} koleksi',
        text: 'Backup data koleksi Klarip (${provider.analyses.length} item)',
      );

      // Tampilkan konfirmasi jika proses berhasil
      if (result.status == ShareResultStatus.success) {
        _showSnackBar('${provider.analyses.length} koleksi berhasil diekspor');
      }
    } catch (e) {
      _showSnackBar('Gagal mengekspor: $e', isError: true);
    }
  }

  // ==========================================================================
  // METODE: IMPOR RIWAYAT (IMPORT BACKUP)
  // ==========================================================================
  /// Mengaktifkan file picker untuk memilih file .json backup aplikasi Klarip,
  /// mem-parsing isinya, dan menyimpannya ke SQLite. Skip data yang duplikat.
  Future<void> _importHistory() async {
    try {
      // 1. Tampilkan dialog konfirmasi persetujuan terlebih dahulu
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Row(
            children: [
              Icon(Icons.file_download_outlined, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text('Import Koleksi', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Pilih file backup (.json) dari Klarip untuk mengimpor koleksi. Data duplikat akan dilewati secara otomatis.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Pilih File'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primarySeedColor,
              ),
            ),
          ],
        ),
      );

      // Jika user memilih Batal, hentikan fungsi.
      if (confirmed != true) return;

      // 2. Jalankan file picker sistem untuk menyaring file ber-ekstensi .json saja
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      // Jika user membatalkan pemilihan file, keluar dari fungsi.
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        _showSnackBar('Gagal membaca file', isError: true);
        return;
      }

      // 3. Baca teks di dalam file JSON tersebut
      final file = File(filePath);
      final jsonString = await file.readAsString();

      // 4. Tampilkan layar loading (blocking dialog) agar user tahu proses sedang berjalan
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Row(
            children: [
              CircularProgressIndicator(color: AppTheme.primarySeedColor),
              SizedBox(width: 24),
              Text('Mengimpor data...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      // 5. Kirim data teks JSON ke provider untuk diproses dan dimasukkan ke SQLite
      final provider = context.read<SavedAnalysisProvider>();
      final importedCount = await provider.importFromJson(jsonString);

      // 6. Tutup dialog loading
      if (mounted) Navigator.pop(context);

      // 7. Berikan feedback hasil impor kepada pengguna
      if (importedCount > 0) {
        _showSnackBar('$importedCount koleksi berhasil diimpor');
      } else {
        _showSnackBar(
          'Tidak ada data baru untuk diimpor (semua sudah ada)',
          isError: false,
        );
      }
    } on FormatException catch (e) {
      // Tutup dialog loading jika terjadi format error
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      // Tutup dialog loading jika terjadi error umum
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showSnackBar('Gagal mengimpor: $e', isError: true);
    }
  }

  /// Utilitas pembantu untuk menampilkan pemberitahuan mengambang di bawah layar.
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : AppTheme.primarySeedColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================================================
  // TAMPILAN UTAMA (BUILD)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // watch() digunakan untuk mendengarkan perubahan daftar riwayat secara dinamis
    final provider = context.watch<SavedAnalysisProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparan agar gradient background di bawah terlihat
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === AREA HEADER ===
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Halaman & Subjudul
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koleksi Fakta',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Arsip analisis hoaks dan catatan pribadi Anda.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tombol Kebab Menu (...) untuk Aksi Ekspor / Impor
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      color: AppTheme.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      offset: const Offset(0, 48),
                      onSelected: (value) {
                        if (value == 'export') {
                          _exportHistory();
                        } else if (value == 'import') {
                          _importHistory();
                        }
                      },
                      itemBuilder: (context) => [
                        // Tombol menu Ekspor
                        PopupMenuItem<String>(
                          value: 'export',
                          enabled: provider.analyses.isNotEmpty, // Nonaktif jika koleksi kosong
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                                color: provider.analyses.isNotEmpty
                                    ? AppTheme.primarySeedColor
                                    : Colors.white24,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ekspor Koleksi',
                                    style: TextStyle(
                                      color: provider.analyses.isNotEmpty
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    provider.analyses.isNotEmpty
                                        ? '${provider.analyses.length} item'
                                        : 'Tidak ada data',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        // Tombol menu Impor
                        const PopupMenuItem<String>(
                          value: 'import',
                          child: Row(
                            children: [
                              Icon(
                                Icons.file_download_outlined,
                                color: Colors.cyanAccent,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Impor Koleksi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Dari file backup (.json)',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // === BAGIAN KONTEN UTAMA ===
              // Menggunakan percabangan kondisi:
              // 1. Loading: Tampilkan spinner lingkaran
              // 2. Kosong: Tampilkan ilustrasi Empty State
              // 3. Ada data: Tampilkan list builder kartu riwayat
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.analyses.isEmpty
                        ? _buildEmptyState(theme)
                        : _buildList(provider.analyses),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tampilan visual ketika database kosong (belum ada riwayat yang disimpan)
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.white.withValues(alpha: 0.24),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada koleksi',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Simpan hasil analisis pencarian di sini.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 24),
          // Tombol impor yang langsung diletakkan di tengah untuk kemudahan akses
          OutlinedButton.icon(
            onPressed: _importHistory,
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('Impor dari Backup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun daftar gulir (scrollable list) yang menampung kartu riwayat
  Widget _buildList(List<SavedAnalysis> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _SavedItemCard(item: item);
      },
    );
  }
}

// ==============================================================================
// SUB-WIDGET: KARTU ITEM RIWAYAT (_SavedItemCard)
// ==============================================================================
/// Menampilkan satu baris ringkasan data riwayat yang disimpan.
class _SavedItemCard extends StatelessWidget {
  final SavedAnalysis item;

  const _SavedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _showDetail(context), // Ketuk kartu untuk buka detail (Bottom Sheet)
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER: BADGE VERDICT & TOMBOL FAVORIT ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge Hasil Analisis (DIDUKUNG / TIDAK DIDUKUNG / VERIFIKASI)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getVerdictColor(item.verdict).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getVerdictColor(item.verdict).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _formatVerdict(item.verdict),
                      style: TextStyle(
                        color: _getVerdictColor(item.verdict),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Tombol Favorit (Bintang)
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      color: item.isFavorite ? Colors.amber : Colors.white38,
                    ),
                    onPressed: () {
                      // Mengubah status favorit di database SQLite lokal
                      context.read<SavedAnalysisProvider>().toggleFavorite(item.id!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // === JUDUL KLAIM ===
              Text(
                _cleanText(item.claim),
                maxLines: 2, // Batasi teks maksimal 2 baris agar tetap rapi
                overflow: TextOverflow.ellipsis, // Sembunyikan sisa teks dengan tanda titik-titik (...)
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // === PRATINJAU CATATAN USER (JIKA ADA) ===
              if (item.userNote.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, size: 16, color: Colors.white54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.userNote,
                          maxLines: 1, // Hanya pratinjau 1 baris di kartu luar
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Membuka Bottom Sheet meluncur dari bawah untuk melihat detail analisis lengkap.
  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Memungkinkan Bottom Sheet ditarik tinggi hingga 85% layar
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(item: item),
    );
  }

  /// Helper untuk mewarnai teks badge verdict agar konsisten
  Color _getVerdictColor(String verdict) {
    switch (verdict) {
      case 'DIDUKUNG_DATA':
        return const Color(0xFF10B981); // Hijau
      case 'TIDAK_DIDUKUNG_DATA':
        return const Color(0xFFEF4444); // Merah
      case 'MEMERLUKAN_VERIFIKASI':
        return const Color(0xFFF59E0B); // Kuning
      case 'Hasil Pencarian':
        return Colors.cyanAccent; // Cyan untuk mode pencarian berita murni
      default:
        return Colors.blue;
    }
  }

  /// Merapikan teks verdict (misal: "DIDUKUNG_DATA" -> "DIDUKUNG DATA")
  String _formatVerdict(String verdict) {
    if (verdict == 'Hasil Pencarian') return 'Pencarian Web';
    return verdict.replaceAll('_', ' ');
  }
}

// ==============================================================================
// SUB-WIDGET: DIALOG LEMBAR DETAIL (_DetailSheet)
// ==============================================================================
/// Menampilkan isi detail analisis AI, daftar artikel referensi yang digunakan,
/// dan menyediakan form sunting (CRUD Update) catatan pribadi serta tombol hapus.
class _DetailSheet extends StatefulWidget {
  final SavedAnalysis item;

  const _DetailSheet({required this.item});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late TextEditingController _noteController;
  bool _isEditing = false; // State: Apakah user sedang dalam mode mengetik catatan?

  @override
  void initState() {
    super.initState();
    // Isi TextField catatan awal dengan catatan yang sudah ada di database
    _noteController = TextEditingController(text: widget.item.userNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Cek apakah keyboard HP sedang muncul di layar untuk menyesuaikan ruang spacer di bawah
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Batasi tinggi max 85% layar
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Garis pegangan kecil penanda Bottom Sheet bisa digeser turun untuk ditutup
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // === TOMBOL AKSI ATAS (TUTUP & HAPUS) ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context), // Tutup Bottom Sheet
                ),
                Row(
                  children: [
                    // Tombol Hapus (CRUD Delete)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // === AREA ISI DETAIL (SCROLLABLE LIST) ===
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Label Teks Klaim
                Text(
                  'Klaim:',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 4),
                // Isi Teks Klaim
                Text(
                  _cleanText(widget.item.claim),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Bagian Hasil Analisis AI
                _buildAnalysisSection(theme),
                const SizedBox(height: 24),

                // Bagian CRUD Catatan Pribadi
                _buildNoteSection(theme),

                // Spacer pengganjal saat keyboard mengetik muncul agar textfield tidak tertutup keyboard
                SizedBox(height: isKeyboardVisible ? 300 : 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun box berlatar belakang abu untuk menampilkan penjelasan ringkas AI
  Widget _buildAnalysisSection(ThemeData theme) {
    final isSearchResult = widget.item.verdict == 'Hasil Pencarian';
    final accentColor = isSearchResult ? Colors.cyanAccent : Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSearchResult ? Icons.search : Icons.auto_awesome,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSearchResult ? 'Ringkasan Web' : 'Analisis AI',
                style: theme.textTheme.titleMedium?.copyWith(color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.item.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          // Jika ada data analisis mendalam terstruktur
          if (widget.item.analysis.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 32),
            _buildStructuredContent(theme, widget.item.analysis),
          ],
        ],
      ),
    );
  }

  /// Memproses isi data terstruktur di database.
  /// Data artikel disimpan dalam format teks ter-serialize JSON agar menghemat tabel SQLite.
  /// Di sini kita deserialisasi kembali untuk menampilkan daftar kartu artikel sumber yang dirujuk.
  Widget _buildStructuredContent(ThemeData theme, String analysisContent) {
    try {
      final data = jsonDecode(analysisContent);
      if (data is Map && data.containsKey('ai_analysis') && data.containsKey('search_results')) {
        final aiText = data['ai_analysis'] as String;
        final rawResults = data['search_results'] as List;
        final results = rawResults
            .map((r) => SearchResult.fromJson(r as Map<String, dynamic>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Penjelasan mendalam dari AI
            if (aiText.isNotEmpty) ...[
              Text(
                aiText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Header bagian daftar website sumber
            Row(
              children: [
                Icon(Icons.language, color: AppTheme.primarySeedColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Sumber Pencarian (${results.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tampilkan list kartu referensi artikel
            if (results.isNotEmpty)
              ...results.map(
                (res) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SearchResultCard(
                    result: res,
                    showSaveButton: false, // Sudah dalam folder simpan, tidak perlu tombol simpan lagi
                    onOpen: (url) async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    onCopy: (url) {
                      Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link disalin')),
                        );
                      }
                    },
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white30, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tidak ada sumber pencarian tersimpan untuk analisis ini.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }
    } catch (e) {
      debugPrint('Failed to parse structured content: $e');
    }

    // Tampilan default berupa teks biasa jika data bukan JSON terstruktur
    return Text(
      analysisContent,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white54,
        height: 1.5,
      ),
    );
  }

  // ==========================================================================
  // FITUR: CRUD UPDATE - EDIT CATATAN PRIBADI
  // ==========================================================================
  /// Mengatur area pengisian dan pengeditan catatan pribadi.
  /// User bisa beralih antara "mode melihat teks" dan "mode input teks" secara dinamis.
  Widget _buildNoteSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catatan Pribadi',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            // Tampilkan tombol "Edit" hanya jika sedang tidak dalam mode mengetik
            if (!_isEditing)
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          Column(
            children: [
              // Input Field Catatan
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tulis tanggapan atau catatan Anda...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tombol Batal Edit
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _noteController.text = widget.item.userNote; // Kembalikan teks ke awal sebelum diedit
                      });
                    },
                    child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Simpan Perubahan (Operasi Update Database)
                  ElevatedButton(
                    onPressed: () async {
                      // Panggil provider untuk memperbarui data di database SQLite
                      await context.read<SavedAnalysisProvider>().updateNote(
                            widget.item.id!,
                            _noteController.text,
                          );
                      setState(() => _isEditing = false); // Kembali ke mode melihat teks
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Catatan diperbarui')),
                        );
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          )
        else
          // Tampilan teks catatan yang sudah disimpan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              widget.item.userNote.isEmpty ? 'Belum ada catatan' : widget.item.userNote,
              style: TextStyle(
                color: widget.item.userNote.isEmpty ? Colors.white30 : Colors.white70,
                fontStyle: widget.item.userNote.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // FITUR: CRUD DELETE - HAPUS DATA RIWAYAT
  // ==========================================================================
  /// Menampilkan dialog konfirmasi sebelum menghapus data agar tidak terhapus tidak sengaja.
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Hapus Koleksi?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Analisis ini akan dihapus permanen dari penyimpanan lokal Anda.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          // Tombol Hapus Konfirmasi
          TextButton(
            onPressed: () {
              // Pemicu operasi delete SQLite melalui provider
              context.read<SavedAnalysisProvider>().deleteAnalysis(widget.item.id!);
              
              Navigator.pop(context); // Tutup popup dialog konfirmasi
              Navigator.pop(context); // Tutup Bottom Sheet detail analisis
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// METHOD UTILITY
// ==============================================================================
/// Membersihkan teks klaim dari bungkus struktur JSON jika terjadi kegagalan jaringan/sistem.
String _cleanText(String text) {
  text = text.trim();
  if (text.startsWith('{') && text.endsWith('}')) {
    try {
      final data = jsonDecode(text);
      if (data is Map && data.containsKey('ai_analysis')) {
        final analysis = data['ai_analysis'] as String;
        final summary = analysis.split('.').first;
        return summary.length > 100 ? '${summary.substring(0, 100)}...' : summary;
      }
    } catch (_) {}
  }
  return text;
}
