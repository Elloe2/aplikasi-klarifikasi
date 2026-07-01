// ==============================================================================
// PENJELASAN UNTUK SIDANG: SETTINGS PAGE (HALAMAN PENGATURAN)
// ==============================================================================
// Bapak/Ibu Penguji, `settings_page.dart` ini adalah "Pusat Kendali" aplikasi.
// Halaman ini tidak hanya untuk mengatur profil, tetapi juga mengontrol "Otak" AI.
//
// FITUR UNGGULAN YANG BISA DIJELASKAN SAAT SIDANG:
// 1. **Manajemen API Key (Bring Your Own Key / BYOK)**: Mengapa pengguna harus 
//    memasukkan API Key Gemini mereka sendiri? Karena layanan API berbayar/dibatasi.
//    Dengan sistem BYOK, aplikasi ini menjadi 100% gratis selamanya untuk developer,
//    karena beban kuota (rate-limit) ditanggung oleh masing-masing pengguna.
// 2. **Custom Prompt Editor**: Kami membuat inovasi di mana pengguna (atau peneliti)
//    bisa mengedit instruksi (Prompt) yang dikirim ke AI. Jika mereka ingin AI 
//    menjawab dengan gaya bahasa santai atau lebih ketat, mereka cukup mengganti
//    teks prompt di sini tanpa perlu mengubah source code aplikasi.
// 3. **Statistik Penggunaan**: Aplikasi memantau dan mencatat secara lokal berapa 
//    kali pengguna telah menanyakan hoax ke AI. Ini membantu memonitor pemakaian kuota.
// 4. **Logout System**: Membersihkan seluruh data sesi agar aman saat berganti akun.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk menyalin teks/API key ke clipboard HP
import 'package:provider/provider.dart'; // State management Provider untuk memantau state dinamis
import 'package:url_launcher/url_launcher.dart'; // Membuka link tutorial di browser eksternal
import '../providers/auth_provider.dart'; // Provider sesi login pengguna
import '../providers/gemini_api_provider.dart'; // Provider API key Gemini AI
import '../providers/search_api_provider.dart'; // Provider API key Google Custom Search
import '../providers/custom_prompt_provider.dart'; // Provider kustomisasi instruksi AI
import '../pages/auth/login_page.dart'; // Halaman login saat pengguna keluar (logout)
import '../pages/profile/edit_profile_page.dart'; // Halaman edit nama lengkap
import '../pages/profile/change_password_page.dart'; // Halaman ganti kata sandi akun
import '../theme/app_theme.dart'; // Konstanta warna dan gradient gelap aplikasi
import '../utils/tutorial_utils.dart'; // Helper pop-up tutorial cara membuat API key

/// Halaman pengaturan aplikasi Klarip.
/// Ditampilkan sebagai Tab 3 (terakhir) pada HomeShell navigasi utama.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onBackTap});

  /// Aksi callback jika pengguna menekan tombol kembali (opsional).
  /// Digunakan oleh HomeShell untuk memindahkan tab ke Tab Cari (index 0).
  final VoidCallback? onBackTap;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  // ==========================================================================
  // HELPER WIDGET: MEMBANGUN ITEM MENU (LIST TILE)
  // ==========================================================================
  /// Membuat baris menu standar dengan latar belakang gradient kartu yang elegan,
  /// ikon di sebelah kiri, judul di tengah, deskripsi di bawah judul, dan panah di kanan.
  Widget _buildMenuTile({
    required IconData icon, // Ikon penanda menu
    required String title, // Judul menu utama
    required String subtitle, // Penjelasan singkat di bawah judul
    required VoidCallback onTap, // Aksi ketika menu ditekan
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primarySeedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primarySeedColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white30,
          size: 16,
        ),
      ),
    );
  }

  // ==========================================================================
  // TAMPILAN UTAMA (BUILD METHOD)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // watch() mendengarkan data user yang sedang login saat ini di AuthProvider
    final user = context.watch<AuthProvider>().currentUser;
    final currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Agar background gradient terlihat
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default dari Flutter
        // Tampilkan tombol kembali custom jika callback onBackTap disediakan
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBackTap,
              )
            : null,
        actions: [
          // === TOMBOL KELUAR (LOGOUT) ===
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              // 1. Tampilkan dialog konfirmasi keluar aplikasi
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text(
                    'Keluar?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar dari aplikasi?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              // 2. Jika dikonfirmasi keluar, bersihkan sesi login
              if (confirm == true) {
                if (!context.mounted) return;
                // Bersihkan sesi aktif dari memory dan SharedPreferences
                await context.read<AuthProvider>().logout();

                if (!context.mounted) return;
                // Navigasi ke halaman Login dan bersihkan seluruh tumpukan halaman sebelumnya
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // === KARTU PROFIL PENGGUNA ===
            if (user != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar inisial huruf pertama username
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primarySeedColor,
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Informasi detail pengguna
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName ?? user.username,
                            style: currentTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: currentTheme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol edit profil (untuk mengganti nama lengkap)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: user),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // === BAGIAN UTAMA: PENGATURAN AKUN ===
              Text(
                'Akun',
                style: currentTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.lock_outline,
                title: 'Ganti Password',
                subtitle: 'Ubah kata sandi akun Anda',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordPage(userId: user.id!),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // === BAGIAN UTAMA: GEMINI API SECTION ===
            _buildGeminiApiSection(currentTheme),

            const SizedBox(height: 16),

            // === BAGIAN UTAMA: CUSTOM PROMPT SECTION ===
            _buildCustomPromptSection(currentTheme),

            const SizedBox(height: 16),

            // === BAGIAN UTAMA: SEARCH API SECTION ===
            _buildSearchApiSection(currentTheme),

            const SizedBox(height: 16),

            // Kartu Informasi Versi Aplikasi
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadows,
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Icon(Icons.info_outline, color: Colors.white70),
                title: Text(
                  'Versi Aplikasi',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'v2.4.0',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kartu Daftar Sumber Berita Terpercaya
            const _TrustedSourcesCard(),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGET: GEMINI API SECTION
  // ==========================================================================
  /// Membangun antarmuka manajemen API key Google Gemini.
  /// Memantau kegagalan key dan statistik penggunaan API key tersebut.
  Widget _buildGeminiApiSection(ThemeData currentTheme) {
    return Consumer<GeminiApiProvider>(
      builder: (context, geminiProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gemini AI API',
              style: currentTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // === SPANDUK ERROR (API KEY EXPIRED / LIMIT KUOTA) ===
            // Jika provider mendeteksi status isKeyExpired = true (misal: setelah request gagal),
            // tampilkan banner merah peringatan beserta keterangan error persis dari API.
            if (geminiProvider.isKeyExpired) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API Key Bermasalah!',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            geminiProvider.lastError ??
                                'API key tidak valid atau quota habis.',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // === KARTU GANTI API KEY ===
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: geminiProvider.isKeyExpired
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: ListTile(
                onTap: () => _showChangeApiKeyDialog(context, geminiProvider),
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: geminiProvider.isKeyExpired
                        ? Colors.redAccent.withValues(alpha: 0.1)
                        : AppTheme.primarySeedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.vpn_key,
                    color: geminiProvider.isKeyExpired
                        ? Colors.redAccent
                        : AppTheme.primarySeedColor,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Ganti API Key',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tampilkan mask key (disensor sebagian)
                      Text(
                        geminiProvider.maskedApiKey,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      // Tampilkan label penanda jenis API key yang sedang aktif
                      if (geminiProvider.isUsingCustomKey)
                        const Text(
                          'Menggunakan API key custom',
                          style: TextStyle(
                            color: AppTheme.primarySeedColor,
                            fontSize: 11,
                          ),
                        )
                      else
                        const Text(
                          'Menggunakan API key default',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white30,
                  size: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // === KARTU STATISTIK PENGGUNAAN GEMINI ===
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySeedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.bar_chart,
                          color: AppTheme.primarySeedColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Statistik Penggunaan API',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Tombol setel ulang statistik ke 0
                      IconButton(
                        onPressed: () => _showResetStatsDialog(context, geminiProvider),
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white30,
                          size: 20,
                        ),
                        tooltip: 'Reset statistik',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informasi grid pemakaian Total vs Harian
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.analytics,
                          label: 'Total',
                          value: '${geminiProvider.totalUsageCount}',
                          color: AppTheme.primarySeedColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.today,
                          label: 'Hari Ini',
                          value: '${geminiProvider.dailyUsageCount}',
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Keterangan waktu pemakaian terakhir
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Terakhir digunakan: ${geminiProvider.lastUsedDisplay}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // WIDGET: CUSTOM PROMPT SECTION
  // ==========================================================================
  /// Membangun antarmuka pengelolaan Custom Prompt AI.
  /// Menampilkan status kustomisasi dan navigasi ke editor instruksi prompt.
  Widget _buildCustomPromptSection(ThemeData currentTheme) {
    return Consumer<CustomPromptProvider>(
      builder: (context, promptProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Prompt AI',
              style: currentTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: promptProvider.isUsingCustom
                      ? Colors.purpleAccent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: ListTile(
                onTap: () => _showCustomPromptEditor(context, promptProvider),
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.purpleAccent,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Instruksi Analisis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kustomisasi perintah analisis Gemini AI',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (promptProvider.isUsingCustom)
                        const Text(
                          '✨ Menggunakan instruksi custom',
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(
                          'Menggunakan instruksi default',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white30,
                  size: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // METODE: DIALOG EDIT PROMPT INSTRUKSI ANALISIS AI
  // ==========================================================================
  /// Menampilkan pop-up dialog berisi formulir sunting instruksi prompt AI.
  /// Pengguna bisa mengubah alur kriteria analisis data klaim di sini.
  void _showCustomPromptEditor(
    BuildContext context,
    CustomPromptProvider provider,
  ) {
    // Controller untuk formulir agar nilainya sinkron saat diketik
    final mainController = TextEditingController(text: provider.mainInstructions);
    final didukungController = TextEditingController(text: provider.verdictDidukung);
    final tidakDidukungController = TextEditingController(text: provider.verdictTidakDidukung);
    final verifikasiController = TextEditingController(text: provider.verdictVerifikasi);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.purpleAccent.withValues(alpha: 0.2)),
        ),
        insetPadding: const EdgeInsets.all(16),
        title: const Row(
          children: [
            Icon(Icons.tune, color: Colors.purpleAccent, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Edit Instruksi Analisis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box peringatan titik akhir
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purpleAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.purpleAccent.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Saat kustomisasi prompt Harus ada . di akhir perubahan dan penambahan kalimat',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === FORM 1: INSTRUKSI UTAMA ===
                const Text(
                  'Prompt AI :',
                  style: TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mainController,
                  maxLines: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  decoration: _promptInputDecoration(
                    hint: 'Instruksi analisis utama...',
                  ),
                ),
                const SizedBox(height: 24),

                // === FORM 2: PENJELASAN VERDICT (NAMA KUNCI TERKUNCI) ===
                Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'Verdict:',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Nama verdict terkunci',
                        style: TextStyle(color: Colors.white30, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // DIDUKUNG_DATA Field
                _buildVerdictField(
                  label: 'DIDUKUNG_DATA',
                  color: const Color(0xFF10B981),
                  controller: didukungController,
                  hint: 'Deskripsi kapan verdict ini digunakan...',
                ),
                const SizedBox(height: 12),

                // TIDAK_DIDUKUNG_DATA Field
                _buildVerdictField(
                  label: 'TIDAK_DIDUKUNG_DATA',
                  color: const Color(0xFFEF4444),
                  controller: tidakDidukungController,
                  hint: 'Deskripsi kapan verdict ini digunakan...',
                ),
                const SizedBox(height: 12),

                // MEMERLUKAN_VERIFIKASI Field
                _buildVerdictField(
                  label: 'MEMERLUKAN_VERIFIKASI',
                  color: const Color(0xFFF59E0B),
                  controller: verifikasiController,
                  hint: 'Deskripsi kapan verdict ini digunakan...',
                ),
                const SizedBox(height: 16),

                // Petunjuk singkat
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Tips:',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Instruksi utama menentukan cara AI memeriksa sumber\n'
                        '• Deskripsi verdict menentukan kapan masing-masing verdict dipilih\n'
                        '• Nama verdict tidak bisa diubah agar format output tetap konsisten',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Tombol Reset ke Default
          if (provider.isUsingCustom)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await provider.resetToDefault();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Instruksi dikembalikan ke default')),
                );
              },
              child: const Text(
                'Reset Default',
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              // Validasi agar formulir tidak kosong saat disubmit
              if (mainController.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Instruksi utama tidak boleh kosong')),
                );
                return;
              }
              if (didukungController.text.trim().isEmpty ||
                  tidakDidukungController.text.trim().isEmpty ||
                  verifikasiController.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Deskripsi verdict tidak boleh kosong')),
                );
                return;
              }

              // Simpan perubahan ke penyimpanan SharedPreferences
              await provider.updateInstructions(
                mainInstructions: mainController.text,
                verdictDidukung: didukungController.text,
                verdictTidakDidukung: tidakDidukungController.text,
                verdictVerifikasi: verifikasiController.text,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(content: Text('Instruksi analisis berhasil diperbarui! ✨')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPER WIDGET: CARD FORMULIR VERDICT PROMPT
  // ==========================================================================
  /// Membuat baris input kustom ter-styling khusus untuk deskripsi verdict prompt
  Widget _buildVerdictField({
    required String label,
    required Color color,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock, color: color.withValues(alpha: 0.6), size: 14),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
            decoration: _promptInputDecoration(hint: hint),
          ),
        ],
      ),
    );
  }

  /// Desain input border textfield kustom khusus tema gelap aplikasi
  InputDecoration _promptInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(12),
      isDense: true,
    );
  }

  // ==========================================================================
  // HELPER WIDGET: CARD ITEM STATISTIK (_buildStatItem)
  // ==========================================================================
  /// Membangun visual layout grid stat item berbentuk box kecil.
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'kali digunakan',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // METODE: DIALOG GANTI API KEY GEMINI AI
  // ==========================================================================
  /// Memunculkan popup untuk mengedit teks API key dinamis dari Google AI Studio.
  void _showChangeApiKeyDialog(
    BuildContext context,
    GeminiApiProvider provider,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ganti API Key Gemini',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan API key baru dari Google AI Studio:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Menampilkan API key yang sedang aktif disensor
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, color: Colors.white38, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saat ini: ${provider.maskedApiKey}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kolom input text API key
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key, color: Colors.white38),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste, color: Colors.white38),
                    onPressed: () async {
                      // Ambil teks yang sedang disalin di clipboard HP pengguna
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        controller.text = data!.text!;
                      }
                    },
                    tooltip: 'Paste dari clipboard',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Kotak panduan membuat API key gratis beserta tautannya
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
                            onPressed: () => _showApiKeyTutorialBottomSheet(context),
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
        ),
        actions: [
          // Tombol Reset ke Default API key bawaan aplikasi
          if (provider.isUsingCustomKey)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await provider.resetToDefaultKey();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('API key dikembalikan ke default'),
                  ),
                );
              },
              child: const Text(
                'Reset Default',
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primarySeedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final newKey = controller.text.trim();
              if (newKey.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('API key tidak boleh kosong')),
                );
                return;
              }

              // Simpan key baru ke SQLite / SharedPreferences
              await provider.updateApiKey(newKey);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('API key berhasil diperbarui! 🎉'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // === METODE: MENAMPILKAN TUTORIAL BOTTOM SHEET ===
  void _showApiKeyTutorialBottomSheet(BuildContext context) {
    showApiKeyTutorialBottomSheet(context);
  }

  // ==========================================================================
  // METODE: DIALOG PENYETELAN ULANG (RESET) STATISTIK PENGGUNAAN GEMINI
  // ==========================================================================
  void _showResetStatsDialog(BuildContext context, GeminiApiProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Reset Statistik?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Semua statistik penggunaan API akan di-reset ke nol. Tindakan ini tidak bisa dibatalkan.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await provider.resetUsageStats();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(content: Text('Statistik berhasil di-reset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // WIDGET: SEARCH API SECTION
  // ==========================================================================
  /// Membangun antarmuka monitoring Google Custom Search.
  /// API key dan CX dikunci secara default karena telah dikonfigurasi khusus.
  Widget _buildSearchApiSection(ThemeData currentTheme) {
    return Consumer<SearchApiProvider>(
      builder: (context, cseProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Google Search API',
              style: currentTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // === SEARCH KEY CARD (STATUS LOCKED / READ-ONLY) ===
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF64B5F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search API Key',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Key: ${cseProvider.maskedApiKey}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'CX: ${cseProvider.maskedCx}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Color(0xFF81C784),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Menggunakan API key default (terkunci)',
                              style: TextStyle(
                                color: Color(0xFF81C784),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // === KARTU MONITORING STATISTIK PENGGUNAAN CSE ===
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bar_chart,
                          color: Color(0xFF64B5F6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Statistik Penggunaan Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showResetCseStatsDialog(context, cseProvider),
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white30,
                          size: 20,
                        ),
                        tooltip: 'Reset statistik',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.analytics,
                          label: 'Total',
                          value: '${cseProvider.totalUsageCount}',
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.today,
                          label: 'Hari Ini',
                          value: '${cseProvider.dailyUsageCount}',
                          color: const Color(0xFF81C784),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Terakhir digunakan: ${cseProvider.lastUsedDisplay}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // === METODE: DIALOG RESET STATISTIK PENGGUNAAN GOOGLE CSE ===
  void _showResetCseStatsDialog(
    BuildContext context,
    SearchApiProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Reset Statistik Search?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Semua statistik penggunaan Search API akan di-reset ke nol.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await provider.resetUsageStats();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Statistik Search berhasil di-reset'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// SUB-WIDGET: KARTU SUMBER BERITA TERPERCAYA INDONESIA (_TrustedSourcesCard)
// ==============================================================================
/// Menampilkan daftar whitelist media nasional, bisnis, fact-checker, dan instansi resmi.
class _TrustedSourcesCard extends StatefulWidget {
  const _TrustedSourcesCard();

  @override
  State<_TrustedSourcesCard> createState() => _TrustedSourcesCardState();
}

class _TrustedSourcesCardState extends State<_TrustedSourcesCard> {
  bool _isExpanded = false; // State: Apakah daftar kategori sedang terbuka?

  // Whitelist domain sumber terpercaya di Indonesia
  final Map<String, List<String>> _trustedSources = {
    '📰 Media Nasional': [
      'kompas.com',
      'tempo.co',
      'detik.com',
      'tirto.id',
      'cnnindonesia.com',
      'liputan6.com',
      'tribunnews.com',
      'republika.co.id',
      'mediaindonesia.com',
      'jawapos.com',
      'antaranews.com',
      'beritasatu.com',
      'kumparan.com',
      'suara.com',
      'merdeka.com',
      'okezone.com',
      'sindonews.com',
      'inews.id',
      'idntimes.com',
      'viva.co.id',
    ],
    '💰 Media Bisnis & Ekonomi': [
      'bisnis.com',
      'kontan.co.id',
      'katadata.co.id',
      'cnbcindonesia.com',
      'investor.id',
      'infobanknews.com',
      'bloombergtechnoz.com',
      'fortuneidn.com',
    ],
    '🏛️ Lembaga Pemerintah': [
      'presidenri.go.id',
      'setkab.go.id',
      'setneg.go.id',
      'dpr.go.id',
      'mpr.go.id',
      'mahkamahagung.go.id',
      'mkri.id',
      'kpk.go.id',
      'kominfo.go.id',
      'kemenkeu.go.id',
      'kemkes.go.id',
      'kemdikbud.go.id',
      'kemlu.go.id',
      'polri.go.id',
      'bps.go.id',
      'bi.go.id',
      'bmkg.go.id',
      'kpu.go.id',
      'bnpb.go.id',
      'bpom.go.id',
    ],
    '✅ Fact-Checker': ['cekfakta.com', 'turnbackhoax.id'],
    '🌍 Media Internasional': [
      'bbc.com',
      'reuters.com',
      'apnews.com',
      'aljazeera.com',
      'theguardian.com',
      'bloomberg.com',
      'cnn.com',
      'nytimes.com',
      'washingtonpost.com',
      'dw.com',
      'channelnewsasia.com',
      'cnbc.com',
      'time.com',
      'economist.com',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadows,
      ),
      child: Column(
        children: [
          // Header Kartu
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySeedColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.verified,
                      color: AppTheme.primarySeedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sumber Terpercaya',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Portal berita & lembaga resmi yang diprioritaskan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          // Konten list kategori yang bisa di-expand (membuka/menutup daftar)
          if (_isExpanded) ...[
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                          Icons.info_outline,
                          color: AppTheme.primarySeedColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Klarip memprioritaskan hasil pencarian dari portal berita terpercaya dan website resmi lembaga pemerintah untuk memastikan akurasi verifikasi fakta.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kategori berita & website instansi
                  ..._trustedSources.entries.map(
                    (entry) => _buildCategory(title: entry.key, sources: entry.value),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Membangun baris kategori beserta chip/tag domain websitenya
  Widget _buildCategory({
    required String title,
    required List<String> sources,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sources
                .map(
                  (source) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      source,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
