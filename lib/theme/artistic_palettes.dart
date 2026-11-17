import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppPaletteType {
  nebulosa,
  atardecer,
  bosqueJade,
  sakura,
  pergamino,
  medianocheOled,
}

class ArtisticPalette {
  final AppPaletteType type;
  final String name;
  final String description;
  final String emoji;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color backgroundDark;
  final Color backgroundLight;
  final Color surfaceDark;
  final Color surfaceLight;
  final Color cardGlassDark;
  final Color cardGlassLight;
  final List<Color> gradientDark;
  final List<Color> gradientLight;
  final Color textColorDark;
  final Color textColorLight;
  final Color glowColor;

  const ArtisticPalette({
    required this.type,
    required this.name,
    required this.description,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.backgroundDark,
    required this.backgroundLight,
    required this.surfaceDark,
    required this.surfaceLight,
    required this.cardGlassDark,
    required this.cardGlassLight,
    required this.gradientDark,
    required this.gradientLight,
    required this.textColorDark,
    required this.textColorLight,
    required this.glowColor,
  });

  static const List<ArtisticPalette> allPalettes = [
    // 1. Nebulosa Mística
    ArtisticPalette(
      type: AppPaletteType.nebulosa,
      name: 'Nebulosa Mística',
      description: 'Violetas astrales, índigo profundo y destellos cian',
      emoji: '🌌',
      primary: Color(0xFF9D4EDD),
      secondary: Color(0xFF48CAE4),
      accent: Color(0xFFFF007F),
      backgroundDark: Color(0xFF0D0B18),
      backgroundLight: Color(0xFFF7F5FC),
      surfaceDark: Color(0xFF161226),
      surfaceLight: Color(0xFFFFFFFF),
      cardGlassDark: Color(0x33281E46),
      cardGlassLight: Color(0xEEFFFFFF),
      gradientDark: [Color(0xFF0F0B1E), Color(0xFF1B1438), Color(0xFF0A0714)],
      gradientLight: [Color(0xFFF6F3FB), Color(0xFFEBE4F6), Color(0xFFFDFCFE)],
      textColorDark: Color(0xFFF3EFFF),
      textColorLight: Color(0xFF1E1730),
      glowColor: Color(0x559D4EDD),
    ),

    // 2. Atardecer Bohemio
    ArtisticPalette(
      type: AppPaletteType.atardecer,
      name: 'Atardecer Bohemio',
      description: 'Coral tostado, oro crepuscular y borgoña aterciopelado',
      emoji: '🌅',
      primary: Color(0xFFE07A5F),
      secondary: Color(0xFFF4A261),
      accent: Color(0xFFE76F51),
      backgroundDark: Color(0xFF1A0F12),
      backgroundLight: Color(0xFFFDF8F5),
      surfaceDark: Color(0xFF27171C),
      surfaceLight: Color(0xFFFFFFFF),
      cardGlassDark: Color(0x3D3D1F27),
      cardGlassLight: Color(0xEEFFFFFF),
      gradientDark: [Color(0xFF1C0F14), Color(0xFF2F1821), Color(0xFF14090C)],
      gradientLight: [Color(0xFFFAF3EE), Color(0xFFF5E4DA), Color(0xFFFCF8F5)],
      textColorDark: Color(0xFFFFEFEB),
      textColorLight: Color(0xFF2E1917),
      glowColor: Color(0x55E07A5F),
    ),

    // 3. Bosque de Jade
    ArtisticPalette(
      type: AppPaletteType.bosqueJade,
      name: 'Bosque de Jade',
      description: 'Esmeralda nocturno, menta luminosa y oro antiguo',
      emoji: '🌿',
      primary: Color(0xFF2EC4B6),
      secondary: Color(0xFF52B788),
      accent: Color(0xFFE9C46A),
      backgroundDark: Color(0xFF081410),
      backgroundLight: Color(0xFFF3FAF6),
      surfaceDark: Color(0xFF11241D),
      surfaceLight: Color(0xFFFFFFFF),
      cardGlassDark: Color(0x3819382D),
      cardGlassLight: Color(0xEEFFFFFF),
      gradientDark: [Color(0xFF091713), Color(0xFF122C24), Color(0xFF060F0C)],
      gradientLight: [Color(0xFFF2F9F6), Color(0xFFE0F2EB), Color(0xFFF8FCFA)],
      textColorDark: Color(0xFFEBF8F4),
      textColorLight: Color(0xFF122B21),
      glowColor: Color(0x552EC4B6),
    ),

    // 4. Sakura & Terciopelo
    ArtisticPalette(
      type: AppPaletteType.sakura,
      name: 'Sakura & Terciopelo',
      description: 'Pétalos de cerezo, rubí suave y sombra obsidiana',
      emoji: '🌸',
      primary: Color(0xFFF72585),
      secondary: Color(0xFFB5179E),
      accent: Color(0xFFFFB3C6),
      backgroundDark: Color(0xFF140D14),
      backgroundLight: Color(0xFFFFF7F9),
      surfaceDark: Color(0xFF221323),
      surfaceLight: Color(0xFFFFFFFF),
      cardGlassDark: Color(0x38351B38),
      cardGlassLight: Color(0xEEFFFFFF),
      gradientDark: [Color(0xFF170E17), Color(0xFF281329), Color(0xFF0E070F)],
      gradientLight: [Color(0xFFFFF5F8), Color(0xFFFDE5EE), Color(0xFFFFFFFF)],
      textColorDark: Color(0xFFFFEEF3),
      textColorLight: Color(0xFF301524),
      glowColor: Color(0x55F72585),
    ),

    // 5. Pergamino & Tinta
    ArtisticPalette(
      type: AppPaletteType.pergamino,
      name: 'Tinta & Pergamino',
      description: 'Sepia literario, cuero noble, bronce y papel café',
      emoji: '📜',
      primary: Color(0xFFC59B27),
      secondary: Color(0xFFA0522D),
      accent: Color(0xFF8B4513),
      backgroundDark: Color(0xFF16120F),
      backgroundLight: Color(0xFFFBF8F1),
      surfaceDark: Color(0xFF241D17),
      surfaceLight: Color(0xFFFFFDF9),
      cardGlassDark: Color(0x3B3D2F24),
      cardGlassLight: Color(0xEEFFFFFF),
      gradientDark: [Color(0xFF181310), Color(0xFF281F1A), Color(0xFF100C0A)],
      gradientLight: [Color(0xFFF7F3EA), Color(0xFFEDE3D0), Color(0xFFFAF7F0)],
      textColorDark: Color(0xFFF8F1E5),
      textColorLight: Color(0xFF2A2119),
      glowColor: Color(0x55C59B27),
    ),

    // 6. Medianoche OLED
    ArtisticPalette(
      type: AppPaletteType.medianocheOled,
      name: 'Medianoche OLED',
      description: 'Negro cósmico absoluto con luces de neón violeta y cian',
      emoji: '🌑',
      primary: Color(0xFF8338EC),
      secondary: Color(0xFF3A86FF),
      accent: Color(0xFF06D6A0),
      backgroundDark: Color(0xFF030304),
      backgroundLight: Color(0xFFF8F9FA),
      surfaceDark: Color(0xFF0E0E12),
      surfaceLight: Color(0xFFFFFFFF),
      cardGlassDark: Color(0x331F1F2C),
      cardGlassLight: Color(0xEEFFFFFF),
      gradientDark: [Color(0xFF000000), Color(0xFF0A0A10), Color(0xFF020204)],
      gradientLight: [Color(0xFFF6F8FB), Color(0xFFE9EDF5), Color(0xFFFFFFFF)],
      textColorDark: Color(0xFFF2F4F8),
      textColorLight: Color(0xFF121419),
      glowColor: Color(0x558338EC),
    ),
  ];

  static ArtisticPalette getByType(AppPaletteType type) {
    return allPalettes.firstWhere(
      (p) => p.type == type,
      orElse: () => allPalettes.first,
    );
  }

  ThemeData buildTheme({required bool isDark}) {
    final bg = isDark ? backgroundDark : backgroundLight;
    final surface = isDark ? surfaceDark : surfaceLight;
    final textCol = isDark ? textColorDark : textColorLight;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: const Color(0xFFE63946),
        onError: Colors.white,
        surface: surface,
        onSurface: textCol,
        tertiary: accent,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textCol,
          letterSpacing: 1.2,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textCol,
          letterSpacing: 1.1,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
        bodyLarge: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: textCol,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textCol.withAlpha(220),
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: primary.withAlpha(isDark ? 50 : 35),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textCol),
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textCol,
          letterSpacing: 1.0,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: primary.withAlpha(isDark ? 30 : 20),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0x22FFFFFF) : const Color(0x10000000),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withAlpha(60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
