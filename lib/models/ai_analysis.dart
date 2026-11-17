class SimilarTextRef {
  final String id;
  final String title;
  final double score; // 0.0 to 1.0
  final String sharedKeywords;

  const SimilarTextRef({
    required this.id,
    required this.title,
    required this.score,
    this.sharedKeywords = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'score': score,
        'sharedKeywords': sharedKeywords,
      };

  factory SimilarTextRef.fromJson(Map<String, dynamic> json) => SimilarTextRef(
        id: json['id'] as String,
        title: json['title'] as String,
        score: (json['score'] as num).toDouble(),
        sharedKeywords: json['sharedKeywords'] as String? ?? '',
      );
}

class AiAnalysis {
  final String mood;
  final String moodEmoji;
  final int moodColorHex;
  final double moodScore;
  final String poeticTone;
  final String summary;
  final List<String> keywords;
  final int verseCount;
  final int stanzaCount;
  final int wordCount;
  final int charCount;
  final int readingTimeSeconds;
  final List<SimilarTextRef> similarTexts;
  final String? geminiAnalysis;
  final DateTime analyzedAt;

  const AiAnalysis({
    required this.mood,
    required this.moodEmoji,
    required this.moodColorHex,
    required this.moodScore,
    required this.poeticTone,
    required this.summary,
    required this.keywords,
    required this.verseCount,
    required this.stanzaCount,
    required this.wordCount,
    required this.charCount,
    required this.readingTimeSeconds,
    this.similarTexts = const [],
    this.geminiAnalysis,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'moodEmoji': moodEmoji,
        'moodColorHex': moodColorHex,
        'moodScore': moodScore,
        'poeticTone': poeticTone,
        'summary': summary,
        'keywords': keywords,
        'verseCount': verseCount,
        'stanzaCount': stanzaCount,
        'wordCount': wordCount,
        'charCount': charCount,
        'readingTimeSeconds': readingTimeSeconds,
        'similarTexts': similarTexts.map((e) => e.toJson()).toList(),
        'geminiAnalysis': geminiAnalysis,
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory AiAnalysis.fromJson(Map<String, dynamic> json) => AiAnalysis(
        mood: json['mood'] as String? ?? 'Serenidad Creativa',
        moodEmoji: json['moodEmoji'] as String? ?? '✨',
        moodColorHex: json['moodColorHex'] as int? ?? 0xFF7B2CBF,
        moodScore: (json['moodScore'] as num?)?.toDouble() ?? 0.8,
        poeticTone: json['poeticTone'] as String? ?? 'Lírico',
        summary: json['summary'] as String? ?? '',
        keywords: (json['keywords'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        verseCount: json['verseCount'] as int? ?? 0,
        stanzaCount: json['stanzaCount'] as int? ?? 0,
        wordCount: json['wordCount'] as int? ?? 0,
        charCount: json['charCount'] as int? ?? 0,
        readingTimeSeconds: json['readingTimeSeconds'] as int? ?? 0,
        similarTexts: (json['similarTexts'] as List<dynamic>?)
                ?.map((e) => SimilarTextRef.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        geminiAnalysis: json['geminiAnalysis'] as String?,
        analyzedAt: json['analyzedAt'] != null
            ? DateTime.tryParse(json['analyzedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  AiAnalysis copyWith({
    String? mood,
    String? moodEmoji,
    int? moodColorHex,
    double? moodScore,
    String? poeticTone,
    String? summary,
    List<String>? keywords,
    int? verseCount,
    int? stanzaCount,
    int? wordCount,
    int? charCount,
    int? readingTimeSeconds,
    List<SimilarTextRef>? similarTexts,
    String? geminiAnalysis,
    DateTime? analyzedAt,
  }) {
    return AiAnalysis(
      mood: mood ?? this.mood,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      moodColorHex: moodColorHex ?? this.moodColorHex,
      moodScore: moodScore ?? this.moodScore,
      poeticTone: poeticTone ?? this.poeticTone,
      summary: summary ?? this.summary,
      keywords: keywords ?? this.keywords,
      verseCount: verseCount ?? this.verseCount,
      stanzaCount: stanzaCount ?? this.stanzaCount,
      wordCount: wordCount ?? this.wordCount,
      charCount: charCount ?? this.charCount,
      readingTimeSeconds: readingTimeSeconds ?? this.readingTimeSeconds,
      similarTexts: similarTexts ?? this.similarTexts,
      geminiAnalysis: geminiAnalysis ?? this.geminiAnalysis,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}
