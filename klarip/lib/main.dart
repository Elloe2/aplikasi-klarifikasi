// ==============================================================================
// MAIN.DART - TITIK MASUK APLIKASI KLARIP
// ==============================================================================
// File ini adalah PINTU UTAMA aplikasi Flutter.
// Hanya bertugas satu hal: memanggil runApp() untuk memulai aplikasi.
//
// ALUR STARTUP APLIKASI:
// 1. Flutter memanggil fungsi main()
// 2. main() memanggil runApp(MainApp())
// 3. MainApp (di app/app.dart) memuat: Provider, Theme, dan Routing
// 4. AuthProvider mengecek sesi login -> tampilkan LoginPage atau HomeShell
//
// PRINSIP DESAIN:
// File main.dart dibuat sesederhana mungkin. Semua konfigurasi detail
// (tema, routing, provider) dikelola di lib/app/app.dart.
// ==============================================================================
library;

import 'package:flutter/material.dart'; // Framework Flutter (wajib ada)

import 'app/app.dart'; // Root widget yang berisi konfigurasi lengkap aplikasi

/// Fungsi main() adalah titik masuk (entry point) pertama yang dieksekusi
/// saat aplikasi dijalankan. Tidak boleh ada logika berat di sini.
void main() {
  // Memulai aplikasi Flutter dengan MainApp sebagai root widget.
  // Semua konfigurasi (theme, routing, provider, autentikasi) ada di MainApp.
  runApp(const MainApp());
}
