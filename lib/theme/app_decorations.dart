import 'dart:ui';
import 'package:flutter/material.dart';
import 'artistic_palettes.dart';

class AppDecorations {
  static BoxDecoration glassBox({
    required ArtisticPalette palette,
    required bool isDark,
    double borderRadius = 20,
    double borderWidth = 1.0,
    Color? customBorderColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: isDark ? palette.cardGlassDark : palette.cardGlassLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: customBorderColor ??
            palette.primary.withAlpha(isDark ? 55 : 35),
        width: borderWidth,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(90)
                  : palette.primary.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
    );
  }

  static Widget glassContainer({
    required Widget child,
    required ArtisticPalette palette,
    required bool isDark,
    double blur = 14.0,
    double borderRadius = 20,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? customBorderColor,
    VoidCallback? onTap,
  }) {
    final box = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: glassBox(
            palette: palette,
            isDark: isDark,
            borderRadius: borderRadius,
            customBorderColor: customBorderColor,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: box,
        ),
      );
    }

    if (margin != null) {
      return Container(margin: margin, child: box);
    }
    return box;
  }

  static Widget artisticBackground({
    required Widget child,
    required ArtisticPalette palette,
    required bool isDark,
  }) {
    final colors = isDark ? palette.gradientDark : palette.gradientLight;
    return Stack(
      children: [
        // Base gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
        ),

        // Artistic ambient glowing orbs
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  palette.primary.withAlpha(isDark ? 55 : 35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  palette.secondary.withAlpha(isDark ? 45 : 30),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: 120,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  palette.accent.withAlpha(isDark ? 30 : 20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Child content
        child,
      ],
    );
  }
}
