class SavedAnalysis {
  final int? id;
  final String title;
  final String claim;
  final String verdict;
  final String explanation;
  final String analysis; // New field
  final String confidence;
  final String userNote;
  final String sourceUrl;
  final DateTime savedAt;
  final bool isFavorite;

  SavedAnalysis({
    this.id,
    required this.title,
    required this.claim,
    required this.verdict,
    required this.explanation,
    this.analysis = '', // Default empty
    required this.confidence,
    this.userNote = '',
    this.sourceUrl = '',
    required this.savedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'claim': claim,
      'verdict': verdict,
      'explanation': explanation,
      'analysis': analysis, // Add to map
      'confidence': confidence,
      'user_note': userNote,
      'source_url': sourceUrl,
      'saved_at': savedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory SavedAnalysis.fromMap(Map<String, dynamic> map) {
    return SavedAnalysis(
      id: map['id'],
      title: map['title'],
      claim: map['claim'],
      verdict: map['verdict'],
      explanation: map['explanation'],
      analysis: map['analysis'] ?? '', // Read from map
      confidence: map['confidence'],
      userNote: map['user_note'],
      sourceUrl: map['source_url'],
      savedAt: DateTime.parse(map['saved_at']),
      isFavorite: map['is_favorite'] == 1,
    );
  }

  SavedAnalysis copyWith({
    int? id,
    String? title,
    String? claim,
    String? verdict,
    String? explanation,
    String? analysis, // Add parameter
    String? confidence,
    String? userNote,
    String? sourceUrl,
    DateTime? savedAt,
    bool? isFavorite,
  }) {
    return SavedAnalysis(
      id: id ?? this.id,
      title: title ?? this.title,
      claim: claim ?? this.claim,
      verdict: verdict ?? this.verdict,
      explanation: explanation ?? this.explanation,
      analysis: analysis ?? this.analysis, // Add to constructor
      confidence: confidence ?? this.confidence,
      userNote: userNote ?? this.userNote,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      savedAt: savedAt ?? this.savedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
