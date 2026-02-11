import 'package:flutter/material.dart';

import '../pages/search_page.dart'; // Tab utama untuk pencarian klaim
import '../pages/saved_page.dart'; // Tab koleksi (CRUD)
import '../pages/settings_page.dart'; // Tab pengaturan profil dan preferensi
import '../services/search_api.dart'; // Service pencarian yang dioper ke SearchPage
import '../theme/app_theme.dart';

/// Shell navigasi utama aplikasi.
/// Mengatur tab navigasi antara pencarian, koleksi, dan pengaturan.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Index tab yang sedang aktif
  int _currentIndex = 0;

  // Instance `SearchApi` yang diteruskan ke `SearchPage`
  final SearchApi _api = const SearchApi();

  @override
  Widget build(BuildContext context) {
    // Daftar halaman yang di-stack
    final pages = [
      SearchPage(
        api: _api,
        onSettingsTap: () {
          if (mounted) {
            setState(() {
              _currentIndex = 2; // Navigate to settings (index 2)
            });
          }
        },
      ),
      const SavedPage(),
      SettingsPage(
        onBackTap: () {
          if (mounted) {
            setState(() {
              _currentIndex = 0; // Back to search
            });
          }
        },
      ),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        extendBody: false, // Prevent content overlap with bottom nav bar
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient, // Match background
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            indicatorColor: AppTheme.primarySeedColor.withValues(alpha: 0.2),
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.search_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.search, color: Colors.white),
                label: 'Cari',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border, color: Colors.white70),
                selectedIcon: Icon(Icons.bookmark, color: Colors.white),
                label: 'Koleksi',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.settings, color: Colors.white),
                label: 'Profil',
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
