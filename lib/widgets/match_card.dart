import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiniela_model.dart';
import '../theme/app_theme.dart';

/// Tarjeta minimalista y directa para un partido individual.
/// Muestra exclusivamente:
/// 1. Número de partido (#1, #2...)
/// 2. Equipo Local vs Equipo Visita
/// 3. Indicador visual destacado con la predicción [ L ], [ E ] o [ V ]
class MatchCard extends StatelessWidget {
  final Partido partido;

  const MatchCard({
    super.key,
    required this.partido,
  });

  @override
  Widget build(BuildContext context) {
    final predColor = AppTheme.getPredictionColor(partido.prediccion);
    final predBg = AppTheme.getPredictionBg(partido.prediccion);
    final predBorder = AppTheme.getPredictionBorder(partido.prediccion);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Número de Partido
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.cardBorder,
                  width: 1.0,
                ),
              ),
              child: Text(
                '#${partido.numero}',
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Equipo Local vs Equipo Visita
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Equipo Local
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 14,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: partido.isLocal ? predColor : AppTheme.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          partido.local,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: partido.isLocal ? FontWeight.w700 : FontWeight.w500,
                            color: partido.isLocal ? AppTheme.textPrimary : AppTheme.textPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Separador 'vs' sutil
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'vs',
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: partido.isEmpate ? predColor : AppTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Equipo Visita
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 14,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: partido.isVisita ? predColor : AppTheme.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          partido.visita,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: partido.isVisita ? FontWeight.w700 : FontWeight.w500,
                            color: partido.isVisita ? AppTheme.textPrimary : AppTheme.textPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Indicador Visual de Predicción sugerida por la IA [ L ], [ E ] o [ V ]
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: predBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: predBorder,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: predColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '[ ${partido.prediccion.toUpperCase()} ]',
                    style: GoogleFonts.outfit(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: predColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSubLabel(partido.prediccion),
                    style: GoogleFonts.robotoMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: predColor.withValues(alpha: 0.9),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubLabel(String pred) {
    switch (pred.toUpperCase()) {
      case 'L':
        return 'LOCAL';
      case 'E':
        return 'EMPATE';
      case 'V':
        return 'VISITA';
      default:
        return 'IA';
    }
  }
}
