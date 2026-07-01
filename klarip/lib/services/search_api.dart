// ==============================================================================
// PENJELASAN UNTUK SIDANG: SEARCH API (ORKESTRATOR)
// ==============================================================================
// Bapak/Ibu Penguji, file `search_api.dart` ini bertindak sebagai "Orkestrator" 
// atau "Dirigen" utama dalam proses verifikasi klaim di aplikasi Klarip.
// File ini menggabungkan dua layanan besar (Google Search & Gemini AI) menjadi
// satu alur kerja yang mulus (Seamless Integration).
//
// ALUR KERJA (RAG - Retrieval-Augmented Generation):
// Langkah 1 (Retrieval) : File ini pertama kali mengirim klaim ke Google Custom 
//                         Search Engine (CSE) untuk mencari artikel/berita relevan.
// Langkah 2 (Generation): Setelah berita didapat, file ini mengirim klaim 
//                         beserta teks berita tersebut ke Gemini AI untuk dianalisis.
//
// MENGAPA TIDAK PAKAI BACKEND SERVER (Node.js/PHP)?
// Aplikasi ini dirancang berarsitektur "Client-Side Processing".
// Semua proses penarikan data dan pengiriman ke AI dilakukan langsung dari HP pengguna.
// Keuntungannya: Jauh lebih hemat biaya server bagi pengembang (Serverless), dan 
// menjaga privasi data karena tidak ada pihak ketiga di tengah.
// ==============================================================================

import 'dart:async'; // Dibutuhkan untuk operasi asinkron (async/await) seperti menunggu proses download internet.
import 'dart:convert'; // Untuk encode (menyusun) dan decode (membaca) data berformat JSON.

import 'package:flutter/foundation.dart'; // Dibutuhkan untuk menggunakan fungsi debugPrint() yang aman untuk production.
import 'package:http/http.dart' as http; // Package eksternal standar Flutter untuk melakukan HTTP Request (GET/POST).

import '../models/search_result.dart'; // Blueprint/Model struktur data dari satu buah artikel berita.
import 'gemini_service.dart'; // Kelas layanan khusus untuk memanggil Google Gemini AI.

/// PENJELASAN SIDANG:
/// Kelas ini adalah sebuah Service murni. Sengaja dibuat `const` (konstan) karena
/// kelas ini tidak menyimpan data/state sama sekali (stateless). Tugasnya murni
/// hanya menerima input, memprosesnya via internet, dan mengembalikan output.
class SearchApi {
  const SearchApi();

  /// PENJELASAN SIDANG:
  /// Ini adalah Fungsi Utama (Master Function) yang dipanggil oleh halaman pencarian.
  /// Parameter yang menggunakan kata kunci `required` berarti wajib diisi (tidak boleh kosong/null).
  /// Kita memaksa agar API Key dilempar dari luar fungsi, sehingga aplikasi menjadi
  /// dinamis (user bisa mengganti API Key kapan saja dari menu Pengaturan).
  Future<Map<String, dynamic>> search(
    String query, {
    int limit = 10, // Maksimal mencari 10 artikel teratas (standar Google)
    required String geminiApiKey,
    required String cseApiKey,
    required String cseCx,
    String? customInstructions,
    // Callback (fungsi yang dititipkan) untuk melapor ke UI jika terjadi error atau berhasil.
    void Function()? onGeminiUsage,
    void Function(int statusCode, String errorMessage)? onGeminiError,
    void Function()? onCseUsage,
    void Function(int statusCode, String errorMessage)? onCseError,
  }) async {
    
    // 1. Membuat instance/perwakilan dari GeminiService dan menitipkan fungsi callback kepadanya.
    final geminiService = GeminiService(
      onUsage: onGeminiUsage,
      onError: onGeminiError,
    );

    try {
      // ======================================================================
      // PENJELASAN SIDANG: FASE 1 - PENCARIAN BERITA (GOOGLE CSE)
      // ======================================================================
      List<SearchResult> searchResults = [];
      try {
        // Menjalankan fungsi private pencarian Google
        searchResults = await _searchGoogleCSE(
          query,
          apiKey: cseApiKey,
          cx: cseCx,
        );
        debugPrint(
          '=== SEARCH API: Google CSE menemukan ${searchResults.length} artikel ===',
        );
        onCseUsage?.call(); // Lapor bahwa kuota Google Search berkurang 1 karena sukses
      } catch (cseError) {
        debugPrint(
          '=== SEARCH API: Google CSE Gagal: $cseError, lanjut ke Gemini saja ===',
        );
        // PENJELASAN SIDANG: GRACEFUL DEGRADATION
        // Jika pencarian Google gagal (misalnya karena kuota API Google habis),
        // aplikasi TIDAK BOLEH hancur (crash). 
        // Kami mengirim notifikasi error ke UI (`onCseError`), namun proses TETAP DILANJUTKAN 
        // ke Gemini AI (Fase 2) tanpa membawa konteks berita (array kosong).
        // Sehingga AI setidaknya masih bisa memberikan respon peringatan.
        if (cseError is CseApiException) {
          onCseError?.call(cseError.statusCode, cseError.message);
        }
      }

      // ======================================================================
      // PENJELASAN SIDANG: FASE 2 - ANALISIS KECERDASAN BUATAN (GEMINI)
      // ======================================================================
      // Sekarang, klaim user digabungkan dengan array `searchResults` (berita Google tadi),
      // lalu dikirimkan berbarengan ke Gemini untuk dipelajari dan dianalisis.
      final analysis = await geminiService.analyzeClaim(
        geminiApiKey,
        query,
        searchResults, // Ini adalah kunci dari metode RAG!
        customInstructions: customInstructions,
      );

      debugPrint(
        '=== SEARCH API: Mengembalikan ${searchResults.length} hasil + Analisis Gemini ===',
      );

      // Setelah dua fase berat di atas selesai, kita bungkus hasil pencarian (List)
      // dan hasil analisis (Objek) menjadi satu paket (Map) lalu dikembalikan ke halaman UI.
      return {'results': searchResults, 'gemini_analysis': analysis};
    } catch (e) {
      // Jika terjadi error sistemal yang sangat parah di fungsi ini (di luar blok try Google), 
      // kita lemparkan ke atas (throw).
      throw Exception('Gagal memproses permintaan secara keseluruhan: $e');
    }
  }

  /// PENJELASAN SIDANG:
  /// Fungsi `_searchGoogleCSE` bertugas melakukan HTTP GET ke server Google.
  /// CX (Custom Search Engine ID) adalah identitas mesin pencari buatan kita di Google Console.
  /// Melalui CX, kita sudah mengatur agar Google HANYA mencari berita dari situs-situs terpercaya 
  /// (seperti kompas, detik, antaranews) untuk mencegah sumber berita abal-abal masuk.
  Future<List<SearchResult>> _searchGoogleCSE(
    String query, {
    required String apiKey,
    required String cx,
  }) async {
    // PENJELASAN SIDANG:
    // URL Encoding sangat penting. Jika klaim user berisi spasi (" "), di URL spasi itu
    // tidak boleh ada, dan harus diubah menjadi "%20" agar server Google tidak bingung.
    final encodedQuery = Uri.encodeComponent(query);

    // PENJELASAN SIDANG:
    // Parameter URL `lr=lang_id` dan `gl=id` memaksa Google untuk memprioritaskan
    // hasil pencarian berbahasa Indonesia (lang_id) dari wilayah Indonesia (gl=id).
    // `safe=active` akan memfilter konten dewasa/berbahaya.
    final url = Uri.parse(
      'https://customsearch.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$encodedQuery&num=10&safe=active&lr=lang_id&gl=id',
    );

    final client = http.Client(); // Membuat perantara jaringan
    try {
      final response = await client.get(url); // Menunggu balasan dari server Google

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // JSON String dari Google diubah jadi Map
        final items = data['items'] as List<dynamic>? ?? [];

        // PENJELASAN SIDANG:
        // Kami memetakan ulang (Mapping) data JSON rumit dari Google menjadi objek `SearchResult`
        // yang jauh lebih rapi dan ringan.
        return items.map((item) {
          final map = item as Map<String, dynamic>;

          // === PENJELASAN SIDANG: ALGORITMA PENCARIAN THUMBNAIL ===
          // Gambar thumbnail berita di API Google itu letaknya tersembunyi di bagian metatags.
          // Kami membuat sistem "Fallback 3 Lapis" (Prioritas 1 ke Prioritas 3) untuk memastikan
          // aplikasi tetap mendapatkan gambar meskipun struktur website berita berbeda-beda.
          String? thumbnail;
          if (map['pagemap'] != null) {
            final pagemap = map['pagemap'] as Map<String, dynamic>;

            // Prioritas 1: Open Graph Image (`og:image`). Kualitas gambar terbesar dan terbaik (HD).
            if (pagemap['metatags'] != null) {
              final metas = pagemap['metatags'] as List<dynamic>;
              if (metas.isNotEmpty) {
                final meta = metas[0] as Map<String, dynamic>;
                if (meta['og:image'] != null) {
                  thumbnail = meta['og:image'] as String?;
                }
              }
            }

            // Prioritas 2: cse_image. Gambar standar cadangan bawaan dari Google API.
            if (thumbnail == null && pagemap['cse_image'] != null) {
              final images = pagemap['cse_image'] as List<dynamic>;
              if (images.isNotEmpty) {
                thumbnail = images[0]['src'] as String?;
              }
            }

            // Prioritas 3: cse_thumbnail. Gambar super kecil/buram, dipakai hanya jika terpaksa.
            if (thumbnail == null && pagemap['cse_thumbnail'] != null) {
              final thumbs = pagemap['cse_thumbnail'] as List<dynamic>;
              if (thumbs.isNotEmpty) {
                thumbnail = thumbs[0]['src'] as String?;
              }
            }
          }

          // Menyusun objek SearchResult final
          return SearchResult(
            title: map['title'] ?? 'No Title',
            link: map['link'] ?? '', 
            snippet: map['snippet'] ?? '', // Ringkasan singkat dari pencarian Google
            displayLink: map['displayLink'] ?? '', // Nama domain pendek, contoh: kompas.com
            formattedUrl: map['formattedUrl'] ?? map['link'] ?? '',
            thumbnail: thumbnail, // URL gambar hasil algoritma 3 lapis di atas
          );
        }).toList();
      } else {
        // === PENJELASAN SIDANG: ERROR HANDLING GOOGLE CSE ===
        // Seperti biasa, jika HTTP bukan 200, berarti ada error.
        String errorMsg = 'Google Search Error: Status ${response.statusCode}';

        // Berusaha mengurai pesan error asli dari Google
        try {
          final errorData = jsonDecode(response.body);
          final apiError = errorData['error']?['message'] ?? '';
          if (apiError.toString().isNotEmpty) {
            errorMsg = apiError.toString();
          }
        } catch (_) {}

        // Terjemahkan menjadi bahasa manusia
        if (response.statusCode == 429) { // HTTP 429 (Too Many Requests)
          errorMsg = 'Quota Google Search API habis. Silakan ganti API key di menu Pengaturan.';
        } else if (response.statusCode == 403) { // HTTP 403 (Forbidden)
          errorMsg = 'API key Google Search tidak valid atau diblokir. Silakan ganti di Pengaturan.';
        } else if (response.statusCode == 400) { // HTTP 400 (Bad Request)
          errorMsg = 'API key atau Search Engine ID bermasalah. Silakan periksa di Pengaturan.';
        }

        // PENJELASAN SIDANG:
        // Di sini kita TIDAK me-return pesan string, tapi secara agresif MELEMPAR (throw) 
        // sebuah Custom Exception yang sudah kita buat sendiri di bagian bawah file ini.
        // Exception ini nantinya akan "ditangkap" (catch) di blok fungsi induknya (search()).
        throw CseApiException(response.statusCode, errorMsg);
      }
    } finally {
      // PENJELASAN SIDANG: Blok 'finally' ini bersifat mutlak. Mau sukses atau gagal (error), 
      // baris kode ini pasti dijalankan. 
      // Fungsinya untuk menutup koneksi jaringan (client) agar HP pengguna tidak bocor memori (Memory Leak).
      client.close(); 
    }
  }
}

/// PENJELASAN SIDANG:
/// Ini adalah Custom Exception (Error Buatan Sendiri).
/// Kenapa kita repot-repot membuat ini alih-alih menggunakan Exception bawaan Dart?
/// Karena Exception bawaan hanya bisa membawa 1 string pesan. Sedangkan kita butuh
/// Exception yang bisa mengangkut Teks Pesan (String) DAN Kode Status HTTP (Integer) 
/// secara bersama-sama.
class CseApiException implements Exception {
  final int statusCode; // Contoh pembawaan data: 403
  final String message; // Contoh pembawaan data: "API Key Salah"

  CseApiException(this.statusCode, this.message);

  // Override fungsi print standar agar output di konsol mudah dibaca developer
  @override
  String toString() => 'CseApiException($statusCode): $message';
}
