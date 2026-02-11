/// =========================================================================
/// ENTRY POINT - KLARIFIKASI.ID FLUTTER APPLICATION
/// =========================================================================
/// File ini adalah pintu masuk pertama ketika aplikasi dijalankan.
/// Tanggung jawab utamanya hanya memanggil `runApp()` dengan root widget
/// `MainApp`, sementara seluruh konfigurasi detail (theme, routes, providers)
/// diserahkan ke `lib/app/app.dart`.
///
/// Struktur:
/// - `main()`: fungsi entry point yang men-setup Flutter binding dan
///   mengeksekusi `runApp()`.
/// - `MainApp`: root widget yang mengatur konfigurasi global aplikasi.
/// =========================================================================
library;

import 'package:flutter/material.dart'; // Widget & utilities Material Design

import 'app/app.dart'; // Root widget yang berisi konfigurasi lengkap aplikasi

/// === MAIN ENTRY POINT ===
/// Fungsi pertama yang dieksekusi saat aplikasi mulai berjalan.
/// Menjalankan `MainApp` sebagai root widget sehingga semua konfigurasi
/// (tema, routing, provider) tersusun di satu tempat.
///
/// Catatan praktik terbaik:
/// - Jaga fungsi `main()` tetap ringkas dan bebas logika berat.
/// - Lakukan setup dependency/konfigurasi lewat widget tree di `MainApp`.
/// - Gunakan `runApp()` untuk mem-boot aplikasi ke platform target.
///
/// Contoh eksekusi:
/// ```bash
/// flutter run -d chrome   # Menjalankan aplikasi di browser web
/// flutter run -d android  # Menjalankan aplikasi di emulator/perangkat Android
/// ```
void main() {
  // Start aplikasi Flutter dengan `MainApp` sebagai root widget.
  // Seluruh konfigurasi (theme, routes, provider, autentikasi) dilakukan di sana.
  runApp(const MainApp());
}
