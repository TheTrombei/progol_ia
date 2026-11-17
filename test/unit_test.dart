import 'package:flutter_test/flutter_test.dart';
import 'package:poetica/models/text_item.dart';
import 'package:poetica/models/topic_category.dart';
import 'package:poetica/services/local_nlp_engine.dart';
import 'package:poetica/services/url_fetcher_service.dart';

void main() {
  group('LocalNlpEngine Tests', () {
    test('Tokenization and Stop Words filtering', () {
      final tokens = LocalNlpEngine.tokenize('El viento en la noche de otoño canta');
      expect(tokens.contains('el'), false);
      expect(tokens.contains('en'), false);
      expect(tokens.contains('la'), false);
      expect(tokens.contains('de'), false);
      expect(tokens.contains('viento'), true);
      expect(tokens.contains('noche'), true);
      expect(tokens.contains('otoño'), true);
      expect(tokens.contains('canta'), true);
    });

    test('Poetic Metrics Calculation', () {
      const poem = '''Verso uno de amor
Verso dos de sombra

Verso tres de alba
Verso cuatro de recuerdo''';

      final metrics = LocalNlpEngine.computeMetrics(poem);
      expect(metrics['verses'], 4);
      expect(metrics['stanzas'], 2);
      expect(metrics['words'], 16);
      expect(metrics['chars'], poem.length);
    });

    test('Atmospheric Mood Detection - Nostalgia', () {
      final tokens = LocalNlpEngine.tokenize('lluvia nostalgia recuerdo olvido lagrima tarde');
      final mood = LocalNlpEngine.analyzeMood(tokens);
      expect(mood['mood'], 'Nostalgia & Melancolía');
      expect(mood['emoji'], '🍂');
    });

    test('Atmospheric Mood Detection - Amor', () {
      final tokens = LocalNlpEngine.tokenize('beso fuego amor piel latido corazon labios ardiente');
      final mood = LocalNlpEngine.analyzeMood(tokens);
      expect(mood['mood'], 'Amor & Pasión');
      expect(mood['emoji'], '🔥');
    });

    test('Cosine Similarity between related poems', () {
      final textA = 'noche estrellada cielo viento mar horizonte';
      final textB = 'noche mar cielo estrella azul silencio';
      final textC = 'ferrocarril maquina motor combustible fabrica';

      final tfA = LocalNlpEngine.getTermFrequency(LocalNlpEngine.tokenize(textA));
      final tfB = LocalNlpEngine.getTermFrequency(LocalNlpEngine.tokenize(textB));
      final tfC = LocalNlpEngine.getTermFrequency(LocalNlpEngine.tokenize(textC));

      final simAB = LocalNlpEngine.cosineSimilarity(tfA, tfB);
      final simAC = LocalNlpEngine.cosineSimilarity(tfA, tfC);

      expect(simAB > simAC, true);
      expect(simAB > 0.3, true);
    });
  });

  group('UrlFetcherService Tests', () {
    test('GitHub blob to raw URL conversion', () {
      const blob = 'https://github.com/autor/antologia/blob/main/poema.txt';
      final raw = UrlFetcherService.normalizeUrl(blob);
      expect(raw, 'https://raw.githubusercontent.com/autor/antologia/main/poema.txt');
    });

    test('Pastebin to raw URL conversion', () {
      const pb = 'https://pastebin.com/xyz123';
      final raw = UrlFetcherService.normalizeUrl(pb);
      expect(raw, 'https://pastebin.com/raw/xyz123');
    });

    test('GitHub Gist standard to raw URL conversion', () {
      const gist = 'https://gist.github.com/poeta/abc987';
      final raw = UrlFetcherService.normalizeUrl(gist);
      expect(raw, 'https://gist.githubusercontent.com/poeta/abc987/raw');
    });
  });

  group('Models Serialization Tests', () {
    test('TopicCategory serialization and default categories', () {
      final defaults = TopicCategory.defaultCategories;
      expect(defaults.isNotEmpty, true);
      final cat = defaults.first;
      final json = cat.toJson();
      final restored = TopicCategory.fromJson(json);
      expect(restored.id, cat.id);
      expect(restored.name, cat.name);
      expect(restored.subtopics.length, cat.subtopics.length);
    });

    test('TextItem serialization', () {
      final now = DateTime.now();
      final item = TextItem(
        id: 'test_123',
        title: 'Soneto al crepúsculo',
        content: 'Un verso en la penumbra...',
        categoryId: 'cat_poesia',
        subtopic: 'Sonetos & Formas Clásicas',
        tags: ['soneto', 'crepusculo'],
        createdAt: now,
        updatedAt: now,
        isFavorite: true,
      );

      final json = item.toJson();
      final restored = TextItem.fromJson(json);
      expect(restored.id, 'test_123');
      expect(restored.title, 'Soneto al crepúsculo');
      expect(restored.subtopic, 'Sonetos & Formas Clásicas');
      expect(restored.isFavorite, true);
      expect(restored.tags.contains('soneto'), true);
    });
  });
}
