import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/artistic_palettes.dart';

class EmptyArtisticState extends StatelessWidget {
  final ArtisticPalette palette;
  final bool isDark;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyArtisticState({
    super.key,
    required this.palette,
    required this.isDark,
    this.title = 'El pergamino está en blanco',
    this.subtitle = '«La poesía es el eco de la melodía del universo en el corazón de los humanos.»',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing artistic feather/star orb
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    palette.primary.withAlpha(isDark ? 90 : 50),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 42,
                color: palette.primary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.4,
                ),
              ),
            ),

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
