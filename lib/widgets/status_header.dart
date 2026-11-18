import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiniela_model.dart';
import '../theme/app_theme.dart';

/// Barra de estado minimalista que muestra los detalles del concurso actual
class StatusHeader extends StatelessWidget {
  final Quiniela quiniela;
  final DateTime? actualizadoEn;

  const StatusHeader({
    super.key,
    required this.quiniela,
    this.actualizadoEn,
  });

  @override
  Widget build(BuildContext context) {
    // Contadores de predicciones
    int localCount = 0;
    int empateCount = 0;
    int visitaCount = 0;

    for (var p in quiniela.partidos) {
      if (p.isLocal) localCount++;
      if (p.isEmpate) empateCount++;
      if (p.isVisita) visitaCount++;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Concurso y Semana
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${quiniela.quiniela} #${quiniela.concurso}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  quiniela.semana,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Resumen de Pronósticos: L - E - V
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatChip('${localCount}L', AppTheme.predLocal),
              const SizedBox(width: 4),
              _buildStatChip('${empateCount}E', AppTheme.predEmpate),
              const SizedBox(width: 4),
              _buildStatChip('${visitaCount}V', AppTheme.predVisita),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
