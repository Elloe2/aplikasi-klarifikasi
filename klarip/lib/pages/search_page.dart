// ==============================================================================
// PENJELASAN UNTUK SIDANG: SEARCH PAGE (HALAMAN PENCARIAN & RAG CONTROLLER)
// ==============================================================================
// Bapak/Ibu Penguji, `search_page.dart` ini adalah "Jantung" dari UI (User Interface) aplikasi.
// Di sinilah pengguna berinteraksi langsung untuk memverifikasi klaim hoax.
//
// ALUR KERJA (RAG - Retrieval-Augmented Generation) DI SISI UI:
// 1. Pengguna mengetikkan klaim (contoh: "Bumi itu datar") di TextField.
// 2. UI mengirim perintah ke `SearchApi` untuk mencari artikel referensi (Retrieval).
// 3. UI menampilkan efek Loading (Kartu Shimmer) selagi menunggu.
// 4. Setelah AI selesai merangkum (Generation), UI menampilkan hasilnya
//    dalam bentuk Chatbot interaktif dan daftar sumber referensi.
//
// FITUR UNGGULAN YANG BISA DIJELASKAN SAAT SIDANG:
// - Cooldown System (Rate Limiting): Sistem paksa jeda 5 detik setiap kali
//   pencarian selesai. Tujuannya? Mencegah pengguna melakukan 'Spamming'
//   yang bisa membuat kuota API Key Google cepat habis.
// - Fallback State (Sistem Cadangan): Jika Google Search mati/error, aplikasi
//   tidak akan crash (tutup paksa). Sistem akan otomatis memakai "Fallback",
//   yaitu menyuruh Gemini AI menjawab sebisanya walau tanpa artikel referensi.
// - Dynamic Error Handling: Jika terdeteksi API Key (Gemini/Google) mati atau habis,
//   akan langsung muncul Pop-up (Dialog) yang mengarahkan user ke halaman Pengaturan.
// ==============================================================================

import 'dart:async'; // Untuk mengelola operasi Timer cooldown harian
import 'package:flutter/material.dart'; // Framework UI Material
import 'package:flutter/services.dart'; // Untuk menyalin teks ke clipboard HP
import 'package:provider/provider.dart'; // State management Provider
import 'package:url_launcher/url_launcher.dart'; // Membuka URL artikel berita di browser eksternal

import '../models/search_result.dart'; // Model representasi data artikel Google CSE
import '../models/gemini_analysis.dart'; // Model data analisis Gemini AI
import '../models/saved_analysis.dart'; // Model data record SQLite
import '../providers/saved_analysis_provider.dart'; // Provider pengelola SQLite riwayat
import '../providers/gemini_api_provider.dart'; // Provider API Key Gemini
import '../providers/search_api_provider.dart'; // Provider API Key Google CSE
import '../providers/custom_prompt_provider.dart'; // Provider editor custom prompt AI
import '../services/search_api.dart'; // Service perancang Query RAG
import '../theme/app_theme.dart'; // Pewarnaan gelap aplikasi
import '../widgets/error_banner.dart'; // Banner visual error
import '../utils/tutorial_utils.dart'; // Bottom sheet tutorial API key
import '../widgets/gemini_chatbot.dart'; // Widget chatbot peraga respon Gemini
import '../widgets/search_result_card.dart'; // Widget kartu artikel referensi

/// Widget utama halaman Pencarian Fakta (Tab 1 pada navigasi utama).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.api, this.onSettingsTap});

  /// Service API pencarian fakta
  final SearchApi api;

  /// Callback untuk berpindah ke Tab Pengaturan saat API key mati
  final VoidCallback? onSettingsTap;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// ==============================================================================
// SUB-WIDGET: PEMBERITAHUAN MODE FALLBACK (_FallbackNotice)
// ==============================================================================
/// Banner pemberitahuan kecil di bagian atas yang memberi tahu pengguna
/// bahwa Google Custom Search tidak tersedia dan sistem menggunakan data sisa.
class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.primarySeedColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Google Custom Search sedang tidak tersedia. Menampilkan analisis AI berbasis data yang ada.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// SUB-WIDGET: TAMPILAN FULL SCREEN MODE FALLBACK (_FallbackState)
// ==============================================================================
/// Halaman kosong representatif yang menjelaskan bahwa pencarian Google gagal total,
/// namun Gemini AI berhasil memberikan analisis perkiraan sementara.
class _FallbackState extends StatelessWidget {
  const _FallbackState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(
                  Icons.bolt_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Analisis AI fallback ditampilkan',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kami belum mendapatkan hasil dari Google Custom Search, namun Gemini tetap memberikan ringkasan berdasarkan informasi yang tersedia.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.subduedGray,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Coba cari lagi beberapa saat atau gunakan kata kunci lain untuk mendapatkan hasil lengkap.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// STATE CLASS: PUSAT LOGIKA HALAMAN PENCARIAN (_SearchPageState)
// ==============================================================================
class _SearchPageState extends State<SearchPage> {
  // === SCROLL CONTROLLER ===
  final ScrollController _scrollController = ScrollController();

  // === PAGE CONTROLLER ===
  /// Controller untuk berpindah tab horizontal secara smooth antara Analisis AI dan Hasil Berita
  final PageController _pageController = PageController();
  int _currentPageIndex = 0; // Index halaman yang aktif saat ini (0 = AI, 1 = Artikel CSE)

  // === TEXT INPUT CONTROLLERS ===
  /// Controller TextField input klaim
  final TextEditingController _controller = TextEditingController();
  /// FocusNode untuk menyembunyikan/menampilkan keyboard HP
  final FocusNode _queryFocus = FocusNode();

  // === RATE LIMITING SYSTEM ===
  /// Durasi jeda keamanan pencarian demi menjaga API Key (5 detik)
  final Duration _cooldown = const Duration(seconds: 5);

  // === SEARCH RESULTS STATE ===
  /// Menyimpan artikel berita rujukan hasil Google CSE
  List<SearchResult> _results = const [];
  /// Flag loader
  bool _isLoading = false;
  /// Objek hasil akhir analisis Gemini AI
  GeminiAnalysis? _geminiAnalysis;
  /// Penampung error jika gagal request API
  String? _error;
  /// Tanggal waktu pencarian terakhir kali berhasil dikirim
  DateTime? _lastSearchTime;
  /// Timer berkala 1 detik untuk memperbarui status cooldown
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Bersihkan semua controller untuk menghindari memory leaks di HP
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _controller.dispose();
    _queryFocus.dispose();
    _cooldownTimer?.cancel(); // Pastikan timer dimatikan saat halaman dihancurkan
    super.dispose();
  }

  void _onScroll() {
    // Callback scroll listener (disediakan jika ada penambahan panel suggestion di kemudian hari)
  }

  // ==========================================================================
  // METODE: MEMULAI COUNTDOWN TIMER COOLDOWN PENCARIAN
  // ==========================================================================
  void _startCooldownTimer() {
    _cooldownTimer?.cancel(); // Matikan timer aktif sebelumnya terlebih dahulu

    // Buat timer periodik yang berjalan setiap 1 detik
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final last = _lastSearchTime;
      if (last == null) {
        timer.cancel();
        return;
      }

      final diff = DateTime.now().difference(last);
      final remaining = _cooldown - diff;

      // Jika sisa waktu jeda telah habis, matikan timer harian
      if (remaining.isNegative) {
        setState(() {}); // Segarkan UI
        timer.cancel();
      } else {
        setState(() {}); // Segarkan progress bar UI
      }
    });
  }

  // ==========================================================================
  // METODE: MEMERIKSA STATUS COOLDOWN
  // ==========================================================================
  /// Mengembalikan sisa durasi jeda yang harus dilewati pengguna.
  /// Mengembalikan `null` jika tidak ada jeda cooldown yang aktif.
  Duration? _checkCooldown() {
    if (_lastSearchTime == null) return null;

    final diff = DateTime.now().difference(_lastSearchTime!);
    final remaining = _cooldown - diff;

    if (remaining.isNegative) {
      return null;
    }
    return remaining;
  }

  // ==========================================================================
  // METODE: PROSES PENCARIAN UTAMA (RAG ORCHESTRATION & FALLBACK SYSTEM)
  // ==========================================================================
  void _performSearchWithLimit() async {
    if (!mounted) return;

    // Hilangkan spasi berlebih pada awal/akhir query klaim
    final query = _controller.text.trim();

    // === VALIDASI UTAMA ===
    if (query.isEmpty) {
      _showSnackBar('Masukkan kata kunci pencarian.');
      return;
    }

    if (query.length < 3) {
      _showSnackBar('Kata kunci minimal 3 karakter.');
      return;
    }

    // === CEK JEDA RATE LIMITING ===
    final cooldown = _checkCooldown();
    if (cooldown != null) {
      _showSnackBar('Tunggu ${cooldown.inSeconds} detik sebelum mencari lagi.');
      return;
    }

    // === BACA KONFIGURASI API KEY ===
    final geminiProvider = context.read<GeminiApiProvider>();
    final cseProvider = context.read<SearchApiProvider>();
    final geminiApiKey = geminiProvider.apiKey;
    final cseApiKey = cseProvider.apiKey;
    final cseCx = cseProvider.cx;

    // Cek dini kegagalan key
    if (geminiProvider.isKeyExpired) {
      _showApiKeyExpiredDialog();
      return;
    }
    if (cseProvider.isKeyExpired) {
      _showCseApiKeyExpiredDialog();
      return;
    }

    // === AKTIFKAN LOADER DAN RESET ERROR ===
    setState(() {
      _isLoading = true;
      _error = null;
      _lastSearchTime = DateTime.now(); // Perbarui log waktu kirim pencarian
    });

    _startCooldownTimer(); // Mulai hitung mundur jeda 5 detik

    try {
      // Panggil orchestrator API RAG (search_api.dart)
      final response = await widget.api.search(
        query,
        limit: 20,
        geminiApiKey: geminiApiKey,
        cseApiKey: cseApiKey,
        cseCx: cseCx,
        customInstructions: context.read<CustomPromptProvider>().customInstructions,
        // Callback mencatat statistik pemakaian sukses
        onGeminiUsage: () {
          geminiProvider.recordUsage();
        },
        // Callback mendeteksi quota habis / key invalid
        onGeminiError: (statusCode, errorMessage) {
          geminiProvider.recordError(statusCode, errorMessage);
          if (mounted && (statusCode == 400 || statusCode == 403 || statusCode == 429)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showApiKeyExpiredDialog();
            });
          }
        },
        onCseUsage: () {
          cseProvider.recordUsage();
        },
        onCseError: (statusCode, errorMessage) {
          cseProvider.recordError(statusCode, errorMessage);
          if (mounted && (statusCode == 400 || statusCode == 403 || statusCode == 429)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showCseApiKeyExpiredDialog();
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          // Ambil daftar artikel pendukung dari Google CSE
          _results = response['results'] as List<SearchResult>;
          // Ambil analisis verdict dan penalaran dari Gemini AI
          _geminiAnalysis = response['gemini_analysis'] as GeminiAnalysis?;
          _isLoading = false;
          _currentPageIndex = 0; // Auto-fokus ke tab 0 (Analisis AI)
        });
      }
    } catch (e) {
      // === MANAGEMENT ERROR FALLBACK ===
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _geminiAnalysis = null;
        });
      }
    }
  }

  // ==========================================================================
  // METODE: DIALOG GOOGLE CSE KEY EXPIRED
  // ==========================================================================
  void _showCseApiKeyExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.3)),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_off,
            color: Colors.orangeAccent,
            size: 36,
          ),
        ),
        title: const Text(
          'Search API Key Bermasalah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'API key Google Custom Search yang Anda gunakan sudah tidak bisa dipakai (quota habis atau tidak valid).\n\nSilakan perbarui API key di menu Pengaturan untuk melanjutkan pencarian.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse('https://aistudio.google.com/api-keys'),
                mode: LaunchMode.externalApplication,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primarySeedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primarySeedColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.launch,
                      color: AppTheme.primarySeedColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Dapatkan API key di\nconsole.cloud.google.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySeedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onSettingsTap?.call(); // Alihkan tab ke menu pengaturan profil
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METODE: DIALOG GEMINI AI API KEY EXPIRED
  // ==========================================================================
  void _showApiKeyExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.vpn_key_off,
            color: Colors.redAccent,
            size: 36,
          ),
        ),
        title: const Text(
          'API Key Bermasalah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'API key Gemini AI yang Anda gunakan sudah tidak bisa dipakai (quota habis atau tidak valid).\n\nSilakan perbarui API key di menu Pengaturan untuk melanjutkan analisis.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primarySeedColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primarySeedColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primarySeedColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Dapatkan API key secara gratis di aistudio.google.com',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showApiKeyTutorialBottomSheet(context),
                          icon: const Icon(Icons.help_outline, size: 14),
                          label: const Text('Cara Buat Key', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse('https://aistudio.google.com/api-keys'),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.launch, size: 14),
                          label: const Text('Buka AI Studio', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primarySeedColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySeedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onSettingsTap?.call(); // Alihkan tab ke menu pengaturan profil
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METODE: MEMBUKA TAUTAN DI BROWSER HP
  // ==========================================================================
  Future<void> _openResult(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnackBar('URL tidak valid.');
      return;
    }

    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success) {
      _showSnackBar('Tidak dapat membuka tautan.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================================
  // METODE: MENYALIN TAUTAN (COPY LINK)
  // ==========================================================================
  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    _showSnackBar('Tautan sumber disalin ke clipboard.');
  }

  // ==========================================================================
  // VIEW UTAMA: BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCooldown = _checkCooldown(); // Periksa jeda 5 detik saat render

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparan agar gradient background shell terlihat
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hapus tombol back default
        title: Text(
          'Klarip',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920), // Responsive lebar desktop
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // === FORM PENCARIAN (_SearchCard) ===
                  _SearchCard(
                    controller: _controller,
                    focusNode: _queryFocus,
                    isLoading: _isLoading,
                    cooldown: onCooldown,
                    onSearch: () => _performSearchWithLimit(),
                  ),

                  // === PROGRESS BAR COUNTDOWN COOLDOWN ===
                  if (onCooldown != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tunggu ${onCooldown.inSeconds} detik sebelum mencari lagi.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: ((_cooldown.inMilliseconds - onCooldown.inMilliseconds) /
                                      _cooldown.inMilliseconds)
                                  .clamp(0.0, 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // === SPANDUK KATA KUNCI ERROR (JIKA ADA KESALAHAN PADA API) ===
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    ErrorBanner(message: _error!),
                  ],

                  // === AREA SLIDE STRUKTUR (TAB SWITCH) ===
                  if (_results.isNotEmpty || _isLoading || _geminiAnalysis != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Tab 1: Analisis AI
                          Expanded(
                            child: _TabButton(
                              icon: Icons.auto_awesome,
                              label: 'Analisis AI',
                              isActive: _currentPageIndex == 0,
                              onTap: () {
                                _pageController.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Tab 2: Hasil Pencarian Google CSE
                          Expanded(
                            child: _TabButton(
                              icon: Icons.search,
                              label: 'Hasil Pencarian',
                              isActive: _currentPageIndex == 1,
                              onTap: () {
                                _pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // === AREA VIEW UTAMA: PAGEVIEW (TAB CONTENT CONTAINER) ===
                  Expanded(
                    child: (_results.isNotEmpty || _isLoading || _geminiAnalysis != null)
                        ? PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            children: [
                              // Halaman 1: AI Chatbot Verdict View
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                child: Column(
                                  children: [
                                    if (_results.isEmpty && !_isLoading && _geminiAnalysis != null)
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: _FallbackNotice(),
                                      ),
                                    GeminiChatbot(
                                      analysis: _geminiAnalysis,
                                      results: _results,
                                      isLoading: _isLoading,
                                      onRetry: () {
                                        _performSearchWithLimit();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Halaman 2: Daftar Artikel Sumber Berita Google CSE
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _isLoading
                                    ? const _LoadingState()
                                    : _results.isEmpty
                                        ? (_geminiAnalysis != null
                                            ? const _FallbackState()
                                            : const _EmptyState())
                                        : _ResultsList(
                                            results: _results,
                                            onOpen: _openResult,
                                            onCopy: _copyLink,
                                            query: _controller.text,
                                            onSave: (result) => _showSaveDialog(context, result),
                                          ),
                              ),
                            ],
                          )
                        : const _EmptyState(), // Empty State pemandu awal
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // METODE: DIALOG SAVE MANUAL ITEM ARTIKEL CSE KE SQLite LOKAL
  // ==========================================================================
  void _showSaveDialog(BuildContext context, SearchResult result) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Simpan ke Koleksi',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambahkan catatan pribadi untuk hasil pencarian ini:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Contoh: Artikel ini menjelaskan detail tentang...',
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
              _saveResult(context, result, noteController.text);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METODE: SIMPAN ARTIKEL MANUAL SQLite (CRUD CREATE)
  // ==========================================================================
  void _saveResult(BuildContext context, SearchResult result, String note) {
    try {
      final savedAnalysis = SavedAnalysis(
        title: result.title,
        claim: _controller.text,
        verdict: 'Hasil Pencarian',
        explanation: result.snippet,
        analysis: result.snippet,
        confidence: 'Tinggi',
        userNote: note,
        sourceUrl: result.link,
        savedAt: DateTime.now(),
      );

      context.read<SavedAnalysisProvider>().addAnalysis(savedAnalysis);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil disimpan ke koleksi')),
        );
      }
    } catch (e) {
      debugPrint('Gagal menyimpan hasil: $e');
    }
  }
}

// === SUGGESTION PANEL CLASSES REMOVED ===
// All suggestion panel related classes have been removed per user request
// (_SuggestionPanel, _SuggestionChips, _AnimatedSuggestionChip)

// === SEARCH CARD WIDGET ===
// Widget stateful yang menangani input pencarian dengan search button
// Komponen utama untuk user interaction dengan fitur loading state dan cooldown indicator
// ==============================================================================
// SUB-WIDGET: KARTU INPUT PENCARIAN FAKTA (_SearchCard)
// ==============================================================================
/// Komponen input dinamis yang mewadahi input TextField dan tombol Cari.
class _SearchCard extends StatefulWidget {
  const _SearchCard({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.cooldown,
    required this.onSearch,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final Duration? cooldown;
  final VoidCallback onSearch;

  @override
  State<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<_SearchCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Input TextField Klaim
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: (_) => _performSearch(), // Trigger cari saat menekan tombol "Enter" di keyboard HP
                    textInputAction: TextInputAction.search, // Tampilkan tombol ikon kaca pembesar di keyboard HP
                    decoration: InputDecoration(
                      hintText: "Cari fakta dari klaim di media sosial...",
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryGradient.colors.first,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Eksekusi Cari dengan spinner loader internal
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: widget.isLoading ? null : _performSearch,
                    icon: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    widget.onSearch();
  }
}

// ==============================================================================
// SUB-WIDGET: TAMPILAN LOADER ANTAR-MUKA PENCARIAN (_LoadingState)
// ==============================================================================
/// Spinner loader berukuran besar dengan teks informatif saat memverifikasi klaim.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mencari sumber terpercaya...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// SUB-WIDGET: TAMPILAN AWAL SEBELUM PENCARIAN (_EmptyState)
// ==============================================================================
/// Halaman panduan utama yang menampilkan tips verifikasi hoax, judul bersinar,
/// dan logo kacamata pembesar Klarip dengan animasi pulse scaling.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === LOGO KLARIP ANIMASI PULSE (SKALA DENYUT) ===
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Image.asset(
                  'assets/logo/logo_klarifikasi_hanya_icon_kacamata_pembesar.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // === JUDUL BERSINAR (SHADER MASK) ===
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ).createShader(bounds),
                child: Text(
                  'Verifikasi klaim di media sosial',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Penjelasan singkat aplikasi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  "Ketikkan klaim dari sosial media yang ingin diperiksa. Sistem kami akan mencari sumber terpercaya untuk memverifikasi kebenarannya.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // === BAGIAN INTERAKTIF: TIPS MENDETEKSI HOAX ===
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGradient.colors.first.withValues(alpha: 0.1),
                      AppTheme.accentGradient.colors.first.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGradient.colors.first.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppTheme.tertiaryAccentColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tips Verifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _TipItem(text: 'Periksa tanggal berita dan klaim yang ada'),
                    const _TipItem(text: 'Bandingkan dengan sumber resmi pemerintah atau lembaga terpercaya'),
                    const _TipItem(text: 'Waspadai judul clickbait yang provokatif di internet'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// SUB-WIDGET: ITEM BARIS TIPS (_TipItem)
// ==============================================================================
class _TipItem extends StatelessWidget {
  const _TipItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.tertiaryAccentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// SUB-WIDGET: DAFTAR KARTU BERITA RUJUKAN (_ResultsList)
// ==============================================================================
class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.onOpen,
    required this.onCopy,
    required this.query,
    required this.onSave,
  });

  final List<SearchResult> results;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onCopy;
  final String query;
  final ValueChanged<SearchResult> onSave;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: ValueKey(results.length),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16), // Spasi vertikal antar kartu berita
      itemBuilder: (context, index) {
        final result = results[index];
        // Bungkus kartu berita dengan animasi masuk bertahap (staggered)
        return _AnimatedResultCard(
          result: result,
          onOpen: onOpen,
          onCopy: onCopy,
          onSave: onSave,
          index: index, // Mengirimkan index untuk hitung durasi jeda delay animasi
          query: query,
        );
      },
    );
  }
}

// ==============================================================================
// SUB-WIDGET: ANIMASI MASUK KARTU RUJUKAN (_AnimatedResultCard & State)
// ==============================================================================
/// Menangani efek gerakan meluncur dari kanan ke kiri (slide transition)
/// dan efek memudar (fade transition) beruntun/staggered.
class _AnimatedResultCard extends StatefulWidget {
  final SearchResult result;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onCopy;
  final ValueChanged<SearchResult> onSave;
  final int index;
  final String query;

  const _AnimatedResultCard({
    required this.result,
    required this.onOpen,
    required this.onCopy,
    required this.onSave,
    required this.index,
    required this.query,
  });

  @override
  State<_AnimatedResultCard> createState() => _AnimatedResultCardState();
}

class _AnimatedResultCardState extends State<_AnimatedResultCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // Durasi total animasi meluncur
      vsync: this,
    );

    // Animasi meluncur sejauh 50 piksel ke arah kiri
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Animasi memudar dari transparan (0.0) ke penuh (1.0)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // === STAGGERED EFFECT (KARTU MUNCUL BERGILIRAN) ===
    // Delay kemunculan kartu = indeks kartu x 150 milidetik
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.forward(); // Jalankan animasi
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SearchResultCard(
              result: widget.result,
              onOpen: widget.onOpen,
              onCopy: widget.onCopy,
              onSave: () => widget.onSave(widget.result),
            ),
          ),
        );
      },
    );
  }
}

// ==============================================================================
// SUB-WIDGET: TOMBOL TAB PENGALIH VIEW (_TabButton)
// ==============================================================================
/// Tombol dinamis dengan dekorasi gradasi jika aktif untuk beralih menu.
class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null, // Gradasi bersinar jika aktif
          color: isActive ? null : AppTheme.surfaceElevated, // Abu gelap jika tidak aktif
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : AppTheme.subduedGray,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? Colors.white : AppTheme.subduedGray,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

