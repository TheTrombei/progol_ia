import 'ai_analysis.dart';

enum SourceType { manualDraft, remoteUrl, importedFile }

class TextItem {
  final String id;
  final String title;
  final String content;
  final String? sourceUrl;
  final SourceType sourceType;
  final String categoryId;
  final String subtopic;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isFavorite;
  final bool isArchived;
  final AiAnalysis? analysis;

  const TextItem({
    required this.id,
    required this.title,
    required this.content,
    this.sourceUrl,
    this.sourceType = SourceType.manualDraft,
    required this.categoryId,
    required this.subtopic,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.analysis,
  });

  bool get isFromUrl => sourceUrl != null && sourceUrl!.trim().isNotEmpty;

  TextItem copyWith({
    String? id,
    String? title,
    String? content,
    String? sourceUrl,
    SourceType? sourceType,
    String? categoryId,
    String? subtopic,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isFavorite,
    bool? isArchived,
    AiAnalysis? analysis,
  }) {
    return TextItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceType: sourceType ?? this.sourceType,
      categoryId: categoryId ?? this.categoryId,
      subtopic: subtopic ?? this.subtopic,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      analysis: analysis ?? this.analysis,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'sourceUrl': sourceUrl,
        'sourceType': sourceType.index,
        'categoryId': categoryId,
        'subtopic': subtopic,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'isFavorite': isFavorite,
        'isArchived': isArchived,
        'analysis': analysis?.toJson(),
      };

  factory TextItem.fromJson(Map<String, dynamic> json) => TextItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Sin Título',
        content: json['content'] as String? ?? '',
        sourceUrl: json['sourceUrl'] as String?,
        sourceType: SourceType.values[
            (json['sourceType'] as int?)?.clamp(0, SourceType.values.length - 1) ?? 0],
        categoryId: json['categoryId'] as String? ?? 'cat_poesia',
        subtopic: json['subtopic'] as String? ?? 'General',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        lastSyncedAt: json['lastSyncedAt'] != null
            ? DateTime.tryParse(json['lastSyncedAt'] as String)
            : null,
        isFavorite: json['isFavorite'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        analysis: json['analysis'] != null
            ? AiAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
            : null,
      );
}
