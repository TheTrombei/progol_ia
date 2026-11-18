import 'package:flutter_test/flutter_test.dart';
import 'package:progol_ia/models/quiniela_model.dart';
import 'package:progol_ia/theme/app_theme.dart';

void main() {
  group('Modelos y Validaciones de Progol IA', () {
    test('Partido se deserializa correctamente y detecta predicción', () {
      final json = {
        'numero': 1,
        'local': 'América',
        'visita': 'Cruz Azul',
        'prediccion': 'L',
      };

      final partido = Partido.fromJson(json);

      expect(partido.numero, 1);
      expect(partido.local, 'América');
      expect(partido.visita, 'Cruz Azul');
      expect(partido.prediccion, 'L');
      expect(partido.isLocal, true);
      expect(partido.isEmpate, false);
      expect(partido.isVisita, false);
      expect(partido.prediccionLabel, 'Local [ L ]');
    });

    test('Quiniela contiene lista de partidos esperada', () {
      final json = {
        'quiniela': 'Progol',
        'concurso': '2258',
        'semana': 'Jornada 17',
        'partidos': [
          {'numero': 1, 'local': 'América', 'visita': 'Cruz Azul', 'prediccion': 'L'},
          {'numero': 2, 'local': 'Tigres', 'visita': 'Toluca', 'prediccion': 'E'},
        ]
      };

      final quiniela = Quiniela.fromJson(json);

      expect(quiniela.quiniela, 'Progol');
      expect(quiniela.concurso, '2258');
      expect(quiniela.partidos.length, 2);
      expect(quiniela.partidos[1].prediccion, 'E');
      expect(quiniela.partidos[1].isEmpate, true);
    });

    test('Colores temáticos para predicciones L, E y V', () {
      expect(AppTheme.getPredictionColor('L'), AppTheme.predLocal);
      expect(AppTheme.getPredictionColor('E'), AppTheme.predEmpate);
      expect(AppTheme.getPredictionColor('V'), AppTheme.predVisita);
    });
  });
}
