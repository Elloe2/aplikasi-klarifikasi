import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/search_result.dart';
import 'gemini_service.dart';

/// Kelas helper untuk melakukan pencarian fakta secara langsung (client-side).
/// Mengintegrasikan Google Custom Search Engine dan Gemini AI
/// tanpa memerlukan backend server.
///
/// Sekarang menerima API key dari provider untuk kedua service:
/// - [geminiApiKey] untuk Gemini AI
/// - [cseApiKey] dan [cseCx] untuk Google Custom Search Engine
class SearchApi {
  const SearchApi();

  /// Melakukan pencarian dan analisis.
  /// [geminiApiKey] - API key untuk Gemini (dari GeminiApiProvider)
  /// [cseApiKey] - API key untuk Google CSE (dari SearchApiProvider)
  /// [cseCx] - Search Engine ID untuk Google CSE (dari SearchApiProvider)
  /// [onGeminiUsage] - Callback ketika Gemini API berhasil digunakan
  /// [onGeminiError] - Callback ketika Gemini API error
  /// [onCseUsage] - Callback ketika CSE API berhasil digunakan
  /// [onCseError] - Callback ketika CSE API error
  Future<Map<String, dynamic>> search(
    String query, {
    int limit = 10,
    required String geminiApiKey,
    required String cseApiKey,
    required String cseCx,
    void Function()? onGeminiUsage,
    void Function(int statusCode, String errorMessage)? onGeminiError,
    void Function()? onCseUsage,
    void Function(int statusCode, String errorMessage)? onCseError,
  }) async {
    final geminiService = GeminiService(
      onUsage: onGeminiUsage,
      onError: onGeminiError,
    );

    try {
      // 1. Cari berita via Google Custom Search API (Direct)
      List<SearchResult> searchResults = [];
      try {
        searchResults = await _searchGoogleCSE(
          query,
          apiKey: cseApiKey,
          cx: cseCx,
        );
        debugPrint(
          '=== SEARCH API: Google CSE returned ${searchResults.length} results ===',
        );
        // Record successful CSE usage
        onCseUsage?.call();
      } catch (cseError) {
        debugPrint(
          '=== SEARCH API: Google CSE failed: $cseError, continuing with Gemini only ===',
        );
        // Rethrow jika error berkaitan API key agar bisa ditangkap di caller
        if (cseError is CseApiException) {
          onCseError?.call(cseError.statusCode, cseError.message);
        }
      }

      // 2. Analisis hasil pencarian dengan Gemini AI (Client-side)
      final analysis = await geminiService.analyzeClaim(
        geminiApiKey,
        query,
        searchResults,
      );

      debugPrint(
        '=== SEARCH API: Returning ${searchResults.length} results + Gemini analysis ===',
      );
      return {'results': searchResults, 'gemini_analysis': analysis};
    } catch (e) {
      // Error handling yang proper
      throw Exception('Gagal memproses permintaan: $e');
    }
  }

  Future<List<SearchResult>> _searchGoogleCSE(
    String query, {
    required String apiKey,
    required String cx,
  }) async {
    final encodedQuery = Uri.encodeComponent(query);

    // URL Google Custom Search JSON API
    final url = Uri.parse(
      'https://customsearch.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$encodedQuery&num=10&safe=active&lr=lang_id&gl=id',
    );

    final client = http.Client();
    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        return items.map((item) {
          final map = item as Map<String, dynamic>;

          // Extract thumbnail from pagemap if available
          String? thumbnail;
          if (map['pagemap'] != null) {
            final pagemap = map['pagemap'] as Map<String, dynamic>;

            // Priority 1: Open Graph Image (High Quality)
            if (pagemap['metatags'] != null) {
              final metas = pagemap['metatags'] as List<dynamic>;
              if (metas.isNotEmpty) {
                final meta = metas[0] as Map<String, dynamic>;
                if (meta['og:image'] != null) {
                  thumbnail = meta['og:image'] as String?;
                }
              }
            }

            // Priority 2: CSE Image (Standard)
            if (thumbnail == null && pagemap['cse_image'] != null) {
              final images = pagemap['cse_image'] as List<dynamic>;
              if (images.isNotEmpty) {
                thumbnail = images[0]['src'] as String?;
              }
            }

            // Priority 3: CSE Thumbnail (Low Quality Fallback)
            if (thumbnail == null && pagemap['cse_thumbnail'] != null) {
              final thumbs = pagemap['cse_thumbnail'] as List<dynamic>;
              if (thumbs.isNotEmpty) {
                thumbnail = thumbs[0]['src'] as String?;
              }
            }
          }

          return SearchResult(
            title: map['title'] ?? 'No Title',
            link: map['link'] ?? '',
            snippet: map['snippet'] ?? '',
            displayLink: map['displayLink'] ?? '',
            formattedUrl: map['formattedUrl'] ?? map['link'] ?? '',
            thumbnail: thumbnail,
          );
        }).toList();
      } else {
        // === DETEKSI ERROR API KEY ===
        String errorMsg = 'Google Search Error: Status ${response.statusCode}';

        try {
          final errorData = jsonDecode(response.body);
          final apiError = errorData['error']?['message'] ?? '';
          if (apiError.toString().isNotEmpty) {
            errorMsg = apiError.toString();
          }
        } catch (_) {}

        // Buat pesan user-friendly berdasarkan status code
        if (response.statusCode == 429) {
          errorMsg =
              'Quota Google Search API habis. Silakan ganti API key di menu Pengaturan.';
        } else if (response.statusCode == 403) {
          errorMsg =
              'API key Google Search tidak valid atau diblokir. Silakan ganti di Pengaturan.';
        } else if (response.statusCode == 400) {
          errorMsg =
              'API key atau Search Engine ID bermasalah. Silakan periksa di Pengaturan.';
        }

        // Throw custom exception dengan status code
        throw CseApiException(response.statusCode, errorMsg);
      }
    } finally {
      client.close();
    }
  }
}

/// Custom exception untuk CSE API errors agar bisa membawa status code.
class CseApiException implements Exception {
  final int statusCode;
  final String message;

  CseApiException(this.statusCode, this.message);

  @override
  String toString() => 'CseApiException($statusCode): $message';
}
