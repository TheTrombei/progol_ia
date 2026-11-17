import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/text_item.dart';
import '../models/topic_category.dart';
import 'local_nlp_engine.dart';

class StorageService {
  static const String _keyTexts = 'caliope_texts_v1';
  static const String _keyCategories = 'caliope_categories_v1';
  static const String _keyPalette = 'caliope_palette_v1';
  static const String _keyIsDark = 'caliope_is_dark_v1';
  static const String _keyGeminiKey = 'caliope_gemini_key_v1';
  static const String _keyPoeticFontSize = 'caliope_font_size_v1';

  /// Load all stored texts
  static Future<List<TextItem>> loadTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTexts);
    if (jsonStr == null || jsonStr.isEmpty) {
      final samples = _getDefaultSampleItems();
      await saveTexts(samples);
      return samples;
    }

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => TextItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return _getDefaultSampleItems();
    }
  }

  /// Save all texts
  static Future<void> saveTexts(List<TextItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_keyTexts, jsonStr);
  }

  /// Load categories
  static Future<List<TopicCategory>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCategories);
    if (jsonStr == null || jsonStr.isEmpty) {
      final defaults = TopicCategory.defaultCategories;
      await saveCategories(defaults);
      return defaults;
    }

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => TopicCategory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return TopicCategory.defaultCategories;
    }
  }

  /// Save categories
  static Future<void> saveCategories(List<TopicCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(_keyCategories, jsonStr);
  }

  /// Settings getters & setters
  static Future<String> loadPaletteName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPalette) ?? 'nebulosa';
  }

  static Future<void> savePaletteName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPalette, name);
  }

  static Future<bool> loadIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDark) ?? true;
  }

  static Future<void> saveIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, isDark);
  }

  static Future<String> loadGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGeminiKey) ?? '';
  }

  static Future<void> saveGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGeminiKey, key);
  }

  static Future<double> loadPoeticFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyPoeticFontSize) ?? 19.0;
  }

  static Future<void> savePoeticFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyPoeticFontSize, size);
  }

  /// Export complete archive as JSON
  static Future<String> exportFullArchiveJson({
    required List<TextItem> texts,
    required List<TopicCategory> categories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'app': 'Calíope',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'texts': texts.map((e) => e.toJson()).toList(),
      'palette': prefs.getString(_keyPalette) ?? 'nebulosa',
      'isDark': prefs.getBool(_keyIsDark) ?? true,
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Default rich poetic sample texts
  static List<TextItem> _getDefaultSampleItems() {
    final now = DateTime.now();

    final item1 = TextItem(
      id: 'sample_poema_xx',
      title: 'Poema XX: Puedo escribir los versos más tristes',
      content: '''Puedo escribir los versos más tristes esta noche.

Escribir, por ejemplo: «La noche está estrellada,
y tiritan, azules, los astros, a lo lejos.»

El viento de la noche gira en el cielo y canta.

Puedo escribir los versos más tristes esta noche.
Yo la quise, y a veces ella también me quiso.

En las noches como ésta la tuve entre mis brazos.
La besé tantas veces bajo el cielo infinito.

Ella me quiso, a veces yo también la quería.
Cómo no haber amado sus grandes ojos fijos.

Puedo escribir los versos más tristes esta noche.
Pensar que no la tengo. Sentir que la he perdido.

Oír la noche inmensa, más inmensa sin ella.
Y el verso cae al alma como al pasto el rocío.

Qué importa que mi amor no pudiera guardarla.
La noche está estrellada y ella no está conmigo.

Eso es todo. A lo lejos alguien canta. A lo lejos.
Mi alma no se contenta con haberla perdido.''',
      categoryId: 'cat_poesia',
      subtopic: 'Amor & Anhelo',
      tags: ['Neruda', 'Nostalgia', 'Noche', 'Clásico'],
      sourceType: SourceType.manualDraft,
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 3)),
      isFavorite: true,
    );

    final item2 = TextItem(
      id: 'sample_romance_sonambulo',
      title: 'Romance Sonámbulo',
      content: '''Verde que te quiero verde.
Verde viento. Verdes ramas.
El barco sobre la mar
y el caballo en la montaña.
Con la sombra en la cintura
ella sueña en su baranda,
verde carne, pelo verde,
con ojos de fría plata.
Verde que te quiero verde.
Bajo la luna gitana,
las cosas le están mirando
y ella no puede mirarlas.

Grandes estrellas de escarcha
vienen con el pez de sombra
que abre el camino del alba.
La higuera frota su viento
con la lija de sus ramas,
y el monte, gato garduño,
eriza sus pitas agrias.
¿Pero quién vendrá? ¿Y por dónde...?
Ella sigue en su baranda,
verde carne, pelo verde,
soñando en la mar amarga.''',
      categoryId: 'cat_poesia',
      subtopic: 'Verso Libre & Experimental',
      tags: ['Lorca', 'Misterio', 'Simbolismo', 'Luna'],
      sourceType: SourceType.manualDraft,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
      isFavorite: true,
    );

    final item3 = TextItem(
      id: 'sample_volveran_golondrinas',
      title: 'Rima LIII: Volverán las oscuras golondrinas',
      content: '''Volverán las oscuras golondrinas
en tu balcón sus nidos a colgar,
y otra vez con el ala a sus cristales
jugando llamarán.

Pero aquellas que el vuelo refrenaban
tu hermosura y mi dicha a contemplar,
aquellas que aprendieron nuestro nombres...
¡esas... no volverán!

Volverán las tupidas madreselvas
de tu jardín las tapias a escalar,
y otra vez a la tarde aún más hermosas
sus flores se abrirán.

Pero aquellas cuajadas de rocío
cuyas gotas mirábamos temblar
y caer como lágrimas del día...
¡esas... no volverán!''',
      categoryId: 'cat_poesia',
      subtopic: 'Muerte, Tiempo & Memoria',
      tags: ['Bécquer', 'Tiempo', 'Rima', 'Romántico'],
      sourceType: SourceType.manualDraft,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
      isFavorite: false,
    );

    final item4 = TextItem(
      id: 'sample_faro_perdido',
      title: 'Fragmento: La vigilia del guardafaros',
      content: '''El mar no tiene memoria; por eso insiste en regresar a la orilla con la misma furia con que se despidió. 

Desde la linterna del faro, las gaviotas parecen cometas cortadas en la bruma. Hay noches en que la soledad no pesa: flota como aceite sobre el agua salada. 

Escribo para no olvidar que fui humano antes de que la sal se me metiera en la garganta. La luz gira en círculos perfectos de dieciocho segundos: dieciocho segundos de ceguera, un relámpago de revelación, dieciocho segundos de silencio. Así también funcionan los recuerdos.''',
      categoryId: 'cat_prosa',
      subtopic: 'Microrrelatos',
      tags: ['Mar', 'Faro', 'Soledad', 'Prosa'],
      sourceType: SourceType.manualDraft,
      createdAt: now.subtract(const Duration(hours: 14)),
      updatedAt: now.subtract(const Duration(hours: 14)),
      isFavorite: true,
    );

    final item5 = TextItem(
      id: 'sample_chispas_poeticas',
      title: 'Semillas & Metáforas Huérfanas de Medianoche',
      content: '''• Las campanas de la catedral son pájaros de bronce que solo cantan cuando los golpea el tiempo.
• La tinta sobre la hoja seca es como la lluvia sobre la tierra quemada: la despierta antes de ahogarla.
• Hay palabras que no se dicen para no romper el cristal del silencio; se guardan en el bolsillo como piedras de río.
• Idea para un soneto: El reflejo en el escaparate de un café cuando cae la primera nieve de noviembre.
• Título tentativo: "Geografía de las Cenizas" o "El relojero ciego".''',
      categoryId: 'cat_ideas',
      subtopic: 'Metáforas Huérfanas',
      tags: ['Chispas', 'Metáforas', 'Bocetos'],
      sourceType: SourceType.manualDraft,
      createdAt: now.subtract(const Duration(hours: 5)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      isFavorite: false,
    );

    final items = [item1, item2, item3, item4, item5];

    // Precalculate local analysis for sample items
    return items.map((item) {
      final analysis = LocalNlpEngine.analyzeText(
        item.content,
        currentId: item.id,
        allItems: items,
      );
      return item.copyWith(analysis: analysis);
    }).toList();
  }
}
