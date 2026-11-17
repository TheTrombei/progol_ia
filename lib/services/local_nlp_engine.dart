import 'dart:math';
import '../models/ai_analysis.dart';
import '../models/text_item.dart';

class LocalNlpEngine {
  // Spanish stop words
  static const Set<String> _stopWords = {
    'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas',
    'de', 'del', 'a', 'al', 'en', 'para', 'por', 'con', 'sin', 'sobre', 'entre',
    'tras', 'hacia', 'hasta', 'desde', 'durante', 'mediante', 'contra',
    'y', 'e', 'ni', 'o', 'u', 'pero', 'mas', 'sino', 'aunque', 'porque',
    'que', 'cual', 'quien', 'cuyo', 'donde', 'cuando', 'como',
    'yo', 'tu', 'ella', 'ello', 'nosotros', 'vosotros', 'ellos', 'ellas',
    'me', 'te', 'se', 'nos', 'os', 'le', 'les', 'lo',
    'mi', 'su', 'mis', 'tus', 'sus', 'nuestro', 'vuestro',
    'este', 'esta', 'estos', 'estas', 'ese', 'esa', 'esos', 'esas', 'aquel',
    'es', 'son', 'era', 'fue', 'ha', 'han', 'hay', 'ser', 'estar', 'hacer',
    'muy', 'tan', 'menos', 'ya', 'no', 'si', 'todo', 'toda', 'todos',
    'cada', 'otro', 'otra', 'otros', 'otras', 'algo', 'nada', 'poco', 'mucho'
  };

  // Thematic lexicons for poetic mood detection
  static const Map<String, List<String>> _moodLexicons = {
    'Nostalgia & Melancolía': [
      'lluvia', 'otoño', 'recuerdo', 'memoria', 'adios', 'adiós', 'lejanía',
      'lágrima', 'lagrima', 'sombra', 'ceniza', 'tristeza', 'soledad',
      'silencio', 'ayer', 'tarde', 'invierno', 'olvido', 'nostalgia',
      'añoranza', 'pena', 'ausencia', 'pasado', 'eco', 'vacio', 'vacío',
    ],
    'Amor & Pasión': [
      'beso', 'piel', 'latido', 'fuego', 'amor', 'amante', 'ardiente',
      'cuerpo', 'caricia', 'abrazo', 'deseo', 'corazón', 'corazon', 'mirada',
      'flor', 'boca', 'ternura', 'labios', 'pasión', 'pasion', 'amada',
      'amado', 'alma', 'ardor', 'locura', 'enamorado', 'devoción',
    ],
    'Luz & Serenidad': [
      'alba', 'aurora', 'mar', 'sol', 'brisa', 'calma', 'estrella', 'cielo',
      'pureza', 'paz', 'horizonte', 'luz', 'claridad', 'rio', 'río', 'mañana',
      'vuelo', 'canto', 'cantar', 'cristal', 'angel', 'ángel', 'rocío', 'rocio',
      'azul', 'dorado', 'armonía', 'armonia', 'esperanza', 'blanco',
    ],
    'Filosofía & Misterio': [
      'abismo', 'tiempo', 'infinito', 'ser', 'alma', 'verdad', 'destino',
      'espejo', 'sueño', 'sueno', 'universo', 'nada', 'vacío', 'enigma',
      'laberinto', 'cosmos', 'existencia', 'vigilia', 'razón', 'razon',
      'duda', 'muerte', 'eterno', 'eternidad', 'origen', 'pensamiento',
    ],
    'Dolor & Sombra': [
      'herida', 'sangre', 'duelo', 'muerte', 'espina', 'llanto', 'tormenta',
      'temor', 'dolor', 'pesadumbre', 'noche', 'grito', 'oscuro', 'agonía',
      'agonia', 'desgarro', 'angustia', 'lamento', 'miedo', 'cruel', 'abismo',
    ],
    'Fuerza & Creación': [
      'alas', 'despertar', 'triunfo', 'camino', 'cumbre', 'coraje',
      'tempestad', 'creación', 'creacion', 'voluntad', 'fuego', 'renacer',
      'acero', 'victoria', 'fuerza', 'voz', 'avanzar', 'canto', 'palabra',
      'escribir', 'verso', 'fuerza', 'vencer', 'vuelo', 'furia',
    ],
    'Naturaleza & Misticismo': [
      'bosque', 'luna', 'montaña', 'montana', 'viento', 'árbol', 'arbol',
      'raíces', 'raices', 'tierra', 'niebla', 'hierba', 'hojas', 'agua',
      'sendero', 'ramas', 'nube', 'río', 'misterio', 'secreto', 'madre',
    ],
  };

  static const Map<String, String> _moodEmojis = {
    'Nostalgia & Melancolía': '🍂',
    'Amor & Pasión': '🔥',
    'Luz & Serenidad': '✨',
    'Filosofía & Misterio': '🌌',
    'Dolor & Sombra': '🥀',
    'Fuerza & Creación': '⚡',
    'Naturaleza & Misticismo': '🌿',
  };

  static const Map<String, int> _moodColors = {
    'Nostalgia & Melancolía': 0xFF6D597A,
    'Amor & Pasión': 0xFFE63946,
    'Luz & Serenidad': 0xFF48CAE4,
    'Filosofía & Misterio': 0xFF7209B7,
    'Dolor & Sombra': 0xFF3D0C11,
    'Fuerza & Creación': 0xFFF77F00,
    'Naturaleza & Misticismo': 0xFF2A9D8F,
  };

  /// Tokenizes a text into lowercased alpha words.
  static List<String> tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\wáéíóúüñ\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !_stopWords.contains(w))
        .toList();
  }

  /// Calculates term frequency map.
  static Map<String, int> getTermFrequency(List<String> tokens) {
    final tf = <String, int>{};
    for (final t in tokens) {
      tf[t] = (tf[t] ?? 0) + 1;
    }
    return tf;
  }

  /// Extracts the most representative keywords.
  static List<String> extractKeywords(Map<String, int> tf, {int max = 7}) {
    final sorted = tf.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(max).map((e) => e.key).toList();
  }

  /// Analyzes the poetic mood and tone of the text.
  static Map<String, dynamic> analyzeMood(List<String> tokens) {
    if (tokens.isEmpty) {
      return {
        'mood': 'Serenidad Creativa',
        'emoji': '✨',
        'color': 0xFF7B2CBF,
        'score': 0.5,
        'tone': 'Reflexivo',
        'summary': 'Lienzo en blanco con cadencia serena.',
      };
    }

    final scores = <String, double>{};
    for (final entry in _moodLexicons.entries) {
      double matchCount = 0;
      for (final word in tokens) {
        if (entry.value.contains(word)) {
          matchCount += 1.0;
        }
      }
      scores[entry.key] = matchCount;
    }

    // Find highest scoring mood
    String bestMood = 'Filosofía & Misterio';
    double maxScore = 0.0;
    for (final e in scores.entries) {
      if (e.value > maxScore) {
        maxScore = e.value;
        bestMood = e.key;
      }
    }

    if (maxScore == 0) {
      bestMood = 'Luz & Serenidad';
    }

    final emoji = _moodEmojis[bestMood] ?? '✨';
    final color = _moodColors[bestMood] ?? 0xFF7B2CBF;
    final normalizedConfidence = min(1.0, 0.45 + (maxScore / max(1, tokens.length)) * 3.5);

    String tone = 'Lírico';
    String summary = '';
    switch (bestMood) {
      case 'Nostalgia & Melancolía':
        tone = 'Elegíaco y evocador';
        summary = 'Atmósfera de reminiscencia, otoños internos y memoria suspendida.';
        break;
      case 'Amor & Pasión':
        tone = 'Apasionado y sensorial';
        summary = 'Fuerte vibración emotiva centrada en el contacto, el anhelo y el fuego íntimo.';
        break;
      case 'Luz & Serenidad':
        tone = 'Trascendente y luminoso';
        summary = 'Imágenes de claridad, horizontes abiertos y contemplación pacífica.';
        break;
      case 'Filosofía & Misterio':
        tone = 'Metafísico y reflexivo';
        summary = 'Exploración de enigmas temporales, la identidad y el abismo de la conciencia.';
        break;
      case 'Dolor & Sombra':
        tone = 'Dramático y sombrío';
        summary = 'Tensión poética marcada por la herida, el combate o la fragilidad humana.';
        break;
      case 'Fuerza & Creación':
        tone = 'Épico y afirmativo';
        summary = 'Impulso vital, determinación creativa y llamado a la acción trascendente.';
        break;
      case 'Naturaleza & Misticismo':
        tone = 'Panteísta y silvestre';
        summary = 'Comunión con la tierra, los ciclos cósmicos y la sabiduría de lo natural.';
        break;
    }

    return {
      'mood': bestMood,
      'emoji': emoji,
      'color': color,
      'score': normalizedConfidence,
      'tone': tone,
      'summary': summary,
    };
  }

  /// Calculates text metrics (verses, stanzas, words, characters, recitation time).
  static Map<String, int> computeMetrics(String content) {
    final rawLines = content.split('\n');
    final verses = rawLines.where((l) => l.trim().isNotEmpty).length;

    // Stanzas are blocks separated by 1 or more empty lines
    int stanzas = 0;
    bool inStanza = false;
    for (final line in rawLines) {
      if (line.trim().isNotEmpty) {
        if (!inStanza) {
          stanzas++;
          inStanza = true;
        }
      } else {
        inStanza = false;
      }
    }
    if (stanzas == 0 && verses > 0) stanzas = 1;

    final words = content
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final chars = content.length;

    // Poetry recitation speed is roughly 110-130 words per minute
    final readingSecs = max(5, ((words / 120.0) * 60).round());

    return {
      'verses': verses,
      'stanzas': stanzas,
      'words': words,
      'chars': chars,
      'readingSecs': readingSecs,
    };
  }

  /// Computes Cosine Similarity between two term-frequency maps.
  static double cosineSimilarity(
    Map<String, int> tfA,
    Map<String, int> tfB,
  ) {
    if (tfA.isEmpty || tfB.isEmpty) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (final val in tfA.values) {
      normA += val * val;
    }
    for (final val in tfB.values) {
      normB += val * val;
    }

    if (normA == 0 || normB == 0) return 0.0;

    for (final entry in tfA.entries) {
      final countB = tfB[entry.key] ?? 0;
      dotProduct += entry.value * countB;
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// Finds top similar texts from the user's archive.
  static List<SimilarTextRef> findSimilarTexts({
    required String currentId,
    required Map<String, int> currentTf,
    required List<TextItem> allItems,
    int maxResults = 4,
  }) {
    final list = <SimilarTextRef>[];

    for (final item in allItems) {
      if (item.id == currentId) continue;
      final otherTokens = tokenize(item.content);
      final otherTf = getTermFrequency(otherTokens);
      final similarity = cosineSimilarity(currentTf, otherTf);

      if (similarity > 0.08) {
        // Find shared words
        final shared = currentTf.keys
            .where((k) => otherTf.containsKey(k))
            .take(3)
            .join(', ');

        list.add(
          SimilarTextRef(
            id: item.id,
            title: item.title,
            score: double.parse(similarity.toStringAsFixed(3)),
            sharedKeywords: shared,
          ),
        );
      }
    }

    list.sort((a, b) => b.score.compareTo(a.score));
    return list.take(maxResults).toList();
  }

  /// Performs full local literary analysis for a text item.
  static AiAnalysis analyzeText(
    String content, {
    String currentId = '',
    List<TextItem> allItems = const [],
    String? existingGeminiAnalysis,
  }) {
    final tokens = tokenize(content);
    final tf = getTermFrequency(tokens);
    final keywords = extractKeywords(tf, max: 8);
    final moodInfo = analyzeMood(tokens);
    final metrics = computeMetrics(content);

    final similar = findSimilarTexts(
      currentId: currentId,
      currentTf: tf,
      allItems: allItems,
    );

    return AiAnalysis(
      mood: moodInfo['mood'] as String,
      moodEmoji: moodInfo['emoji'] as String,
      moodColorHex: moodInfo['color'] as int,
      moodScore: (moodInfo['score'] as num).toDouble(),
      poeticTone: moodInfo['tone'] as String,
      summary: moodInfo['summary'] as String,
      keywords: keywords,
      verseCount: metrics['verses'] ?? 0,
      stanzaCount: metrics['stanzas'] ?? 0,
      wordCount: metrics['words'] ?? 0,
      charCount: metrics['chars'] ?? 0,
      readingTimeSeconds: metrics['readingSecs'] ?? 0,
      similarTexts: similar,
      geminiAnalysis: existingGeminiAnalysis,
      analyzedAt: DateTime.now(),
    );
  }
}
