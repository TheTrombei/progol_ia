import 'package:flutter/material.dart';

class TopicCategory {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final List<String> subtopics;
  final String description;

  const TopicCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.subtopics,
    this.description = '',
  });

  Color get color => Color(colorValue);

  IconData get icon {
    switch (iconName) {
      case 'poem':
        return Icons.auto_awesome;
      case 'book':
        return Icons.menu_book;
      case 'idea':
        return Icons.lightbulb_outline;
      case 'philosophy':
        return Icons.psychology;
      case 'diary':
        return Icons.history_edu;
      case 'prose':
        return Icons.edit_note;
      case 'favorites':
        return Icons.favorite;
      default:
        return Icons.folder_special;
    }
  }

  TopicCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    List<String>? subtopics,
    String? description,
  }) {
    return TopicCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      subtopics: subtopics ?? List.from(this.subtopics),
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'colorValue': colorValue,
        'subtopics': subtopics,
        'description': description,
      };

  factory TopicCategory.fromJson(Map<String, dynamic> json) => TopicCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        iconName: json['iconName'] as String? ?? 'poem',
        colorValue: json['colorValue'] as int? ?? 0xFF7B2CBF,
        subtopics: (json['subtopics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        description: json['description'] as String? ?? '',
      );

  static List<TopicCategory> get defaultCategories => [
        const TopicCategory(
          id: 'cat_poesia',
          name: 'Poesía & Versos',
          iconName: 'poem',
          colorValue: 0xFF9D4EDD,
          subtopics: [
            'Amor & Anhelo',
            'Naturaleza & Cosmos',
            'Muerte, Tiempo & Memoria',
            'Verso Libre & Experimental',
            'Sonetos & Formas Clásicas',
            'Melancolía de Medianoche',
          ],
          description: 'Estrofas, rimas, versos libres y cantos líricos',
        ),
        const TopicCategory(
          id: 'cat_prosa',
          name: 'Prosa & Microrrelatos',
          iconName: 'prose',
          colorValue: 0xFFE07A5F,
          subtopics: [
            'Microrrelatos',
            'Fragmentos de Novela',
            'Cartas Nunca Enviadas',
            'Retratos & Personajes',
            'Atmósferas Urbanas',
          ],
          description: 'Narrativa breve, cuentos y prosa poética',
        ),
        const TopicCategory(
          id: 'cat_ideas',
          name: 'Chispas & Creatividad',
          iconName: 'idea',
          colorValue: 0xFFF4A261,
          subtopics: [
            'Metáforas Huérfanas',
            'Imágenes & Visiones',
            'Títulos Tentativos',
            'Diálogos Escuchados',
            'Estructuras de Proyectos',
          ],
          description: 'Ideas fugaces, semillas literarias e intuiciones',
        ),
        const TopicCategory(
          id: 'cat_filosofia',
          name: 'Reflexión & Filosofía',
          iconName: 'philosophy',
          colorValue: 0xFF2A9D8F,
          subtopics: [
            'Existencialismo',
            'Estética del Arte',
            'Paradojas Humanas',
            'Soledad & Silencio',
            'El Tiempo & el Olvido',
          ],
          description: 'Ensayos breves, aforismos y meditaciones',
        ),
        const TopicCategory(
          id: 'cat_diario',
          name: 'Diario & Confesiones',
          iconName: 'diary',
          colorValue: 0xFFE76F51,
          subtopics: [
            'Reflexiones del Día',
            'Sueños Anotados',
            'Lugares Visitados',
            'Conversaciones Grabadas',
          ],
          description: 'Páginas íntimas y registro de vivencias',
        ),
      ];
}
