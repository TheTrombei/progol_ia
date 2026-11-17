import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/text_item.dart';
import '../models/topic_category.dart';
import '../services/gemini_service.dart';
import '../services/local_nlp_engine.dart';
import '../services/storage_service.dart';
import '../services/url_fetcher_service.dart';

class ArchiveProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  List<TextItem> _items = [];
  List<TopicCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters & State
  String? _selectedCategoryId;
  String? _selectedSubtopic;
  String? _selectedMood;
  String _searchQuery = '';
  bool _onlyFavorites = false;
  TextItem? _selectedItem;

  // Getters
  List<TextItem> get items => _items;
  List<TopicCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSubtopic => _selectedSubtopic;
  String? get selectedMood => _selectedMood;
  String get searchQuery => _searchQuery;
  bool get onlyFavorites => _onlyFavorites;
  TextItem? get selectedItem => _selectedItem;

  /// Computed filtered items according to filters and search query
  List<TextItem> get filteredItems {
    return _items.where((item) {
      if (item.isArchived) return false;

      // Category filter
      if (_selectedCategoryId != null && item.categoryId != _selectedCategoryId) {
        return false;
      }

      // Subtopic filter
      if (_selectedSubtopic != null &&
          item.subtopic.toLowerCase() != _selectedSubtopic!.toLowerCase()) {
        return false;
      }

      // Mood filter
      if (_selectedMood != null) {
        final itemMood = item.analysis?.mood ?? '';
        if (!itemMood.toLowerCase().contains(_selectedMood!.toLowerCase())) {
          return false;
        }
      }

      // Favorites filter
      if (_onlyFavorites && !item.isFavorite) {
        return false;
      }

      // Search query (title, content, tags, subtopic)
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesContent = item.content.toLowerCase().contains(q);
        final matchesSubtopic = item.subtopic.toLowerCase().contains(q);
        final matchesTags = item.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesTitle && !matchesContent && !matchesSubtopic && !matchesTags) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Initialize and load stored data
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await StorageService.loadCategories();
      _items = await StorageService.loadTexts();
      if (_items.isNotEmpty) {
        _selectedItem = _items.first;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar el archivo creativo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectItem(TextItem? item) {
    _selectedItem = item;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubtopic = null; // Reset subtopic on category change
    notifyListeners();
  }

  void setSelectedSubtopic(String? subtopic) {
    _selectedSubtopic = subtopic;
    notifyListeners();
  }

  void setSelectedMood(String? mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleOnlyFavorites() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedSubtopic = null;
    _selectedMood = null;
    _searchQuery = '';
    _onlyFavorites = false;
    notifyListeners();
  }

  /// Add a new text draft
  Future<TextItem> addTextItem({
    required String title,
    required String content,
    required String categoryId,
    required String subtopic,
    List<String> tags = const [],
    String? sourceUrl,
    SourceType sourceType = SourceType.manualDraft,
  }) async {
    final now = DateTime.now();
    final newId = _uuid.v4();

    // Auto-analyze text
    final analysis = LocalNlpEngine.analyzeText(
      content,
      currentId: newId,
      allItems: _items,
    );

    final newItem = TextItem(
      id: newId,
      title: title.trim().isEmpty ? 'Sin Título' : title.trim(),
      content: content,
      sourceUrl: sourceUrl,
      sourceType: sourceType,
      categoryId: categoryId,
      subtopic: subtopic,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      lastSyncedAt: sourceUrl != null ? now : null,
      analysis: analysis,
    );

    _items.insert(0, newItem);
    _selectedItem = newItem;
    await StorageService.saveTexts(_items);
    _recalculateAllSimilarities();
    notifyListeners();
    return newItem;
  }

  /// Fetch text from a remote URL and add it to a category/subtopic
  Future<TextItem> addFromUrl({
    required String url,
    required String categoryId,
    required String subtopic,
    List<String> tags = const [],
  }) async {
    final fetched = await UrlFetcherService.fetchTextFromUrl(url);

    return await addTextItem(
      title: fetched.title,
      content: fetched.content,
      categoryId: categoryId,
      subtopic: subtopic,
      tags: tags,
      sourceUrl: fetched.finalUrl,
      sourceType: SourceType.remoteUrl,
    );
  }

  /// Refresh / re-sync content from remote URL for an existing item
  Future<void> refreshFromUrl(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = _items[index];
    if (item.sourceUrl == null || item.sourceUrl!.isEmpty) return;

    final fetched = await UrlFetcherService.fetchTextFromUrl(item.sourceUrl!);

    final updatedAnalysis = LocalNlpEngine.analyzeText(
      fetched.content,
      currentId: item.id,
      allItems: _items,
      existingGeminiAnalysis: item.analysis?.geminiAnalysis,
    );

    final updated = item.copyWith(
      content: fetched.content,
      lastSyncedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      analysis: updatedAnalysis,
    );

    _items[index] = updated;
    if (_selectedItem?.id == id) {
      _selectedItem = updated;
    }
    await StorageService.saveTexts(_items);
    notifyListeners();
  }

  /// Update an existing text item
  Future<void> updateTextItem(TextItem updatedItem) async {
    final index = _items.indexWhere((e) => e.id == updatedItem.id);
    if (index == -1) return;

    // Recalculate analysis on content edit
    final newAnalysis = LocalNlpEngine.analyzeText(
      updatedItem.content,
      currentId: updatedItem.id,
      allItems: _items,
      existingGeminiAnalysis: updatedItem.analysis?.geminiAnalysis,
    );

    final finalItem = updatedItem.copyWith(
      updatedAt: DateTime.now(),
      analysis: newAnalysis,
    );

    _items[index] = finalItem;
    if (_selectedItem?.id == finalItem.id) {
      _selectedItem = finalItem;
    }
    await StorageService.saveTexts(_items);
    notifyListeners();
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final updated = _items[index].copyWith(
      isFavorite: !_items[index].isFavorite,
    );
    _items[index] = updated;
    if (_selectedItem?.id == id) {
      _selectedItem = updated;
    }
    await StorageService.saveTexts(_items);
    notifyListeners();
  }

  /// Delete text item
  Future<void> deleteTextItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    if (_selectedItem?.id == id) {
      _selectedItem = _items.isNotEmpty ? _items.first : null;
    }
    await StorageService.saveTexts(_items);
    _recalculateAllSimilarities();
    notifyListeners();
  }

  /// Perform AI analysis with Gemini
  Future<void> runGeminiCritique(String id, String apiKey) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = _items[index];
    final category = _categories.firstWhere(
      (c) => c.id == item.categoryId,
      orElse: () => _categories.first,
    );

    final critique = await GeminiService.generateLiteraryCritique(
      apiKey: apiKey,
      title: item.title,
      content: item.content,
      category: category.name,
      subtopic: item.subtopic,
    );

    final currentAnalysis = item.analysis ??
        LocalNlpEngine.analyzeText(item.content, currentId: item.id, allItems: _items);

    final updatedAnalysis = currentAnalysis.copyWith(
      geminiAnalysis: critique,
    );

    final updatedItem = item.copyWith(analysis: updatedAnalysis);
    _items[index] = updatedItem;
    if (_selectedItem?.id == id) {
      _selectedItem = updatedItem;
    }
    await StorageService.saveTexts(_items);
    notifyListeners();
  }

  /// Recalculate similarities for all items (keeps connections fresh)
  void _recalculateAllSimilarities() {
    for (int i = 0; i < _items.length; i++) {
      final it = _items[i];
      final analysis = LocalNlpEngine.analyzeText(
        it.content,
        currentId: it.id,
        allItems: _items,
        existingGeminiAnalysis: it.analysis?.geminiAnalysis,
      );
      _items[i] = it.copyWith(analysis: analysis);
    }
  }

  /// Add a subtopic to a category
  Future<void> addSubtopicToCategory(String categoryId, String subtopicName) async {
    final clean = subtopicName.trim();
    if (clean.isEmpty) return;

    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex == -1) return;

    final cat = _categories[catIndex];
    if (!cat.subtopics.contains(clean)) {
      final updatedList = List<String>.from(cat.subtopics)..add(clean);
      _categories[catIndex] = cat.copyWith(subtopics: updatedList);
      await StorageService.saveCategories(_categories);
      notifyListeners();
    }
  }

  /// Add a new category
  Future<void> addCategory({
    required String name,
    required String iconName,
    required int colorValue,
    required List<String> subtopics,
    String description = '',
  }) async {
    final newCat = TopicCategory(
      id: 'cat_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      iconName: iconName,
      colorValue: colorValue,
      subtopics: subtopics,
      description: description,
    );
    _categories.add(newCat);
    await StorageService.saveCategories(_categories);
    notifyListeners();
  }

  /// Export complete archive as JSON
  Future<String> exportArchiveJson() async {
    return await StorageService.exportFullArchiveJson(
      texts: _items,
      categories: _categories,
    );
  }

  /// Import archive from JSON string
  Future<int> importArchiveJson(String jsonStr) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final rawCats = map['categories'] as List<dynamic>?;
    final rawTexts = map['texts'] as List<dynamic>?;

    if (rawCats != null) {
      _categories = rawCats
          .map((e) => TopicCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      await StorageService.saveCategories(_categories);
    }

    if (rawTexts != null) {
      _items = rawTexts
          .map((e) => TextItem.fromJson(e as Map<String, dynamic>))
          .toList();
      await StorageService.saveTexts(_items);
      _recalculateAllSimilarities();
    }

    if (_items.isNotEmpty) {
      _selectedItem = _items.first;
    }
    notifyListeners();
    return _items.length;
  }
}
