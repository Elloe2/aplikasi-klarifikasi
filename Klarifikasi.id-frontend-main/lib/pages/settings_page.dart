import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
