import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/archive_provider.dart';
import 'providers/theme_provider.dart';
import 'views/home_adaptive_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  final archiveProvider = ArchiveProvider();

  // Initialize both providers asynchronously
  await themeProvider.init();
  await archiveProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: archiveProvider),
      ],
      child: const CaliopeApp(),
    ),
  );
}

class CaliopeApp extends StatelessWidget {
  const CaliopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Calíope — Estudio Poético & Archivo',
      debugShowCheckedModeBanner: false,
      theme: theme.themeData,
      home: const HomeAdaptiveView(),
    );
  }
}
