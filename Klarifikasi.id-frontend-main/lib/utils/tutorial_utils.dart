import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:klarifikasi_id/theme/app_theme.dart';

void showApiKeyTutorialBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      return Container(
        height: MediaQuery.of(bottomSheetContext).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.vpn_key, color: AppTheme.primarySeedColor, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tutorial Mendapatkan API Key',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Ikuti 5 langkah mudah berikut untuk mendapatkan kunci API Anda secara gratis:',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTutorialStep('1', 'Buka situs web Google AI Studio menggunakan tombol utama di bawah.'),
                    _buildTutorialStep('2', 'Pastikan Anda telah Login menggunakan Akun Google (Gmail) Anda.'),
                    _buildTutorialStep('3', 'Ketuk tombol putih "Create API key" di bagian atas halaman.', imagePath: 'assets/images/tutorial_step_1.png'),
                    _buildTutorialStep('4', 'Pada pop-up yang muncul, pilih project (atau biarkan default), lalu ketuk "Create key".', imagePath: 'assets/images/tutorial_step_2.png'),
                    _buildTutorialStep('5', 'Setelah selesai, salin (Copy) deretan teks panjang yang muncul pada "API key details".', imagePath: 'assets/images/tutorial_step_3.png'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kembali ke aplikasi ini dan Tempel (Paste) teks yang disalin tadi ke kolom API Key.',
                              style: TextStyle(color: Colors.orangeAccent, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                  launchUrl(
                    Uri.parse('https://aistudio.google.com/api-keys'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.launch, size: 20),
                label: const Text('Buka laman AI Studio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primarySeedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTutorialStep(String number, String text, {String? imagePath}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primarySeedColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.primarySeedColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
              if (imagePath != null) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
