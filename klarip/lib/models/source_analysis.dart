// ==============================================================================
// PENJELASAN UNTUK SIDANG: MODEL SOURCE ANALYSIS
// ==============================================================================
// Bapak/Ibu Penguji, file ini adalah sebuah "Model" (Blue Print / Cetakan Data).
// Fungsinya mendefinisikan struktur data untuk menyimpan sikap (STANCE) dari 
// masing-masing artikel berita terhadap klaim yang sedang kita uji.
//
// KONSEP 'STANCE' (SIKAP BERITA):
// AI kami dilatih untuk tidak sekadar membaca, tapi juga menilai kecenderungan 
// (bias) dari sebuah berita. Apakah berita itu PRO, KONTRA, atau NETRAL terhadap klaim?
// 
// CONTOH KASUS:
// Klaim: "Bumi itu datar"
// Berita A (Sains)   -> OPPOSE (Menentang)
// Berita B (Konspirasi)-> SUPPORT (Mendukung)
// Berita C (Umum)    -> NEUTRAL (Hanya meliput bahwa ada perdebatan)
//
// Stance inilah yang nanti akan kami visualisasikan dengan warna di antarmuka (UI):
// Hijau untuk Mendukung, Merah untuk Menentang, Abu-abu untuk Netral.
// ==============================================================================

/// Model data yang merepresentasikan analisis AI terhadap satu sumber berita spesifik.
class SourceAnalysis {
  /// Nomor urut (Index) berita dari Google Search (mulai dari 0).
  /// Ini bertindak sebagai ID agar kita tahu analisis ini milik berita yang mana.
  final int index;

  /// Posisi/sikap sumber terhadap klaim.
  /// Berisi salah satu dari: 'SUPPORT', 'OPPOSE', atau 'NEUTRAL'
  final String stance;

  /// Penjelasan logis mengapa AI menyimpulkan stance tersebut.
  /// AI dipaksa memberikan argumen (Reasoning), bukan sekadar menebak.
  final String reasoning;

  /// Kutipan langsung (Quote) dari teks berita asli yang membuktikan stance-nya.
  /// Dibuat 'nullable' (?) karena kadang AI tidak menemukan kutipan yang pas.
  final String? quote;

  /// Constructor: Fungsi untuk mencetak objek SourceAnalysis baru.
  const SourceAnalysis({
    required this.index,
    required this.stance,
    required this.reasoning,
    this.quote, 
  });

  /// PENJELASAN SIDANG: FACTORY CONSTRUCTOR DARI JSON
  /// Saat Gemini AI membalas permintaan aplikasi, balasan itu masih berupa
  /// teks mentah berformat JSON (JavaScript Object Notation). 
  /// Fungsi inilah yang bertugas menyulap JSON mentah tersebut menjadi
  /// Objek Dart `SourceAnalysis` yang bisa kita proses lebih lanjut.
  factory SourceAnalysis.fromJson(Map<String, dynamic> json, int index) {
    return SourceAnalysis(
      index: index,
      // Default value: Jika AI bingung / gagal mendeteksi stance, kita anggap NEUTRAL
      stance: json['stance'] as String? ?? 'NEUTRAL',
      // Default value untuk reasoning jika kosong
      reasoning: json['reasoning'] as String? ?? 'Tidak ada penjelasan tersedia',
      // Karena quote nullable, jika json['quote'] tidak ada, ia otomatis null
      quote: json['quote'] as String?,
    );
  }

  /// Kebalikan dari fromJson. Fungsi ini mengubah Objek kembali ke JSON.
  /// Biasanya dipakai sebelum data disimpan ke Database (SQLite).
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'stance': stance,
      'reasoning': reasoning,
      // PENJELASAN SIDANG: SPREAD OPERATOR
      // 'if (quote != null)' mencegah kita menyimpan nilai null ke database.
      // Ini membuat ukuran database lebih ringkas.
      if (quote != null) 'quote': quote,
    };
  }

  // ==========================================================================
  // PENJELASAN SIDANG: GETTER BANTUAN UNTUK UI (TAMPILAN)
  // ==========================================================================

  /// UI kita menggunakan Bahasa Indonesia, sedangkan kode sistem kita pakai Bahasa Inggris.
  /// Getter ini bertugas menerjemahkan (Translasi Otomatis) kode 'SUPPORT' jadi 'Mendukung' dll.
  /// Mengapa tidak langsung simpan Bahasa Indonesia di database? 
  /// Karena AI lebih stabil membalas dalam keyword Inggris, dan standarisasi kode lebih baik.
  String get stanceText {
    switch (stance) {
      case 'SUPPORT':
        return 'Mendukung'; 
      case 'OPPOSE':
        return 'Menentang'; 
      case 'NEUTRAL':
        return 'Netral'; 
      default:
        return stance; // Jaga-jaga jika AI membalas di luar 3 kata di atas
    }
  }

  /// Mengecek apakah artikel ini memiliki kutipan spesifik atau tidak.
  bool get hasQuote => quote != null && quote!.isNotEmpty;
}
