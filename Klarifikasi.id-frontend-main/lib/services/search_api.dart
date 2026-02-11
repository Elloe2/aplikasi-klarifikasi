import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/search_result.dart';
import 'gemini_service.dart';

/// Kelas helper untuk melakukan pencarian fakta secara langsung (client-side).
/// Mengintegrasikan Google Custom Search Engine dan Gemini AI
/// tanpa memerlukan backend server.
class SearchApi {
  const SearchApi();

  Future<Map<String, dynamic>> search(String query, {int limit = 10}) async {
    final geminiService = GeminiService();

    try {
      // 1. Cari berita via Google Custom Search API (Direct)
      List<SearchResult> searchResults = [];
      try {
        searchResults = await _searchGoogleCSE(query);
        debugPrint(
          '=== SEARCH API: Google CSE returned ${searchResults.length} results ===',
        );
      } catch (cseError) {
        debugPrint(
          '=== SEARCH API: Google CSE failed: $cseError, continuing with Gemini only ===',
        );
      }

      // 2. Analisis hasil pencarian dengan Gemini AI (Client-side)
      final analysis = await geminiService.analyzeClaim(query, searchResults);

      debugPrint(
        '=== SEARCH API: Returning ${searchResults.length} results + Gemini analysis ===',
      );
      return {'results': searchResults, 'gemini_analysis': analysis};
    } catch (e) {
      // Error handling yang proper
      throw Exception('Gagal memproses permintaan: $e');
    }
  }

  Future<List<SearchResult>> _searchGoogleCSE(String query) async {
    final apiKey = googleCseApiKey;
    final cx = googleCseCx;
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
        // Handle error dari Google API
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Google Search Error: ${errorData['error']?['message'] ?? response.statusCode}',
        );
      }
    } finally {
      client.close();
    }
  }
}
