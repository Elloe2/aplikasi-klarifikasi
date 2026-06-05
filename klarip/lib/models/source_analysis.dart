/// Model untuk data analisis sumber individual
/// Merepresentasikan analisis stance dari setiap sumber berita
class SourceAnalysis {
  /// Index/nomor urut sumber dalam list
  final int index;

  /// Stance sumber terhadap klaim: SUPPORT, OPPOSE, atau NEUTRAL
  final String stance;

  /// Penjelasan reasoning mengapa sumber memiliki stance tersebut
  final String reasoning;

  /// Quote/kutipan dari sumber yang mendukung reasoning (opsional)
  final String? quote;

  /// Constructor utama untuk membuat instance analisis sumber
  const SourceAnalysis({
    required this.index,
    required this.stance,
    required this.reasoning,
    this.quote,
  });

  /// Factory constructor untuk mengubah JSON menjadi objek model
  factory SourceAnalysis.fromJson(Map<String, dynamic> json, int index) {
    return SourceAnalysis(
      index: index,
      stance: json['stance'] as String? ?? 'NEUTRAL',
      reasoning: json['reasoning'] as String? ?? 'Tidak ada penjelasan tersedia',
      quote: json['quote'] as String?,
    );
  }

  /// Convert object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'stance': stance,
      'reasoning': reasoning,
      if (quote != null) 'quote': quote,
    };
  }

  /// Getter untuk text stance yang lebih readable
  String get stanceText {
    switch (stance) {
      case 'SUPPORT':
        return 'Mendukung';
      case 'OPPOSE':
        return 'Menentang';
      case 'NEUTRAL':
        return 'Netral';
      default:
        return stance;
    }
  }

  /// Check apakah sumber memiliki quote
  bool get hasQuote => quote != null && quote!.isNotEmpty;
}
