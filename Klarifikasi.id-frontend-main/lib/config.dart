/// ============================================================================
/// KONFIGURASI API - KLARIFIKASI.ID FRONTEND
/// ============================================================================
/// File ini berisi konfigurasi untuk API keys yang digunakan oleh aplikasi.
/// Semua API dipanggil langsung dari client (tanpa backend server).
///
/// Struktur:
/// - geminiApiKey: API key untuk Google Gemini AI
/// - googleCseApiKey: API key untuk Google Custom Search Engine
/// - googleCseCx: Search Engine ID untuk Google CSE
/// ============================================================================
library;

/// === GEMINI API CONFIGURATION ===
/// Getter function untuk Google Gemini AI API Key.
String get geminiApiKey {
  // === VALID API KEY ===
  // Warning: Hardcoding API keys in frontend code is not secure for production apps.
  // Use Firebase Remote Config or environment variables for better security.
  return 'AIzaSyAnD4JUB291cnSR1sghyQTD6Q4gSrzBQ_4';
}

/// === GOOGLE CSE API CONFIGURATION ===
/// API Key untuk Google Custom Search Engine.
String get googleCseApiKey {
  return 'AIzaSyAFOdoaMwgurnjfnhGKn5GFy6_m2HKiGtA';
}

/// === GOOGLE CSE CX CONFIGURATION ===
/// Search Engine ID (CX) untuk Google Custom Search Engine.
String get googleCseCx {
  return '6242f5825dedb4b59';
}
