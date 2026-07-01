// ==============================================================================
// PENJELASAN UNTUK SIDANG: MODEL SAVED ANALYSIS
// ==============================================================================
// Bapak/Ibu Penguji, ini adalah Model (Struktur Data) untuk fitur "Koleksi" (Saved Page).
// Fungsinya mendefinisikan satu baris riwayat verifikasi yang disimpan di SQLite.
//
// KONSEP PENTING:
// 1. `toMap` dan `fromMap`: Di dunia database lokal (SQLite), data harus berbentuk
//    "Map" (Kamus) agar bisa disimpan di kolom tabel. Fungsi inilah jembatannya.
// 2. Konversi Tipe Data: Anda bisa lihat `isFavorite` itu Boolean (True/False).
//    Tetapi SQLite tidak kenal Boolean, ia hanya kenal Angka (Integer 0 dan 1).
//    Di sinilah kode kami mengkonversi Boolean ke Integer saat menyimpan, dan
//    mengembalikan Integer ke Boolean saat membaca (parsing).
// 3. `copyWith`: Fitur untuk membuat duplikat riwayat dengan sedikit perubahan
//    (misalnya, jika user cuma mau mengubah status favorit saja).
// ==============================================================================

/// Model data untuk satu riwayat analisis klaim yang disimpan.
/// Berisi semua informasi: klaim, verdict, penjelasan, analisis, dan metadata.
class SavedAnalysis {
  final int? id; // ID unik dari database (null sebelum disimpan)
  final String title; // Judul yang diberikan pengguna untuk riwayat ini
  final String claim; // Teks klaim yang diverifikasi
  final String verdict; // Hasil: DIDUKUNG_DATA / TIDAK_DIDUKUNG_DATA / MEMERLUKAN_VERIFIKASI
  final String explanation; // Penjelasan singkat (2-3 kalimat) dari Gemini AI
  final String analysis; // Analisis mendalam (4-5 kalimat) dari Gemini AI
  final String confidence; // Tingkat keyakinan analisis (tinggi/sedang/rendah)
  final String userNote; // Catatan tambahan yang ditulis pengguna sendiri
  final String sourceUrl; // URL sumber utama yang dirujuk
  final DateTime savedAt; // Waktu penyimpanan
  final bool isFavorite; // Apakah riwayat ini ditandai sebagai favorit?
  final String userEmail; // Email pengguna pemilik riwayat (untuk multi-akun)

  /// Constructor dengan beberapa nilai default.
  /// Nilai default mencegah error jika field opsional tidak diisi.
  SavedAnalysis({
    this.id,
    required this.title,
    required this.claim,
    required this.verdict,
    required this.explanation,
    this.analysis = '', // Default: kosong jika tidak ada analisis mendalam
    required this.confidence,
    this.userNote = '', // Default: kosong jika pengguna tidak menulis catatan
    this.sourceUrl = '', // Default: kosong jika tidak ada URL sumber
    required this.savedAt,
    this.isFavorite = false, // Default: tidak difavoritkan
    this.userEmail = '', // Default: kosong (bisa terjadi pada data lama)
  });

  /// Mengubah objek SavedAnalysis menjadi Map untuk disimpan ke SQLite.
  /// Perhatikan: 'isFavorite' (bool) dikonversi ke integer (1/0)
  /// karena SQLite tidak mendukung tipe data boolean secara native.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'claim': claim,
      'verdict': verdict,
      'explanation': explanation,
      'analysis': analysis,
      'confidence': confidence,
      'user_note': userNote, // Di database: 'user_note' (dengan underscore)
      'source_url': sourceUrl,
      'saved_at': savedAt.toIso8601String(), // DateTime dikonversi ke String ISO 8601
      'is_favorite': isFavorite ? 1 : 0, // true=1, false=0 (konversi bool ke int)
      'user_email': userEmail,
    };
  }

  /// Factory constructor: membuat objek SavedAnalysis dari Map (data dari database).
  /// Kebalikan dari toMap() -- mengubah data SQLite kembali menjadi objek Dart.
  factory SavedAnalysis.fromMap(Map<String, dynamic> map) {
    return SavedAnalysis(
      id: map['id'],
      title: map['title'],
      claim: map['claim'],
      verdict: map['verdict'],
      explanation: map['explanation'],
      analysis: map['analysis'] ?? '', // Operator ?? untuk nilai default jika null
      confidence: map['confidence'],
      userNote: map['user_note'],
      sourceUrl: map['source_url'],
      savedAt: DateTime.parse(map['saved_at']), // String ISO 8601 -> DateTime
      isFavorite: map['is_favorite'] == 1, // Integer (1/0) -> bool (true/false)
      userEmail: map['user_email'] ?? '',
    );
  }

  /// Membuat salinan objek SavedAnalysis dengan beberapa field yang diubah.
  /// Digunakan misalnya saat pengguna mengubah status favorit atau catatan.
  ///
  /// Contoh: Menambah/hapus favorit tanpa mengubah field lain:
  /// SavedAnalysis updated = item.copyWith(isFavorite: true);
  SavedAnalysis copyWith({
    int? id,
    String? title,
    String? claim,
    String? verdict,
    String? explanation,
    String? analysis,
    String? confidence,
    String? userNote,
    String? sourceUrl,
    DateTime? savedAt,
    bool? isFavorite,
    String? userEmail,
  }) {
    return SavedAnalysis(
      id: id ?? this.id,
      title: title ?? this.title,
      claim: claim ?? this.claim,
      verdict: verdict ?? this.verdict,
      explanation: explanation ?? this.explanation,
      analysis: analysis ?? this.analysis,
      confidence: confidence ?? this.confidence,
      userNote: userNote ?? this.userNote,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      savedAt: savedAt ?? this.savedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
