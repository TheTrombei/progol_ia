import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/text_item.dart';
import '../../theme/artistic_palettes.dart';

class LiteraryAnalysisView extends StatelessWidget {
  final TextItem item;
  final ArtisticPalette palette;
  final bool isDark;
  final bool hasGeminiKey;
  final bool isLoadingGemini;
  final VoidCallback onRunGemini;
  final VoidCallback onOpenSettings;
  final Function(String itemId) onSelectSimilarItem;

  const LiteraryAnalysisView({
    super.key,
    required this.item,
    required this.palette,
    required this.isDark,
    required this.hasGeminiKey,
    this.isLoadingGemini = false,
    required this.onRunGemini,
    required this.onOpenSettings,
    required this.onSelectSimilarItem,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = item.analysis;

    if (analysis == null) {
      return Center(
        child: Text(
          'Guarda el texto para activar el análisis literario',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
      );
    }

    final moodColor = Color(analysis.moodColorHex);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.primary, palette.secondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_outlined, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Análisis Literario & IA',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Ecos temáticos, métrica y resonancia',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Mood Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  moodColor.withAlpha(isDark ? 50 : 35),
                  palette.primary.withAlpha(isDark ? 30 : 20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: moodColor.withAlpha(100), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      analysis.moodEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.mood,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Tono: ${analysis.poeticTone}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: moodColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Confidence Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: moodColor.withAlpha(isDark ? 60 : 40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(analysis.moodScore * 100).toInt()}% afinidad',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: moodColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  analysis.summary,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 15.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Metrics Grid (4 cards)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: [
              _buildMetricCard(
                icon: Icons.format_align_left,
                value: '${analysis.verseCount}',
                label: 'Versos / Líneas',
                color: palette.primary,
              ),
              _buildMetricCard(
                icon: Icons.view_headline,
                value: '${analysis.stanzaCount}',
                label: 'Estrofas',
                color: palette.secondary,
              ),
              _buildMetricCard(
                icon: Icons.short_text,
                value: '${analysis.wordCount}',
                label: 'Palabras',
                color: palette.accent,
              ),
              _buildMetricCard(
                icon: Icons.timer_outlined,
                value: '~${analysis.readingTimeSeconds}s',
                label: 'Tiempo de Recitado',
                color: const Color(0xFF2EC4B6),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Keywords / Motifs
          Text(
            'ESENCIAS & MOTIVOS CLAVE',
            style: GoogleFonts.cinzel(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.keywords.map((kw) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: palette.primary.withAlpha(isDark ? 35 : 20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: palette.primary.withAlpha(isDark ? 70 : 45),
                  ),
                ),
                child: Text(
                  '• $kw',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 26),

          // Similar Texts / Thematic Echos (User requested!)
          Row(
            children: [
              Text(
                'ECOS & SIMILITUDES TEMÁTICAS',
                style: GoogleFonts.cinzel(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Compara matemáticamente este escrito con todos los demás de tu archivo',
                child: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (analysis.similarTexts.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withAlpha(10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Aún no hay suficientes textos con afinidad temática. Escribe más poemas o notas para descubrir conexiones.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            )
          else
            ...analysis.similarTexts.map((sim) {
              final pct = (sim.score * 100).toInt();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onSelectSimilarItem(sim.id),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withAlpha(12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: palette.primary.withAlpha(isDark ? 40 : 25),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Score pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: palette.secondary.withAlpha(isDark ? 50 : 35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: palette.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sim.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              if (sim.sharedKeywords.isNotEmpty)
                                Text(
                                  'Comparte: ${sim.sharedKeywords}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 28),

          // Gemini AI Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  palette.secondary.withAlpha(isDark ? 30 : 15),
                  palette.accent.withAlpha(isDark ? 25 : 12),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: palette.secondary.withAlpha(isDark ? 70 : 40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFF4A261)),
                    const SizedBox(width: 8),
                    Text(
                      'Crítica Literaria con Gemini AI',
                      style: GoogleFonts.cinzel(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (analysis.geminiAnalysis != null &&
                    analysis.geminiAnalysis!.isNotEmpty) ...[
                  MarkdownBody(
                    data: analysis.geminiAnalysis!,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: GoogleFonts.cormorantGaramond(
                        fontSize: 15.5,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      h3: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: palette.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onRunGemini,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Volver a consultar a la Musa'),
                    ),
                  ),
                ] else ...[
                  Text(
                    hasGeminiKey
                        ? 'Solicita una lectura profunda de símbolos, métrica, rima y sugerencias poéticas de la IA.'
                        : 'Conecta tu clave gratuita de Google Gemini en Ajustes para obtener exégesis lírica e interpretación profunda.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: hasGeminiKey
                          ? (isLoadingGemini ? null : onRunGemini)
                          : onOpenSettings,
                      icon: isLoadingGemini
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(hasGeminiKey ? Icons.auto_awesome : Icons.key),
                      label: Text(
                        hasGeminiKey
                            ? (isLoadingGemini ? 'Consultando...' : 'Consultar a la Musa IA')
                            : 'Configurar Clave Gratuita de Gemini',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(isDark ? 50 : 30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
