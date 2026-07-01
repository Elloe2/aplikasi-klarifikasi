// ==============================================================================
// CONFIG.DART - KONFIGURASI API KEY DEFAULT KLARIP
// ==============================================================================
// File ini menyimpan API key BAWAAN (default) yang digunakan saat pengguna
// belum memasukkan API key miliknya sendiri di menu Pengaturan.
//
// PENTING UNTUK DIPAHAMI:
// - Semua API key bersifat DINAMIS -- bisa diganti pengguna di menu Pengaturan
// - Konstanta di sini hanya sebagai NILAI AWAL (fallback)
// - API key yang aktif dikelola oleh masing-masing Provider:
//   * Gemini API key -> GeminiApiProvider
//   * Google CSE API key & CX -> SearchApiProvider
//
// CARA MENGGUNAKAN API KEY DI KODE:
// Gunakan context.read<GeminiApiProvider>().apiKey
// bukan langsung mengakses konstanta di sini.
// ==============================================================================
library;

/// API key default untuk Google Gemini AI.
/// Format: Dimulai dengan 'AQ.' (API key v2 dari Google AI Studio)
/// Pengguna bisa menggantinya di: menu Profil -> Pengaturan API -> Gemini API Key
const String defaultGeminiApiKey = 'AQ.Ab8RN6IcqiuL6ib9m5jUUG4zsDbafkI9BtkWfekTAmsKWh345Q';

/// API key default untuk Google Custom Search Engine (CSE).
/// Format: Dimulai dengan 'AIzaSy' (API key standar Google Cloud)
/// Digunakan untuk memanggil Google Custom Search JSON API.
const String defaultGoogleCseApiKey = 'AIzaSyAFOdoaMwgurnjfnhGKn5GFy6_m2HKiGtA';

/// Search Engine ID (CX) default untuk Google Custom Search Engine.
/// ID ini menentukan MESIN PENCARI KUSTOM mana yang digunakan.
/// Setiap CX dikonfigurasi di Google Programmable Search Engine Console
/// untuk membatasi pencarian pada sumber berita terpercaya Indonesia.
const String defaultGoogleCseCx = '6242f5825dedb4b59';
