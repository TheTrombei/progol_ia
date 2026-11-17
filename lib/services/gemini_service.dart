import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static Future<String> generateLiteraryCritique({
    required String apiKey,
    required String title,
    required String content,
    String? category,
    String? subtopic,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Por favor configura tu clave de API de Gemini en Ajustes.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey.trim()}',
    );

    final prompt = '''
Eres un distinguido crítico literario, poeta y editor lírico. Analiza con sensibilidad artística el siguiente texto del autor.
Proporciona una respuesta elegante, inspiradora y concisa en formato Markdown con las siguientes secciones:

### 🌟 Interpretación & Resonancia Simbólica
(Breve exégesis del texto, metáforas clave y su atmósfera emocional)

### ✍️ Análisis de Estilo & Ritmo
(Cadencia de versos o prosa, sonoridad, pausas, riqueza léxica)

### 💡 Sugerencias Creativas & Ecos
(1-2 ideas de ampliación, posibles títulos alternativos o variaciones metafóricas)

### 🏷️ Subtema Sugerido
(Una categoría poética ideal para archivar esta obra)

---
DATOS DE LA OBRA:
Título: $title
Categoría actual: ${category ?? 'General'}
Subtema actual: ${subtopic ?? 'General'}

TEXTO:
$content
''';

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1000,
      }
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw Exception('Tiempo de espera agotado al conectar con Gemini.'),
        );

    if (response.statusCode != 200) {
      String err = 'Error HTTP ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded['error'] != null && decoded['error']['message'] != null) {
          err = decoded['error']['message'];
        }
      } catch (_) {}
      throw Exception('Gemini API: $err');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates != null && candidates.isNotEmpty) {
      final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
      if (parts != null && parts.isNotEmpty) {
        return parts[0]['text'] as String? ?? 'Sin respuesta';
      }
    }

    return 'No se pudo generar la crítica literaria.';
  }
}
