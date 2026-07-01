// ==============================================================================
// PENJELASAN UNTUK SIDANG: GEMINI SERVICE
// ==============================================================================
// Bapak/Ibu Penguji, file `gemini_service.dart` ini adalah komponen AI dari
// aplikasi Klarip. File ini bertanggung jawab penuh untuk melakukan komunikasi 
// (request dan response) dengan server Google Gemini AI.
//
// KONSEP UTAMA YANG DIGUNAKAN: RAG (Retrieval-Augmented Generation)
// Aplikasi ini tidak membiarkan AI menjawab klaim dari pengetahuannya sendiri
// (yang berpotensi salah/halusinasi). Sebaliknya, aplikasi ini mengambil data 
// terbaru dari Google Search (Retrieval), lalu memberikannya ke AI sebagai 
// konteks atau sumber kebenaran, baru AI menyusun kesimpulan (Generation).
//
// ALUR KERJA (Bisa dijelaskan saat demo aplikasi):
// 1. Menerima data: Teks klaim dari user dan daftar artikel berita dari Google CSE.
// 2. Menyusun Prompt: Membuat teks instruksi khusus yang berisi klaim, aturan 
//    analisis, dan teks artikel berita.
// 3. HTTP Request: Mengirim data tersebut ke API Gemini menggunakan metode HTTP POST.
// 4. JSON Parsing: Mengubah (parsing) jawaban Gemini yang berformat teks JSON
//    menjadi objek `GeminiAnalysis` agar mudah ditampilkan di UI aplikasi.
// ==============================================================================

import 'dart:convert'; // Library bawaan Dart untuk encode (mengubah ke String) dan decode (mengubah ke bentuk Map) data JSON.
import 'package:http/http.dart' as http; // Package eksternal untuk melakukan HTTP request (seperti GET atau POST) ke server.
import '../models/search_result.dart'; // Blueprint/Model dari data artikel berita hasil pencarian.
import '../models/gemini_analysis.dart'; // Blueprint/Model dari data hasil analisis akhir AI.

/// PENJELASAN SIDANG:
/// Kelas ini bertugas sebagai 'Service' (Layanan) khusus AI.
/// Kita memisahkan logika AI ke dalam kelas ini agar kode lebih rapi (Separation of Concerns).
/// UI (halaman layar) tidak perlu tahu cara kerja API, UI cukup memanggil fungsi di kelas ini.
class GeminiService {
  // PENJELASAN SIDANG:
  // Ini adalah URL endpoint resmi dari Google Gemini API.
  // ALASAN PEMILIHAN MODEL: Kami menggunakan `gemini-2.5-flash-lite`. 
  // 'Flash' berarti cepat, dan 'Lite' berarti ringan. Ini sangat cocok untuk
  // aplikasi mobile karena hemat kuota internet dan memberikan respons yang nyaris instan
  // dibandingkan model AI versi Pro yang lebih berat dan lambat.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  /// Callback untuk mencatat statistik penggunaan API jika sukses.
  final void Function()? onUsage;

  /// Callback untuk melempar pesan error ke Provider jika terjadi kegagalan (misal API Key habis).
  final void Function(int statusCode, String errorMessage)? onError;

  /// Constructor (Fungsi pembangun) kelas. Menerima callback opsional.
  GeminiService({this.onUsage, this.onError});

  /// PENJELASAN SIDANG:
  /// Ini adalah fungsi utama (Core Function) untuk menganalisis klaim.
  /// Fungsi ini bersifat `async` (Asynchronous) karena proses menembak API membutuhkan
  /// waktu (internet delay). Kita tidak ingin aplikasi 'freeze' atau macet saat menunggu,
  /// jadi kita menggunakan `await`.
  /// 
  /// Parameter `apiKey` dikirim dari luar (di-inject) agar jika user mengubah API Key di Pengaturan,
  /// kelas ini langsung menggunakan API Key yang baru tanpa perlu di-restart.
  Future<GeminiAnalysis> analyzeClaim(
    String apiKey,
    String claim,
    List<SearchResult> searchResults, {
    String? customInstructions,
  }) async {
    // 1. Menyiapkan URL dengan menambahkan API Key pengguna ke dalam parameter URL.
    final url = Uri.parse('$_baseUrl?key=$apiKey');

    // 2. Memanggil fungsi private `_buildPrompt` untuk merangkai instruksi panjang ke AI.
    final prompt = _buildPrompt(claim, searchResults,
        customInstructions: customInstructions);

    try {
      // PENJELASAN SIDANG:
      // 3. MENGIRIM REQUEST KE GEMINI
      // Kita menggunakan metode HTTP POST karena kita mengirim data (prompt) yang cukup besar
      // di dalam 'body' request.
      final response = await http.post(
        url,
        // Header menyatakan bahwa format data yang kita kirim adalah JSON
        headers: {'Content-Type': 'application/json'},
        // Body adalah isi payload. Kita merangkainya sesuai dengan struktur standar API Google.
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}, // Memasukkan prompt yang sudah dirangkai tadi
              ],
            },
          ],
          'generationConfig': {
            // PENJELASAN SIDANG:
            // Parameter 'temperature' ini sangat penting!
            // Temperature mengatur tingkat 'kreativitas' atau 'halusinasi' dari AI.
            // Nilai 0.2 adalah nilai yang sangat rendah. Ini memaksa AI untuk menjawab
            // secara faktual, kaku, dan konsisten dengan teks sumber (berita) yang kita berikan,
            // dan tidak mengarang bebas.
            'temperature': 0.2, 
            'maxOutputTokens': 2048, // Batas maksimal panjang kata/token jawaban AI
          },
        }),
      );

      // PENJELASAN SIDANG:
      // 4. MENERIMA DAN MEMPROSES RESPONSE (JAWABAN)
      // Kode 200 berarti OK (Berhasil). Jika berhasil, kita bongkar file JSON jawabannya.
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // jsonDecode mengubah Teks JSON jadi Map di Dart
        
        // Kita telusuri struktur JSON bersarang (nested JSON) dari Google untuk mengambil teks jawabannya.
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null) {
          onUsage?.call(); // Catat penggunaan (analytics) bahwa API berhasil dipanggil
          // Memanggil fungsi private `_parseResponse` untuk mengubah teks JSON dari AI jadi objek Dart
          return _parseResponse(text, claim); 
        }
      }

      // === PENJELASAN SIDANG: PENANGANAN ERROR (ERROR HANDLING) ===
      // Jika status bukan 200, berarti ada yang salah (misal: kuota habis, internet putus, API key salah).
      // Aplikasi yang baik tidak boleh 'crash' atau keluar sendiri saat error, melainkan harus
      // memberikan pesan error yang jelas kepada user.
      String errorMsg =
          'Gagal mengambil analisis AI. Status: ${response.statusCode}';

      // Kita mencoba mengekstrak pesan error resmi yang dikirimkan oleh server Google
      try {
        final errorData = jsonDecode(response.body);
        final apiError = errorData['error']?['message'] ?? '';
        if (apiError.toString().isNotEmpty) {
          errorMsg = apiError.toString();
        }
      } catch (_) {
        // Jika gagal diekstrak, kita abaikan dan pakai pesan default.
      }

      // Memberikan pesan terjemahan bahasa Indonesia yang lebih ramah pengguna
      // berdasarkan kode error standar HTTP.
      if (response.statusCode == 429) {
        // 429 Too Many Requests
        errorMsg = 'Quota API key habis. Silakan ganti API key di menu Pengaturan.';
      } else if (response.statusCode == 403) {
        // 403 Forbidden
        errorMsg = 'API key tidak valid atau diblokir. Silakan ganti API key di menu Pengaturan.';
      } else if (response.statusCode == 400) {
        // 400 Bad Request
        errorMsg = 'API key bermasalah. Silakan periksa atau ganti API key di menu Pengaturan.';
      }

      // Mengirimkan error ke Provider (State Management) agar UI bisa menampilkan notifikasi snackbar/alert
      onError?.call(response.statusCode, errorMsg);

      // Kita kembalikan objek error agar UI tetap bisa me-render tampilan dengan pesan error
      return _getErrorResponse(claim, errorMsg);
    } catch (e) {
      // PENJELASAN SIDANG: Block catch ini menangani 'Network Error'. 
      // Terjadi sebelum sempat ke server Google, misal: HP user tidak ada koneksi internet.
      return _getErrorResponse(claim, 'Terjadi kesalahan jaringan: $e');
    }
  }

  /// PENJELASAN SIDANG:
  /// Fungsi `_buildPrompt` inilah kunci keberhasilan RAG (Retrieval-Augmented Generation).
  /// Prompt Engineering adalah teknik menyusun kalimat perintah kepada AI agar hasil sesuai keinginan.
  /// Di sini kita menggabungkan 3 hal: Klaim User + Konteks Berita + Aturan/Tugas.
  String _buildPrompt(
    String claim,
    List<SearchResult> searchResults, {
    String? customInstructions,
  }) {
    // 1. Kumpulkan semua artikel berita dari SearchApi menjadi satu teks panjang (String)
    // Kita gunakan StringBuffer karena lebih hemat memori dan cepat dibanding operator String (+).
    StringBuffer sourcesBuffer = StringBuffer();

    for (int i = 0; i < searchResults.length; i++) {
      final r = searchResults[i];
      // PENJELASAN SIDANG:
      // Membersihkan link (domain). AI dilarang mengatakan "Menurut sumber 1",
      // karena terlihat seperti robot. AI harus bilang "Menurut kompas.com",
      // agar terkesan lebih pintar dan informasinya jelas asal-usulnya.
      final domain = r.displayLink
          .replaceFirst('www.', '')
          .replaceAll('https://', '')
          .replaceAll('http://', '')
          .split('/')[0];

      sourcesBuffer.writeln('\n--- Sumber ${i + 1} [$domain] ---');
      sourcesBuffer.writeln('Judul: ${r.title}');
      sourcesBuffer.writeln('Ringkasan: ${r.snippet}');
    }

    // 2. Siapkan instruksi analisis
    // Jika user mengaktifkan instruksi kustom di pengaturan (misal: "Beri gaya bahasa santai"), 
    // maka gunakan itu. Jika tidak, gunakan instruksi default yang ketat.
    final instructions =
        customInstructions ??
        '''1. Periksa apakah setiap sumber benar-benar berkaitan (RELEVAN) dengan isi klaim.
2. Identifikasi sumber yang mendukung (PRO) dan sumber yang membantah (KONTRA) terhadap klaim.
3. Bandingkan informasi antara satu sumber dengan sumber lainnya untuk melihat konsistensi data.
4. Tentukan verdict:
   - DIDUKUNG_DATA: Jika mayoritas sumber relevan mendukung klaim.
   - TIDAK_DIDUKUNG_DATA: Jika mayoritas sumber relevan membantah klaim (hoaks).
   - MEMERLUKAN_VERIFIKASI: Jika data kontradiktif atau tidak cukup bukti.''';

    // PENJELASAN SIDANG:
    // 3. Merangkai kerangka akhir Prompt. 
    // Hal yang paling penting di sini adalah bagian FORMAT JAWABAN.
    // Kami memaksa Gemini AI untuk hanya membalas dalam format JSON yang kaku, bukan paragraf panjang.
    // Tujuannya agar aplikasi (kode Dart kita) bisa langsung memecah jawabannya menjadi variabel-variabel
    // seperti `verdict`, `explanation`, dan `analysis` dengan mudah untuk ditampilkan di User Interface.
    return '''
Analisis klaim berikut secara kritis berdasarkan data sumber berita yang diberikan.

KLAIM: "$claim"

SUMBER DATA:
${sourcesBuffer.toString()}

TUGAS ANDA:
$instructions

ATURAN PENULISAN:
- DILARANG KERAS menyebut "Sumber 1", "Sumber 2", dst. Ganti dengan nama domain (contoh: "menurut detik.com...", "dilansir dari antaranews.com...").
- Gunakan penyebutan domain tanpa "www." (contoh: "kompas.com", jangan "www.kompas.com").
- Berikan analisis yang objektif tentang pro dan kontra yang ditemukan.

FORMAT JAWABAN (JSON SAJA):
{
  "verdict": "DIDUKUNG_DATA" | "TIDAK_DIDUKUNG_DATA" | "MEMERLUKAN_VERIFIKASI",
  "explanation": "Ringkasan 2-3 kalimat (sebutkan sumber pendukung/pembantah utama)",
  "analysis": "Analisis mendalam 4-5 kalimat tentang kaitan antar sumber, poin pro/kontra, dan fakta yang ditemukan",
  "sources_used": ["domain.com", "Lainnya.com"]
}
JAWAB HANYA JSON!
''';
  }

  /// PENJELASAN SIDANG:
  /// Fungsi `_parseResponse` mengubah String teks JSON dari jawaban Gemini
  /// dan memetakannya menjadi objek Dart `GeminiAnalysis` yang sudah kita buat blueprint-nya.
  GeminiAnalysis _parseResponse(String text, String claim) {
    try {
      // PENJELASAN SIDANG:
      // Kadang-kadang Gemini bandel, meski disuruh JSON saja, ia malah menaruh block kode 
      // markdown seperti (```json ...isi json... ```).
      // Regex ini berfungsi untuk "membersihkan" sampah markdown tersebut sehingga json murni bisa diparsing.
      final jsonStr = text
          .replaceAll(RegExp(r'^```json|```\$', multiLine: true), '')
          .trim();
          
      // Parsing json string yang sudah bersih jadi Map Object Dart
      final parsed = jsonDecode(jsonStr); 

      // PENJELASAN SIDANG:
      // Menyuntikkan hasil parsing ke dalam blueprint GeminiAnalysis.
      // Tanda '??' adalah Fallback. Jika AI lupa mengirimkan atribut (misalnya lupa mengirim 'verdict'),
      // maka sistem tidak akan crash, melainkan menggunakan nilai default (contoh: 'MEMERLUKAN_VERIFIKASI').
      return GeminiAnalysis(
        success: true,
        verdict: parsed['verdict'] ?? 'MEMERLUKAN_VERIFIKASI',
        explanation: parsed['explanation'] ?? 'Tidak ada penjelasan.',
        analysis: parsed['analysis'] ?? 'Tidak ada analisis.',
        confidence: 'tinggi',
        sources: (parsed['sources_used'] as List?)?.join(', ') ?? '',
        claim: claim,
        isFallback: false, // Menandakan bahwa ini adalah analisis sukses, bukan error message
      );
    } catch (e) {
      // Jika proses mapping json gagal (mungkin AI nge-bug balas teks biasa), kita jadikan error
      return _getErrorResponse(claim, 'Gagal memproses jawaban AI (Format tidak sesuai).');
    }
  }

  /// PENJELASAN SIDANG:
  /// Fungsi pembantu (Helper) untuk membungkus pesan error ke dalam bentuk `GeminiAnalysis`.
  /// Ini diperlukan karena UI (layar) selalu berharap menerima kembalian data berupa `GeminiAnalysis`.
  /// Dengan fungsi ini, error tetap bisa dirender di layar, misalnya dengan menaruh pesan error
  /// di atribut `explanation`.
  GeminiAnalysis _getErrorResponse(String claim, String error) {
    return GeminiAnalysis(
      success: false,
      verdict: 'MEMERLUKAN_VERIFIKASI', // Status netral saat terjadi error
      explanation: error, // Tampilkan pesan error di layar
      analysis: 'Terjadi kesalahan sistem saat menghubungi server kecerdasan buatan.',
      confidence: 'rendah',
      sources: '',
      claim: claim,
      isFallback: true, // Menandakan ke UI bahwa ini adalah balasan gagal/error
    );
  }
}

