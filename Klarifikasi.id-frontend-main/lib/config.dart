/// ============================================================================
/// KONFIGURASI API - KLARIFIKASI.ID FRONTEND
/// ============================================================================
/// File ini berisi konfigurasi default untuk API keys yang digunakan aplikasi.
/// Semua API dipanggil langsung dari client (tanpa backend server).
///
/// CATATAN: Semua API key sekarang bersifat dinamis dan dikelola oleh Provider:
/// - Gemini API key → GeminiApiProvider
/// - Google CSE API key & CX → SearchApiProvider
///
/// Gunakan context.read<Provider>().apiKey untuk mendapatkan key aktif.
/// Konstanta di sini hanya digunakan sebagai default/fallback oleh providers.
/// ============================================================================
library;

/// === DEFAULT GEMINI API KEY ===
/// API key default bawaan aplikasi. Bisa diganti oleh user melalui Settings.
const String defaultGeminiApiKey = 'AIzaSyAnD4JUB291cnSR1sghyQTD6Q4gSrzBQ_4';

/// === DEFAULT GOOGLE CSE API KEY ===
/// API Key default untuk Google Custom Search Engine.
const String defaultGoogleCseApiKey = 'AIzaSyAFOdoaMwgurnjfnhGKn5GFy6_m2HKiGtA';

/// === DEFAULT GOOGLE CSE CX ===
/// Search Engine ID (CX) default untuk Google Custom Search Engine.
const String defaultGoogleCseCx = '6242f5825dedb4b59';
