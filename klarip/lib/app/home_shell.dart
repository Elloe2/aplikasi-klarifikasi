// ==============================================================================
// HOME SHELL - KLARIP
// ==============================================================================
// File ini adalah KERANGKA NAVIGASI UTAMA aplikasi setelah pengguna login.
// Menampilkan bottom navigation bar dengan 3 tab utama:
//
// Tab 1 (Cari)    -> SearchPage  : Halaman verifikasi klaim dengan AI
// Tab 2 (Koleksi) -> SavedPage   : Halaman riwayat dan manajemen analisis tersimpan
// Tab 3 (Profil)  -> SettingsPage: Halaman profil pengguna dan pengaturan API
//
// POLA DESAIN IndexedStack:
// Ketiga halaman di-render SEKALIGUS namun hanya satu yang terlihat.
// Keuntungan: saat berpindah tab, halaman tidak di-rebuild dari nol
// (scroll position dan state tetap terjaga).
// ==============================================================================

import 'package:flutter/material.dart';

import '../pages/search_page.dart'; // Halaman utama verifikasi klaim
import '../pages/saved_page.dart'; // Halaman koleksi/riwayat analisis
import '../pages/settings_page.dart'; // Halaman pengaturan dan profil
import '../services/search_api.dart'; // Service pencarian (diteruskan ke SearchPage)
import '../theme/app_theme.dart'; // Warna dan gaya tema aplikasi

/// Widget shell navigasi utama yang menjadi "bingkai" untuk semua halaman utama.
/// Bersifat StatefulWidget karena perlu menyimpan state: tab mana yang aktif.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Menyimpan index tab yang sedang aktif (0=Cari, 1=Koleksi, 2=Profil)
  int _currentIndex = 0;

  // Instance SearchApi yang diteruskan ke SearchPage.
  // Dibuat di sini (bukan di SearchPage) agar tidak dibuat ulang setiap rebuild.
  final SearchApi _api = const SearchApi();

  @override
  Widget build(BuildContext context) {
    // Daftar halaman yang tersedia. Disusun sesuai urutan tab.
    // IndexedStack membutuhkan daftar ini untuk mengetahui widget mana yang ditampilkan.
    final pages = [
      // Tab 0: Halaman Cari (SearchPage)
      // onSettingsTap: fungsi callback jika pengguna menekan tombol pengaturan dari SearchPage
      SearchPage(
        api: _api,
        onSettingsTap: () {
          if (mounted) {
            setState(() {
              _currentIndex = 2; // Pindah ke tab Profil (index 2)
            });
          }
        },
      ),

      // Tab 1: Halaman Koleksi (SavedPage)
      const SavedPage(),

      // Tab 2: Halaman Profil/Pengaturan (SettingsPage)
      // onBackTap: fungsi callback jika pengguna menekan tombol kembali dari SettingsPage
      SettingsPage(
        onBackTap: () {
          if (mounted) {
            setState(() {
              _currentIndex = 0; // Kembali ke tab Cari (index 0)
            });
          }
        },
      ),
    ];

    return PopScope(
      // canPop: true hanya jika pengguna ada di tab pertama (Cari)
      // Mencegah pengguna keluar aplikasi dari tab lain dengan tombol Back
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // Jika sudah berhasil pop, tidak perlu tindakan lain
        // Jika bukan di tab pertama, kembali ke tab Cari alih-alih keluar aplikasi
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        extendBody: false, // Konten tidak melebar ke area bottom nav bar
        // IndexedStack: menampilkan hanya satu halaman sesuai _currentIndex,
        // tapi semua halaman tetap hidup di memori (tidak di-destroy saat ganti tab)
        body: IndexedStack(index: _currentIndex, children: pages),

        // === BOTTOM NAVIGATION BAR ===
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient, // Background sesuai tema gelap
            border: Border(
              // Garis tipis di atas nav bar sebagai pemisah visual
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent, // Transparan agar gradient terlihat
            // Warna indikator saat tab dipilih (hijau semi-transparan)
            indicatorColor: AppTheme.primarySeedColor.withValues(alpha: 0.2),
            selectedIndex: _currentIndex, // Tab yang sedang aktif
            // Callback saat pengguna mengetuk salah satu tab
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index; // Update tab yang aktif
              });
            },
            destinations: const [
              // Tab 1: Cari (ikon search)
              NavigationDestination(
                icon: Icon(Icons.search_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.search, color: Colors.white),
                label: 'Cari',
              ),
              // Tab 2: Koleksi (ikon bookmark)
              NavigationDestination(
                icon: Icon(Icons.bookmark_border, color: Colors.white70),
                selectedIcon: Icon(Icons.bookmark, color: Colors.white),
                label: 'Koleksi',
              ),
              // Tab 3: Profil (ikon settings/gear)
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.settings, color: Colors.white),
                label: 'Profil',
              ),
            ],
            // Label selalu ditampilkan (tidak hanya saat dipilih)
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
