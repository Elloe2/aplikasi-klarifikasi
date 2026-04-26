import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_analysis.dart';
import '../services/database_helper.dart';

class SavedAnalysisProvider extends ChangeNotifier {
  List<SavedAnalysis> _analyses = [];
  bool _isLoading = false;

  List<SavedAnalysis> get analyses => _analyses;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadAnalyses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';

      final data = await _dbHelper.queryAll(
        'saved_analyses',
        where: 'user_email = ?',
        whereArgs: [userEmail],
      );

      _analyses = data.map((e) => SavedAnalysis.fromMap(e)).toList();
      _sortAnalyses();
    } catch (e) {
      debugPrint('Error loading analyses: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _sortAnalyses() {
    _analyses.sort((a, b) {
      // 1. Sort by Favorite (True first)
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      // 2. Sort by Date (Newest first)
      return b.savedAt.compareTo(a.savedAt);
    });
  }

  Future<void> addAnalysis(SavedAnalysis analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';
      
      final newAnalysis = analysis.copyWith(userEmail: userEmail);
      await _dbHelper.insert('saved_analyses', newAnalysis.toMap());
      await loadAnalyses(); // Reload list
    } catch (e) {
      debugPrint('Error adding analysis: $e');
    }
  }

  Future<void> deleteAnalysis(int id) async {
    try {
      await _dbHelper.delete('saved_analyses', 'id = ?', [id]);
      _analyses.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting analysis: $e');
    }
  }

  Future<void> updateNote(int id, String newNote) async {
    try {
      await _dbHelper.update(
        'saved_analyses',
        {'user_note': newNote},
        'id = ?',
        [id],
      );
      final index = _analyses.indexWhere((element) => element.id == id);
      if (index != -1) {
        _analyses[index] = _analyses[index].copyWith(userNote: newNote);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  Future<void> toggleFavorite(int id) async {
    final index = _analyses.indexWhere((element) => element.id == id);
    if (index != -1) {
      final newValue = !_analyses[index].isFavorite;
      final updatedItem = _analyses[index].copyWith(isFavorite: newValue);

      // Optimistic update
      _analyses[index] = updatedItem;
      _sortAnalyses(); // Re-sort immediately
      notifyListeners();

      try {
        await _dbHelper.update(
          'saved_analyses',
          {'is_favorite': newValue ? 1 : 0},
          'id = ?',
          [id],
        );
      } catch (e) {
        debugPrint('Error toggling favorite: $e');
        // Rollback if needed (optional but recommended)
      }
    }
  }

  // ==========================================================================
  // EXPORT / IMPORT HISTORY
  // ==========================================================================

  /// Mengekspor seluruh history sebagai JSON string.
  /// Format: { "app": "klarip", "version": "2.3.0",
  ///           "exported_at": "...", "total": N, "data": [...] }
  String exportToJson() {
    final exportData = {
      'app': 'klarip',
      'version': '2.4.0',
      'exported_at': DateTime.now().toIso8601String(),
      'total': _analyses.length,
      'data': _analyses.map((a) {
        final map = a.toMap();
        map.remove('id'); // Hapus id lokal agar tidak bentrok saat import
        return map;
      }).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Mengimpor history dari JSON string.
  /// Mengembalikan jumlah item yang berhasil diimpor (skip duplikat).
  Future<int> importFromJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        throw FormatException('Format file tidak valid');
      }

      // Validasi format file
      if (decoded['app'] != 'klarip') {
        throw FormatException('File ini bukan backup Klarip');
      }

      final dataList = decoded['data'] as List<dynamic>?;
      if (dataList == null || dataList.isEmpty) {
        return 0;
      }

      // Load existing analyses untuk pengecekan duplikat
      await loadAnalyses();
      final existingClaims = _analyses.map((a) => a.claim.trim()).toSet();

      int importedCount = 0;

      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email') ?? '';

      for (final item in dataList) {
        try {
          final map = item as Map<String, dynamic>;
          final analysis = SavedAnalysis.fromMap(map).copyWith(userEmail: userEmail);

          // Skip duplikat berdasarkan claim text
          if (existingClaims.contains(analysis.claim.trim())) {
            debugPrint('Skip duplikat: ${analysis.claim.substring(0, 30)}...');
            continue;
          }

          // Insert ke database tanpa id (auto-increment)
          final insertMap = analysis.toMap();
          insertMap.remove('id');
          await _dbHelper.insert('saved_analyses', insertMap);

          existingClaims.add(analysis.claim.trim());
          importedCount++;
        } catch (e) {
          debugPrint('Error importing item: $e');
          // Skip item yang bermasalah, lanjutkan ke item berikutnya
        }
      }

      // Reload setelah import selesai
      await loadAnalyses();
      return importedCount;
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }
}
