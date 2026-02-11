import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/search_result.dart';
import '../models/gemini_analysis.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  Future<GeminiAnalysis> analyzeClaim(
    String claim,
    List<SearchResult> searchResults,
  ) async {
    final apiKey = geminiApiKey;
    final url = Uri.parse('$_baseUrl?key=$apiKey');

    final prompt = _buildPrompt(claim, searchResults);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 2048},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null) {
          return _parseResponse(text, claim);
        }
      }

      return _getErrorResponse(
        claim,
        'Gagal mengambil analisis AI. Status: ${response.statusCode}',
      );
    } catch (e) {
      return _getErrorResponse(claim, 'Terjadi kesalahan jaringan: $e');
    }
  }

  String _buildPrompt(String claim, List<SearchResult> searchResults) {
    StringBuffer sourcesBuffer = StringBuffer();

    for (int i = 0; i < searchResults.length; i++) {
      final r = searchResults[i];
      final domain = r.displayLink
          .replaceFirst('www.', '')
          .replaceAll('https://', '')
          .replaceAll('http://', '')
          .split('/')[0];

      sourcesBuffer.writeln('\n--- Sumber ${i + 1} [$domain] ---');
      sourcesBuffer.writeln('Judul: ${r.title}');
      sourcesBuffer.writeln('Ringkasan: ${r.snippet}');
    }

    return '''
Analisis klaim berikut secara kritis berdasarkan data sumber berita yang diberikan.

KLAIM: "$claim"

SUMBER DATA:
${sourcesBuffer.toString()}

TUGAS ANDA:
1. Periksa apakah setiap sumber benar-benar berkaitan (RELEVAN) dengan isi klaim.
2. Identifikasi sumber yang mendukung (PRO) dan sumber yang membantah (KONTRA) terhadap klaim.
3. Bandingkan informasi antara satu sumber dengan sumber lainnya untuk melihat konsistensi data.
4. Tentukan verdict:
   - DIDUKUNG_DATA: Jika mayoritas sumber relevan mendukung klaim.
   - TIDAK_DIDUKUNG_DATA: Jika mayoritas sumber relevan membantah klaim (hoaks).
   - MEMERLUKAN_VERIFIKASI: Jika data kontradiktif atau tidak cukup bukti.

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

  GeminiAnalysis _parseResponse(String text, String claim) {
    try {
      // Clean markdown code blocks if present
      final jsonStr = text
          .replaceAll(RegExp(r'^```json|```$', multiLine: true), '')
          .trim();
      final parsed = jsonDecode(jsonStr);

      return GeminiAnalysis(
        success: true,
        verdict: parsed['verdict'] ?? 'MEMERLUKAN_VERIFIKASI',
        explanation: parsed['explanation'] ?? 'Tidak ada penjelasan.',
        analysis: parsed['analysis'] ?? 'Tidak ada analisis.',
        confidence: 'tinggi',
        sources: (parsed['sources_used'] as List?)?.join(', ') ?? '',
        claim: claim,
        isFallback: false,
      );
    } catch (e) {
      return _getErrorResponse(claim, 'Gagal memproses jawaban AI.');
    }
  }

  GeminiAnalysis _getErrorResponse(String claim, String error) {
    return GeminiAnalysis(
      success: false,
      verdict: 'MEMERLUKAN_VERIFIKASI',
      explanation: error,
      analysis: 'Terjadi kesalahan sistem saat menghubungi layanan AI.',
      confidence: 'rendah',
      sources: '',
      claim: claim,
      isFallback: true, // Treat as fallback/error
    );
  }
}
