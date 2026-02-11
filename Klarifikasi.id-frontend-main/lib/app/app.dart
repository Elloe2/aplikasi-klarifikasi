/// ============================================================================
/// MAIN APPLICATION WIDGET - KLARIFIKASI.ID
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/saved_analysis_provider.dart';
import '../providers/auth_provider.dart';
import '../app/home_shell.dart';
import '../pages/auth/login_page.dart';

/// === MAIN APP WIDGET ===
/// Root widget aplikasi yang mengatur semua konfigurasi global.
class MainApp extends StatelessWidget {
  /// Constructor dengan key untuk widget identification
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan MultiProvider untuk inject state management ke seluruh app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavedAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            // Judul aplikasi yang muncul di window/browser tab
            title: 'Klarifikasi.id',
            // Sembunyikan banner debug untuk tampilan yang bersih
            debugShowCheckedModeBanner: false,
            // Terapkan tema gelap custom dari `AppTheme`
            theme: AppTheme.light,

            // ===== ROUTE CONFIGURATION =====
            // Halaman utama didaftarkan di sini untuk navigasi.
            home: auth.isLoading
                ? const Scaffold(
                    backgroundColor: Color(0xFF1E1E1E),
                    body: Center(child: CircularProgressIndicator()),
                  )
                : (auth.isLoggedIn ? const HomeShell() : const LoginPage()),

            routes: {
              '/home': (context) => const HomeShell(), // Shell utama
              '/login': (context) => const LoginPage(),
            },

            // ===== ERROR & MEDIA CONFIG =====
            // Override `builder` untuk memastikan text scale tetap 1.0 (stabil di web)
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
