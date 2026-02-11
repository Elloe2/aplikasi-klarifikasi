/// ============================================================================
/// SEARCH RESULT MODEL - KLARIFIKASI.ID FRONTEND
/// ============================================================================
/// Model class untuk merepresentasikan satu hasil pencarian dari Google CSE.
/// Berisi informasi artikel/berita yang didapat langsung dari Google CSE API.
///
/// Struktur Data:
/// - title: Judul artikel/berita
/// - snippet: Cuplikan isi artikel
/// - link: URL lengkap artikel
/// - displayLink: Domain sumber (contoh: detik.com)
/// - formattedUrl: URL yang diformat untuk display
/// - thumbnail: URL gambar thumbnail (opsional)
/// - credibilityScore: Skor kredibilitas sumber (opsional)
/// - publishedDate: Tanggal publikasi artikel (opsional)
/// ============================================================================
library;

import 'dart:ui'; // For Color class

/// === SEARCH RESULT DATA MODEL ===
/// Class untuk menyimpan data hasil pencarian dari Google Custom Search Engine.
/// Data didapat langsung dari Google CSE API (client-side, tanpa backend).
///
/// Features:
/// - Immutable data class dengan final fields
/// - Factory constructor untuk parsing JSON dari API
/// - Null-safe parsing dengan default values
/// - DateTime parsing dengan error handling
///
/// Architecture:
/// - Data flow: Flutter Frontend → Google CSE API → Display
/// - JSON parsing: Google CSE response format
/// - Error handling: Graceful fallback untuk missing data
class SearchResult {
  /// === REQUIRED FIELDS ===
  /// Fields yang wajib diisi untuk setiap hasil pencarian
  ///
  /// Judul artikel atau berita pada hasil pencarian
  final String title;

  /// Cuplikan singkat isi artikel untuk membantu konteks
  final String snippet;

  /// URL penuh yang dapat diklik oleh pengguna
  final String link;

  /// Domain sumber (misalnya `detik.com`) untuk kredibilitas cepat
  final String displayLink;

  /// URL versi tampilan (sebagian besar sama dengan `link`)
  final String formattedUrl;

  /// === OPTIONAL FIELDS ===
  /// Fields tambahan untuk enrich hasil pencarian

  /// URL thumbnail dari Google CSE pagemap data
  final String? thumbnail;

  /// Skor kredibilitas sumber (0-100)
  final int? credibilityScore;

  /// Tanggal publikasi artikel agar bisa dihitung relative time
  final DateTime? publishedDate;

  /// === CONSTRUCTOR ===
  /// Constructor dengan required fields untuk basic search result.
  /// Optional fields untuk enhanced search results dengan metadata.
  const SearchResult({
    required this.title,
    required this.snippet,
    required this.link,
    required this.displayLink,
    required this.formattedUrl,
    this.thumbnail,
    this.credibilityScore,
    this.publishedDate,
  });

  /// === FACTORY CONSTRUCTOR - JSON PARSING ===
  /// Membuat SearchResult object dari response JSON Google CSE API.
  /// Mengkonversi data dari Google CSE API ke format Dart yang type-safe.
  ///
  /// JSON Structure dari Google CSE API:
  /// {
  ///   "title": "Judul Artikel Berita",
  ///   "snippet": "Cuplikan isi artikel yang menjelaskan...",
  ///   "link": "https://example.com/article/123",
  ///   "displayLink": "example.com",
  ///   "formattedUrl": "https://example.com/article/123",
  ///   "thumbnail": "https://example.com/image.jpg",
  ///   "credibility_score": 85,
  ///   "published_date": "2024-01-15T10:30:00Z"
  /// }
  ///
  /// Error Handling:
  /// - Null-safe parsing dengan default values
  /// - DateTime parsing dengan try-catch
  /// - Empty string fallback untuk required fields
  ///
  /// Usage:
  /// ```dart
  /// final results = json['results'] as List<dynamic>? ?? [];
  /// final searchResults = results.map((item) => SearchResult.fromJson(item)).toList();
  /// ```
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      // === REQUIRED FIELDS dengan null-safe parsing ===
      title: json['title'] as String? ?? 'Tanpa judul',
      snippet: json['snippet'] as String? ?? '',
      link: json['link'] as String? ?? '',
      displayLink: json['displayLink'] as String? ?? '',
      formattedUrl: json['formattedUrl'] as String? ?? '',

      // === OPTIONAL FIELDS ===
      thumbnail: json['thumbnail'] as String?,
      credibilityScore: json['credibility_score'] as int?,
      publishedDate: json['published_date'] != null
          ? DateTime.tryParse(json['published_date'] as String)
          : null,
    );
  }

  /// === HELPER METHODS ===

  /// Get kredibilitas sebagai text yang mudah dibaca
  String get credibilityText {
    final score = credibilityScore ?? 75; // Default 75 jika null
    if (score >= 80) return 'Sangat Terpercaya';
    if (score >= 60) return 'Terpercaya';
    if (score >= 40) return 'Cukup Terpercaya';
    return 'Perlu Verifikasi';
  }

  /// Get warna kredibilitas untuk UI display
  /// Return Color yang bisa digunakan untuk badges atau indicators
  /// {@macro color_scheme}
  /// {@category ui}
  /// {@subCategory indicators}
  Color get credibilityColor {
    final score = credibilityScore ?? 75;
    if (score >= 80) return const Color(0xFF10B981); // Green
    if (score >= 60) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }

  /// Check apakah hasil memiliki gambar thumbnail
  bool get hasThumbnail => thumbnail != null && thumbnail!.isNotEmpty;

  /// Check apakah hasil memiliki tanggal publikasi
  bool get hasPublishedDate => publishedDate != null;

  /// Get relative time dari published date
  String? get relativeTime {
    if (publishedDate == null) return null;

    final now = DateTime.now();
    final difference = now.difference(publishedDate!);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Get domain dari URL untuk display
  String get domain {
    try {
      final uri = Uri.parse(link);
      return uri.host;
    } catch (e) {
      return displayLink;
    }
  }

  /// Check apakah link valid dan bisa diakses
  bool get hasValidLink => link.isNotEmpty && Uri.tryParse(link) != null;

  /// Get snippet yang sudah dibersihkan (remove extra whitespace)
  String get cleanSnippet {
    return snippet.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Get title yang sudah dibersihkan
  String get cleanTitle {
    return title.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Convert objects to Map for JSON encoding
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'snippet': snippet,
      'link': link,
      'displayLink': displayLink,
      'formattedUrl': formattedUrl,
      'thumbnail': thumbnail,
      'credibility_score': credibilityScore,
      'published_date': publishedDate?.toIso8601String(),
    };
  }
}

/// === USAGE EXAMPLES ===
///
/// 1. Parsing dari Google CSE API response:
/// ```dart
/// final results = items.map((item) => SearchResult(
///   title: item['title'] ?? 'No Title',
///   link: item['link'] ?? '',
///   snippet: item['snippet'] ?? '',
///   displayLink: item['displayLink'] ?? '',
///   formattedUrl: item['formattedUrl'] ?? '',
/// )).toList();
/// ```
///
/// 2. Display di UI:
/// ```dart
/// ListTile(
///   leading: result.hasThumbnail ? Image.network(result.thumbnail!) : Icon(Icons.article),
///   title: Text(result.cleanTitle),
///   subtitle: Text(result.cleanSnippet),
///   trailing: Text(result.credibilityText),
/// )
/// ```
///
/// 3. Filter dan sort results:
/// ```dart
/// final trustedResults = results.where((result) => (result.credibilityScore ?? 0) >= 70);
/// final recentResults = results.where((result) => result.hasPublishedDate).toList()
///   ..sort((a, b) => (b.publishedDate ?? DateTime.now()).compareTo(a.publishedDate ?? DateTime.now()));
/// ```
///
/// === DATA FLOW (Client-Side) ===
/// 1. User melakukan pencarian di Flutter app
/// 2. SearchApi memanggil Google CSE API secara langsung
/// 3. Google mengembalikan hasil pencarian dalam format JSON
/// 4. SearchResult.fromJson() mem-parse response
/// 5. GeminiService menganalisis klaim berdasarkan hasil pencarian
/// 6. Hasil pencarian + analisis AI ditampilkan di UI
///
/// === PERFORMANCE CONSIDERATIONS ===
/// - Immutable objects untuk mencegah unnecessary rebuilds
/// - Lazy parsing untuk optional fields
/// - Null-safe operations untuk graceful error handling
/// - Efficient string operations untuk clean display
