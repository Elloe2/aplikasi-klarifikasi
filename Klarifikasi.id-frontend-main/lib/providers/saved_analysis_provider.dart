import 'package:flutter/material.dart';
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
      final data = await _dbHelper.queryAll('saved_analyses');

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
      await _dbHelper.insert('saved_analyses', analysis.toMap());
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
}
