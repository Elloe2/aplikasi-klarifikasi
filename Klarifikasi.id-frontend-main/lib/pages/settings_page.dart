import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/gemini_api_provider.dart';
import '../providers/search_api_provider.dart';
import '../pages/auth/login_page.dart';
import '../pages/profile/edit_profile_page.dart';
import '../pages/profile/change_password_page.dart';
import '../theme/app_theme.dart'; // Konsistensi warna dan gradient UI

/// Halaman pengaturan sederhana tanpa fitur pengguna.
/// Hanya menampilkan informasi aplikasi dan sumber terpercaya.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBackTap,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              // Confirm logout
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

              if (confirm == true) {
                if (!context.mounted) return;
                await context.read<AuthProvider>().logout();

                if (!context.mounted) return;
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
            // User Profile Card
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
                          // Education and Age Badge
                          if (user.education != null || user.age != null) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (user.education != null)
                                  _buildInfoBadge(user.education!),
                                if (user.age != null)
                                  _buildInfoBadge('${user.age} Tahun'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Edit Icon
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfilePage(user: user), // Pass user
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Settings Section
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
                      builder: (_) =>
                          ChangePasswordPage(userId: user.id!), // Pass ID
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // === GEMINI API SECTION ===
            _buildGeminiApiSection(currentTheme),

            const SizedBox(height: 16),

            // === SEARCH API SECTION ===
            _buildSearchApiSection(currentTheme),

            const SizedBox(height: 16),

            // App Info Card berisi metadata aplikasi
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
                  'v2.3.0',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Trusted Sources Info Card
            const _TrustedSourcesCard(),
          ],
        ),
      ),
    );
  }

  // === GEMINI API SECTION BUILDER ===
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

            // === ERROR BANNER ===
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

            // === API KEY CARD ===
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
                      Text(
                        geminiProvider.maskedApiKey,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
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

            // === USAGE STATISTICS CARD ===
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
                          color: AppTheme.primarySeedColor.withValues(
                            alpha: 0.1,
                          ),
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
                      // Reset button
                      IconButton(
                        onPressed: () =>
                            _showResetStatsDialog(context, geminiProvider),
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

                  // Stats Grid
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

                  // Last Used
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

  // === STAT ITEM WIDGET ===
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

  // === DIALOG GANTI API KEY ===
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

              // Current key info
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

              // Input field
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

              // Info box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primarySeedColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primarySeedColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primarySeedColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Dapatkan API key gratis di aistudio.google.com',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Reset to default button
          if (provider.isUsingCustomKey)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await provider.resetToDefaultKey();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('API key dikembalikan ke default'),
                    ),
                  );
                }
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
              if (!newKey.startsWith('AIza')) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Format API key tidak valid (harus dimulai dengan AIza)',
                    ),
                  ),
                );
                return;
              }
              await provider.updateApiKey(newKey);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('API key berhasil diperbarui! 🎉'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // === DIALOG RESET STATISTIK ===
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
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Statistik berhasil di-reset')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // === SEARCH API SECTION BUILDER ===
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

            // === ERROR BANNER ===
            if (cseProvider.isKeyExpired) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orangeAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orangeAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Search API Key Bermasalah!',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cseProvider.lastError ??
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

            // === API KEY CARD ===
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cseProvider.isKeyExpired
                      ? Colors.orangeAccent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: ListTile(
                onTap: () => _showChangeCseApiKeyDialog(context, cseProvider),
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cseProvider.isKeyExpired
                        ? Colors.orangeAccent.withValues(alpha: 0.1)
                        : const Color(0xFF64B5F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search,
                    color: cseProvider.isKeyExpired
                        ? Colors.orangeAccent
                        : const Color(0xFF64B5F6),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Ganti API Key & CX',
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
                      if (cseProvider.isUsingCustomKey)
                        const Text(
                          'Menggunakan API key custom',
                          style: TextStyle(
                            color: Color(0xFF64B5F6),
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

            // === USAGE STATISTICS CARD ===
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
                        onPressed: () =>
                            _showResetCseStatsDialog(context, cseProvider),
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

  // === DIALOG GANTI CSE API KEY & CX ===
  void _showChangeCseApiKeyDialog(
    BuildContext context,
    SearchApiProvider provider,
  ) {
    final keyController = TextEditingController();
    final cxController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ganti Search API Key',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan API key dan Search Engine ID (CX):',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Current key info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.key, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Key: ${provider.maskedApiKey}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.tag, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'CX: ${provider.maskedCx}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // API Key input
              const Text(
                'API Key:',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: keyController,
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
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        keyController.text = data!.text!;
                      }
                    },
                    tooltip: 'Paste',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // CX input
              const Text(
                'Search Engine ID (CX):',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: cxController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: 6242f5825dedb4b59',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.tag, color: Colors.white38),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste, color: Colors.white38),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        cxController.text = data!.text!;
                      }
                    },
                    tooltip: 'Paste',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF64B5F6).withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF64B5F6),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dapatkan API key di console.cloud.google.com\nCX di programmablesearchengine.google.com',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (provider.isUsingCustomKey || provider.isUsingCustomCx)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await provider.resetToDefault();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Search API dikembalikan ke default'),
                    ),
                  );
                }
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
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final newKey = keyController.text.trim();
              final newCx = cxController.text.trim();

              // Minimal satu field harus diisi
              if (newKey.isEmpty && newCx.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Isi minimal satu field')),
                );
                return;
              }

              // Validasi API key format
              if (newKey.isNotEmpty && !newKey.startsWith('AIza')) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Format API key tidak valid (harus dimulai dengan AIza)',
                    ),
                  ),
                );
                return;
              }

              // Update yang diisi saja
              if (newKey.isNotEmpty) await provider.updateApiKey(newKey);
              if (newCx.isNotEmpty) await provider.updateCx(newCx);

              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Search API berhasil diperbarui! 🎉'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // === DIALOG RESET STATISTIK CSE ===
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
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Statistik Search berhasil di-reset'),
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Card yang menampilkan informasi sumber-sumber terpercaya
class _TrustedSourcesCard extends StatefulWidget {
  const _TrustedSourcesCard();

  @override
  State<_TrustedSourcesCard> createState() => _TrustedSourcesCardState();
}

class _TrustedSourcesCardState extends State<_TrustedSourcesCard> {
  bool _isExpanded = false;

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
          // Header
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

          // Expandable Content
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
                            'Klarifikasi.id memprioritaskan hasil pencarian dari portal berita terpercaya dan website resmi lembaga pemerintah untuk memastikan akurasi verifikasi fakta.',
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

                  // Categories
                  ..._trustedSources.entries.map(
                    (entry) =>
                        _buildCategory(title: entry.key, sources: entry.value),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

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
