import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual moderno, minimalista y optimizado para Modo Oscuro por defecto.
class AppTheme {
  // Paleta de Fondos y Superficies
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF141A22);
  static const Color cardSurface = Color(0xFF1A222D);
  static const Color cardBorder = Color(0xFF263242);
  
  // Acentos y Textos
  static const Color primary = Color(0xFF10B981); // Esmeralda deportivo
  static const Color primaryLight = Color(0xFF34D399);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Colores Distintivos para Predicciones IA
  // [ L ] Local: Verde Esmeralda
  static const Color predLocal = Color(0xFF10B981);
  static const Color predLocalBg = Color(0x2410B981);
  static const Color predLocalBorder = Color(0xFF059669);

  // [ E ] Empate: Ámbar / Oro
  static const Color predEmpate = Color(0xFFF59E0B);
  static const Color predEmpateBg = Color(0x24F59E0B);
  static const Color predEmpateBorder = Color(0xFFD97706);

  // [ V ] Visita: Azul Royal / Celeste Deportivo
  static const Color predVisita = Color(0xFF3B82F6);
  static const Color predVisitaBg = Color(0x243B82F6);
  static const Color predVisitaBorder = Color(0xFF2563EB);

  static Color getPredictionColor(String pred) {
    switch (pred.toUpperCase()) {
      case 'L':
        return predLocal;
      case 'E':
        return predEmpate;
      case 'V':
        return predVisita;
      default:
        return textSecondary;
    }
  }

  static Color getPredictionBg(String pred) {
    switch (pred.toUpperCase()) {
      case 'L':
        return predLocalBg;
      case 'E':
        return predEmpateBg;
      case 'V':
        return predVisitaBg;
      default:
        return cardSurface;
    }
  }

  static Color getPredictionBorder(String pred) {
    switch (pred.toUpperCase()) {
      case 'L':
        return predLocalBorder;
      case 'E':
        return predEmpateBorder;
      case 'V':
        return predVisitaBorder;
      default:
        return cardBorder;
    }
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: predVisita,
        surface: surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: cardBorder.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: cardBorder, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      textTheme: textTheme.copyWith(
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.robotoMono(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
