// ==============================================================================
// PENJELASAN UNTUK SIDANG: MODEL SEARCH RESULT
// ==============================================================================
// Bapak/Ibu Penguji, file ini adalah "Cetakan Data" (Model) untuk menyimpan 
// informasi dari artikel berita yang ditemukan oleh Google Custom Search Engine (CSE).
//
// BAGAIMANA ALURNYA?
// 1. Google merespons pencarian dengan format teks JSON (yang sulit dibaca).
// 2. File ini menggunakan `fromJson` untuk mengubah teks tersebut menjadi
//    Objek `SearchResult` yang rapi dan mudah ditampilkan di UI (Antarmuka).
//
// FIELD UTAMA:
// - title       : Judul artikel berita.
// - snippet     : Cuplikan ringkas isi berita (menghemat waktu tanpa klik link).
// - link        : Tautan (URL) asli untuk memverifikasi sumber langsung.
// - thumbnail   : Gambar pratinjau berita (Opsional, agar UI lebih menarik).
//
// KREDIBILITAS:
// Kami juga menambahkan logika untuk menilai kredibilitas domain berdasarkan skor.
// Fungsi `credibilityText` dan `credibilityColor` digunakan agar artikel 
// mendapat label otomatis (misal: "Sangat Terpercaya" berwarna Hijau).
// ==============================================================================
library;

import 'dart:ui'; // Untuk class Color (pewarnaan badge kredibilitas)

/// Model data yang merepresentasikan satu artikel/berita dari hasil Google CSE.
/// Setiap kali Google CSE menemukan artikel, datanya diubah menjadi objek ini.
class SearchResult {
  // ==========================================================================
  // FIELD WAJIB (selalu ada di setiap hasil pencarian dari Google)
  // ==========================================================================

  /// Judul artikel berita yang ditemukan
  /// Contoh: "Menteri Keuangan Bantah Isu Penggantian Jabatan"
  final String title;

  /// Cuplikan singkat isi artikel (2-3 kalimat otomatis dari Google)
  /// Memberikan gambaran isi artikel tanpa harus membukanya
  final String snippet;

  /// URL lengkap artikel yang bisa diklik pengguna untuk membaca selengkapnya
  /// Contoh: "https://www.kompas.com/nasional/2024/01/15/..."
  final String link;

  /// Nama domain sumber berita (dari mana artikel ini berasal)
  /// Contoh: "kompas.com", "detik.com", "tempo.co"
  /// Digunakan untuk menampilkan nama sumber tanpa URL panjang
  final String displayLink;

  /// URL yang sudah diformat rapi untuk ditampilkan di UI
  /// Biasanya sama dengan link, tapi kadang lebih pendek/bersih
  final String formattedUrl;

  // ==========================================================================
  // FIELD OPSIONAL (tidak semua artikel memiliki data ini)
  // ==========================================================================

  /// URL gambar thumbnail artikel (null jika tidak ada gambar)
  /// Didapat dari metadata Open Graph atau schema CSE Image di halaman artikel
  final String? thumbnail;

  /// Skor kredibilitas sumber (0-100). null jika tidak ada data skor.
  /// Skor ini bisa digunakan untuk menampilkan badge "Sangat Terpercaya" dll.
  final int? credibilityScore;

  /// Tanggal artikel dipublikasikan. null jika tidak ada informasi tanggal.
  final DateTime? publishedDate;

  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================
  /// Membuat objek SearchResult. Field opsional bisa tidak diisi (null).
  const SearchResult({
    required this.title,
    required this.snippet,
    required this.link,
    required this.displayLink,
    required this.formattedUrl,
    this.thumbnail,         // Opsional
    this.credibilityScore,  // Opsional
    this.publishedDate,     // Opsional
  });

  // ==========================================================================
  // FACTORY CONSTRUCTOR (dari JSON Google CSE)
  // ==========================================================================
  /// Membuat objek SearchResult dari data JSON yang dikembalikan oleh Google CSE API.
  /// Ini adalah "kebalikan" dari toMap() -- mengubah Map JSON ke objek Dart.
  ///
  /// Contoh struktur JSON dari Google CSE:
  /// {
  ///   "title": "Judul Artikel",
  ///   "snippet": "Cuplikan artikel...",
  ///   "link": "https://example.com/artikel",
  ///   "displayLink": "example.com",
  ///   "formattedUrl": "https://example.com/artikel",
  ///   "thumbnail": "https://example.com/gambar.jpg",
  /// }
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      // Gunakan ?? untuk memberikan nilai default jika data null dari Google
      title: json['title'] as String? ?? 'Tanpa judul',
      snippet: json['snippet'] as String? ?? '',
      link: json['link'] as String? ?? '',
      displayLink: json['displayLink'] as String? ?? '',
      formattedUrl: json['formattedUrl'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?, // Boleh null
      credibilityScore: json['credibility_score'] as int?, // Boleh null
      publishedDate: json['published_date'] != null
          ? DateTime.tryParse(json['published_date'] as String)
          : null, // DateTime.tryParse mengembalikan null jika format salah
    );
  }

  // ==========================================================================
  // GETTER HELPER UNTUK UI
  // ==========================================================================
  // Getter-getter ini membantu widget menampilkan data dengan format yang tepat.

  /// Mengubah angka skor kredibilitas menjadi teks deskriptif
  /// Digunakan untuk badge seperti "Sangat Terpercaya", "Terpercaya", dll.
  String get credibilityText {
    final score = credibilityScore ?? 75; // Jika tidak ada skor, anggap 75 (Terpercaya)
    if (score >= 80) return 'Sangat Terpercaya';
    if (score >= 60) return 'Terpercaya';
    if (score >= 40) return 'Cukup Terpercaya';
    return 'Perlu Verifikasi';
  }

  /// Menghasilkan warna sesuai tingkat kredibilitas sumber.
  /// Warna ini digunakan untuk badge indikator di tampilan kartu artikel.
  /// Hijau = sangat terpercaya, Kuning = cukup terpercaya, Merah = perlu verifikasi
  Color get credibilityColor {
    final score = credibilityScore ?? 75;
    if (score >= 80) return const Color(0xFF10B981); // Hijau
    if (score >= 60) return const Color(0xFFF59E0B); // Kuning/oranye
    return const Color(0xFFEF4444); // Merah
  }

  /// true jika artikel ini memiliki gambar thumbnail
  bool get hasThumbnail => thumbnail != null && thumbnail!.isNotEmpty;

  /// true jika artikel ini memiliki informasi tanggal publikasi
  bool get hasPublishedDate => publishedDate != null;

  /// Mengubah tanggal publikasi menjadi teks relatif yang mudah dibaca
  /// Contoh: "2 hari yang lalu", "3 jam yang lalu", "Baru saja"
  String? get relativeTime {
    if (publishedDate == null) return null; // Tidak ada tanggal

    final now = DateTime.now();
    final difference = now.difference(publishedDate!); // Hitung selisih waktu

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

  /// Mengekstrak domain dari URL lengkap artikel.
  /// Berguna sebagai fallback jika displayLink tidak tersedia.
  /// Contoh: "https://www.kompas.com/artikel/123" -> "www.kompas.com"
  String get domain {
    try {
      final uri = Uri.parse(link); // Parsing URL
      return uri.host; // Ambil bagian host/domain saja
    } catch (e) {
      return displayLink; // Fallback ke displayLink jika URL tidak bisa di-parse
    }
  }

  /// true jika link URL valid dan bisa dibuka
  bool get hasValidLink => link.isNotEmpty && Uri.tryParse(link) != null;

  /// Cuplikan artikel yang sudah dibersihkan dari spasi berlebih
  String get cleanSnippet {
    return snippet.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Judul artikel yang sudah dibersihkan dari spasi berlebih
  String get cleanTitle {
    return title.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ==========================================================================
  // SERIALISASI KE MAP
  // ==========================================================================
  /// Mengubah objek SearchResult kembali ke Map (untuk disimpan atau dikirim)
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
