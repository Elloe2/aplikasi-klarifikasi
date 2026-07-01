// ==============================================================================
// PENJELASAN UNTUK SIDANG: APP.DART (ROOT WIDGET)
// ==============================================================================
// Bapak/Ibu Penguji, file ini adalah "Tulang Punggung" dari arsitektur aplikasi.
// Di sinilah 3 pilar utama aplikasi disatukan sebelum layar apa pun dimunculkan:
//
// 1. STATE MANAGEMENT (MULTI PROVIDER):
//    Kami memakai 'Provider' untuk menyuntikkan data ke seluruh aplikasi.
//    (Auth, Gemini API, Search API, Custom Prompt, Saved Analysis).
//    Mengapa Provider? Agar data tidak perlu dioper-oper (prop-drilling) secara
//    manual dari halaman ke halaman, yang membuat koding berantakan.
//
// 2. LOGIKA ROUTING OTOMATIS:
//    Di bagian `home:`, ada logika pengecekan sesi. 
//    Jika belum login -> paksa ke LoginPage.
//    Jika sudah login -> otomatis masuk ke HomeShell (Halaman Utama).
//
// 3. TEMA GLOBAL & RESPONSIVITAS:
//    Di sini juga kami menetapkan tema (AppTheme.light) dan mengunci ukuran teks
//    (textScaler: 1.0) agar desain UI tidak rusak walau font HP dibesarkan.
// ==============================================================================
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Package state management Provider
import '../theme/app_theme.dart'; // Konfigurasi tema (warna, font, dll)
import '../providers/saved_analysis_provider.dart'; // Provider riwayat analisis
import '../providers/auth_provider.dart'; // Provider autentikasi pengguna
import '../providers/gemini_api_provider.dart'; // Provider API key Gemini
import '../providers/search_api_provider.dart'; // Provider API key Google CSE
import '../providers/custom_prompt_provider.dart'; // Provider instruksi kustom AI
import '../app/home_shell.dart'; // Shell navigasi utama (3 tab)
import '../pages/auth/login_page.dart'; // Halaman login

/// Root widget aplikasi yang mengatur konfigurasi global.
/// Dipanggil satu kali dari main.dart sebagai widget tertinggi (root) dalam tree.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // === MULTI PROVIDER ===
    // MultiProvider adalah widget yang mendaftarkan banyak Provider sekaligus.
    // Semua Provider di sini dapat diakses oleh widget MANA SAJA di bawahnya.
    //
    // Analogi: Seperti mendaftarkan "layanan" (listrik, air, internet) di gedung --
    // semua penghuni di bawah bisa menggunakannya.
    return MultiProvider(
      providers: [
        // Provider untuk mengelola daftar riwayat analisis yang disimpan
        ChangeNotifierProvider(create: (_) => SavedAnalysisProvider()),

        // Provider untuk mengelola status login/logout pengguna
        // AuthProvider langsung mengecek sesi saat dibuat (di constructor-nya)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provider untuk mengelola API key Gemini AI
        ChangeNotifierProvider(create: (_) => GeminiApiProvider()),

        // Provider untuk mengelola API key dan CX Google Custom Search Engine
        ChangeNotifierProvider(create: (_) => SearchApiProvider()),

        // Provider untuk mengelola instruksi analisis kustom dari pengguna
        ChangeNotifierProvider(create: (_) => CustomPromptProvider()),
      ],

      // Consumer<AuthProvider> mendengarkan perubahan status login.
      // Setiap kali status login berubah (login/logout), widget ini dibangun ulang.
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Klarip', // Nama aplikasi (muncul di task switcher HP)
            debugShowCheckedModeBanner: false, // Sembunyikan banner "DEBUG" merah
            theme: AppTheme.light, // Terapkan tema kustom dari AppTheme

            // === LOGIKA ROUTING BERDASARKAN STATUS LOGIN ===
            home: auth.isLoading
                ? const Scaffold(
                    // Tampilkan layar loading (loading spinner) saat AuthProvider
                    // sedang mengecek sesi login (proses async pertama kali)
                    backgroundColor: Color(0xFF1E1E1E),
                    body: Center(child: CircularProgressIndicator()),
                  )
                : (auth.isLoggedIn
                    ? const HomeShell() // Sudah login -> masuk ke halaman utama
                    : const LoginPage()), // Belum login -> tampilkan halaman login

            // Daftar named routes untuk navigasi programmatis
            routes: {
              '/home': (context) => const HomeShell(),
              '/login': (context) => const LoginPage(),
            },

            // Override builder untuk mengunci skala teks tetap 1.0.
            // Mencegah layout rusak jika pengguna mengubah ukuran font di pengaturan HP.
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
