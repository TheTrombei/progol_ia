import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/archive_provider.dart';
import '../providers/theme_provider.dart';
import 'desktop/desktop_studio_screen.dart';
import 'mobile/mobile_main_screen.dart';

class HomeAdaptiveView extends StatelessWidget {
  const HomeAdaptiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final archive = Provider.of<ArchiveProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    // Initial loading indicator
    if (archive.isLoading || !theme.isInitialized) {
      return Scaffold(
        backgroundColor: theme.currentPalette.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.currentPalette.primary,
                      theme.currentPalette.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.currentPalette.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Despertando a Calíope...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / PC Web threshold: 850px
        if (constraints.maxWidth >= 850) {
          return const DesktopStudioScreen();
        } else {
          return const MobileMainScreen();
        }
      },
    );
  }
}
