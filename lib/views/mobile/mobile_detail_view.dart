import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/archive_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_decorations.dart';
import '../dialogs/settings_dialog.dart';
import '../widgets/literary_analysis_view.dart';
import '../widgets/poem_canvas_editor.dart';

class MobileDetailView extends StatefulWidget {
  final String itemId;

  const MobileDetailView({super.key, required this.itemId});

  @override
  State<MobileDetailView> createState() => _MobileDetailViewState();
}

class _MobileDetailViewState extends State<MobileDetailView> {
  int _currentTab = 0; // 0: Reading/Writing Studio, 1: AI Inspector
  bool _isLoadingGemini = false;

  void _openSettings(BuildContext context, ArchiveProvider archive, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => SettingsDialog(
        themeProvider: theme,
        archiveProvider: archive,
      ),
    );
  }

  Future<void> _runGemini(ArchiveProvider archive, ThemeProvider theme, String itemId) async {
    if (!theme.hasGeminiKey) {
      _openSettings(context, archive, theme);
      return;
    }

    setState(() => _isLoadingGemini = true);
    try {
      await archive.runGeminiCritique(itemId, theme.geminiApiKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Crítica de la Musa IA generada con éxito! ✨'),
            backgroundColor: theme.currentPalette.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con Gemini: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingGemini = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final archive = Provider.of<ArchiveProvider>(context);
    final palette = theme.currentPalette;
    final isDark = theme.isDark;

    final item = archive.items.firstWhere(
      (it) => it.id == widget.itemId,
      orElse: () => archive.items.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Favorite
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? const Color(0xFFE63946) : null,
            ),
            onPressed: () => archive.toggleFavorite(item.id),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Eliminar este escrito?'),
                  content: Text('«${item.title}» será removido del archivo.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await archive.deleteTextItem(item.id);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: AppDecorations.artisticBackground(
        palette: palette,
        isDark: isDark,
        child: _currentTab == 0
            ? PoemCanvasEditor(
                key: ValueKey(item.id),
                item: item,
                categories: archive.categories,
                palette: palette,
                isDark: isDark,
                fontSize: theme.poeticFontSize,
                onSave: (updated) => archive.updateTextItem(updated),
                onRefreshUrl: () async {
                  await archive.refreshFromUrl(item.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-sincronizado desde URL 🔄')),
                  );
                },
                onOpenAiInspector: () => setState(() => _currentTab = 1),
              )
            : LiteraryAnalysisView(
                item: item,
                palette: palette,
                isDark: isDark,
                hasGeminiKey: theme.hasGeminiKey,
                isLoadingGemini: _isLoadingGemini,
                onRunGemini: () => _runGemini(archive, theme, item.id),
                onOpenSettings: () => _openSettings(context, archive, theme),
                onSelectSimilarItem: (simId) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MobileDetailView(itemId: simId),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) => setState(() => _currentTab = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            selectedIcon: Icon(Icons.menu_book, color: Colors.white),
            label: 'Lectura & Taller',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology, color: Colors.white),
            label: 'Musa IA & Similitudes',
          ),
        ],
      ),
    );
  }
}
