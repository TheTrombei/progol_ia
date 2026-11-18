import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/progol_service.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar barra de estado y navegación transparente para Modo Oscuro nativo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final progolService = ProgolService();

  runApp(ProgolIaApp(progolService: progolService));
}

class ProgolIaApp extends StatelessWidget {
  final ProgolService progolService;

  const ProgolIaApp({
    super.key,
    required this.progolService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Progol IA',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Modo Oscuro por defecto
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeScreen(progolService: progolService),
    );
  }
}
