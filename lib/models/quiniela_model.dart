/// Modelos de datos para Progol IA
class Partido {
  final int numero;
  final String local;
  final String visita;
  final String prediccion; // 'L', 'E' o 'V'

  Partido({
    required this.numero,
    required this.local,
    required this.visita,
    required this.prediccion,
  });

  bool get isLocal => prediccion.toUpperCase() == 'L';
  bool get isEmpate => prediccion.toUpperCase() == 'E';
  bool get isVisita => prediccion.toUpperCase() == 'V';

  String get prediccionLabel {
    switch (prediccion.toUpperCase()) {
      case 'L':
        return 'Local [ L ]';
      case 'E':
        return 'Empate [ E ]';
      case 'V':
        return 'Visita [ V ]';
      default:
        return '[ $prediccion ]';
    }
  }

  factory Partido.fromJson(Map<String, dynamic> json) {
    return Partido(
      numero: json['numero'] is int
          ? json['numero']
          : int.tryParse(json['numero'].toString()) ?? 1,
      local: json['local']?.toString().trim() ?? 'Local',
      visita: json['visita']?.toString().trim() ?? 'Visita',
      prediccion: json['prediccion']?.toString().trim().toUpperCase() ?? 'L',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'local': local,
      'visita': visita,
      'prediccion': prediccion,
    };
  }
}

class Quiniela {
  final String quiniela;
  final String concurso;
  final String semana;
  final List<Partido> partidos;

  Quiniela({
    required this.quiniela,
    required this.concurso,
    required this.semana,
    required this.partidos,
  });

  factory Quiniela.fromJson(Map<String, dynamic> json) {
    final rawList = json['partidos'] as List? ?? [];
    final partidosList = rawList
        .map((item) => Partido.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return Quiniela(
      quiniela: json['quiniela']?.toString() ?? 'Progol',
      concurso: json['concurso']?.toString() ?? 'Actual',
      semana: json['semana']?.toString() ?? 'Semana Oficial',
      partidos: partidosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiniela': quiniela,
      'concurso': concurso,
      'semana': semana,
      'partidos': partidos.map((p) => p.toJson()).toList(),
    };
  }
}

class ProgolDataResponse {
  final DateTime? actualizadoEn;
  final Quiniela progol;
  final Quiniela mediaSemana;

  ProgolDataResponse({
    this.actualizadoEn,
    required this.progol,
    required this.mediaSemana,
  });

  factory ProgolDataResponse.fromJson(Map<String, dynamic> json) {
    DateTime? date;
    if (json['actualizado_en'] != null) {
      date = DateTime.tryParse(json['actualizado_en'].toString());
    }

    Quiniela progolParsed;
    Quiniela mediaSemanaParsed;

    // Manejar estructura de mapa con claves 'progol' y 'media_semana'
    if (json.containsKey('progol') && json['progol'] is Map) {
      progolParsed = Quiniela.fromJson(
        Map<String, dynamic>.from(json['progol'] as Map),
      );
    } else {
      progolParsed = Quiniela(
        quiniela: 'Progol',
        concurso: 'Concurso',
        semana: 'Fin de Semana',
        partidos: [],
      );
    }

    if (json.containsKey('media_semana') && json['media_semana'] is Map) {
      mediaSemanaParsed = Quiniela.fromJson(
        Map<String, dynamic>.from(json['media_semana'] as Map),
      );
    } else {
      mediaSemanaParsed = Quiniela(
        quiniela: 'Progol Media Semana',
        concurso: 'Concurso',
        semana: 'Media Semana',
        partidos: [],
      );
    }

    return ProgolDataResponse(
      actualizadoEn: date,
      progol: progolParsed,
      mediaSemana: mediaSemanaParsed,
    );
  }
}
