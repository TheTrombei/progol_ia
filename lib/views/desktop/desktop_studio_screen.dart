import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/topic_category.dart';
import '../../providers/archive_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_decorations.dart';
import '../../theme/artistic_palettes.dart';
import '../dialogs/add_text_dialog.dart';
import '../dialogs/add_url_dialog.dart';
import '../dialogs/manage_subtopics_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../widgets/artistic_glass_card.dart';
import '../widgets/empty_artistic_state.dart';
import '../widgets/literary_analysis_view.dart';
import '../widgets/poem_canvas_editor.dart';
import '../widgets/subtopic_chip_bar.dart';

class DesktopStudioScreen extends StatefulWidget {
  const DesktopStudioScreen({super.key});

  @override
  State<DesktopStudioScreen> createState() => _DesktopStudioScreenState();
}

class _DesktopStudioScreenState extends State<DesktopStudioScreen> {
  final _searchController = TextEditingController();
  bool _showAiInspector = true;
  bool _isLoadingGemini = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddUrlDialog(BuildContext context, ArchiveProvider archive, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => AddUrlDialog(
        categories: archive.categories,
        initialCategoryId: archive.selectedCategoryId,
        initialSubtopic: archive.selectedSubtopic,
        palette: theme.currentPalette,
        isDark: theme.isDark,
        onConfirm: ({
          required String url,
          required String categoryId,
          required String subtopic,
          required List<String> tags,
        }) async {
          await archive.addFromUrl(
            url: url,
            categoryId: categoryId,
            subtopic: subtopic,
            tags: tags,
          );
        },
      ),
    );
  }

  void _openAddTextDialog(BuildContext context, ArchiveProvider archive, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => AddTextDialog(
        categories: archive.categories,
        initialCategoryId: archive.selectedCategoryId,
        initialSubtopic: archive.selectedSubtopic,
        palette: theme.currentPalette,
        isDark: theme.isDark,
        onConfirm: ({
          required String title,
          required String content,
          required String categoryId,
          required String subtopic,
          required List<String> tags,
        }) async {
          await archive.addTextItem(
            title: title,
            content: content,
            categoryId: categoryId,
            subtopic: subtopic,
            tags: tags,
          );
        },
      ),
    );
  }

  void _openManageSubtopics(BuildContext context, ArchiveProvider archive, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => ManageSubtopicsDialog(
        archiveProvider: archive,
        palette: theme.currentPalette,
        isDark: theme.isDark,
      ),
    );
  }

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

    final currentCat = archive.categories.firstWhere(
      (c) => c.id == archive.selectedCategoryId,
      orElse: () => archive.categories.isNotEmpty
          ? archive.categories.first
          : const TopicCategory(
              id: 'cat_poesia',
              name: 'General',
              iconName: 'poem',
              colorValue: 0xFF9D4EDD,
              subtopics: [],
            ),
    );

    return Scaffold(
      body: AppDecorations.artisticBackground(
        palette: palette,
        isDark: isDark,
        child: Row(
          children: [
            // 1. LEFT PANE: Categories, Subtopics, Navigation, Themes & Actions (270px)
            SizedBox(
              width: 270,
              child: _buildSidebar(context, archive, theme, palette, isDark),
            ),

            // Vertical divider
            Container(
              width: 1,
              color: palette.primary.withAlpha(isDark ? 40 : 25),
            ),

            // 2. CENTER PANE: Document Gallery & Search (380px)
            SizedBox(
              width: 380,
              child: _buildGalleryPane(context, archive, theme, palette, isDark, currentCat),
            ),

            // Vertical divider
            Container(
              width: 1,
              color: palette.primary.withAlpha(isDark ? 40 : 25),
            ),

            // 3. RIGHT PANE: Reading Canvas & Editor Studio
            Expanded(
              child: _buildStudioPane(context, archive, theme, palette, isDark),
            ),

            // 4. OPTIONAL RIGHT COLLAPSIBLE PANE: AI Inspector Panel (330px)
            if (_showAiInspector && archive.selectedItem != null) ...[
              Container(
                width: 1,
                color: palette.primary.withAlpha(isDark ? 40 : 25),
              ),
              SizedBox(
                width: 330,
                child: Container(
                  color: isDark ? const Color(0x33000000) : const Color(0x0C000000),
                  child: Column(
                    children: [
                      // Header with close button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: palette.primary.withAlpha(isDark ? 40 : 25),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.psychology, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Panel de la Musa IA',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => setState(() => _showAiInspector = false),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: LiteraryAnalysisView(
                          item: archive.selectedItem!,
                          palette: palette,
                          isDark: isDark,
                          hasGeminiKey: theme.hasGeminiKey,
                          isLoadingGemini: _isLoadingGemini,
                          onRunGemini: () =>
                              _runGemini(archive, theme, archive.selectedItem!.id),
                          onOpenSettings: () => _openSettings(context, archive, theme),
                          onSelectSimilarItem: (simId) {
                            final match =
                                archive.items.firstWhere((it) => it.id == simId);
                            archive.selectItem(match);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 1. SIDEBAR ---
  Widget _buildSidebar(
    BuildContext context,
    ArchiveProvider archive,
    ThemeProvider theme,
    ArtisticPalette palette,
    bool isDark,
  ) {
    return Container(
      color: isDark ? const Color(0x44000000) : const Color(0x0A000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.primary, palette.secondary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withAlpha(100),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CALÍOPE',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Estudio Poético & Archivo',
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                        color: palette.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Primary Action Buttons: Add from URL & New Writing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Add from URL button (prominent!)
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddUrlDialog(context, archive, theme),
                    icon: const Icon(Icons.link, size: 17),
                    label: const Text(
                      'Organizar desde URL',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // New draft button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: () => _openAddTextDialog(context, archive, theme),
                    icon: const Icon(Icons.create, size: 16),
                    label: const Text(
                      'Escribir Nuevo Poema',
                      style: TextStyle(fontSize: 12.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black87,
                      side: BorderSide(color: palette.primary.withAlpha(60)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Divider(indent: 16, endIndent: 16),

          // Category List & Subtopics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Text(
                  'COLECCIONES & TEMAS',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  tooltip: 'Gestionar subtemas',
                  onPressed: () => _openManageSubtopics(context, archive, theme),
                ),
              ],
            ),
          ),

          // All Items
          _buildCategoryTile(
            icon: Icons.all_inclusive,
            name: 'Todos los escritos',
            color: palette.secondary,
            count: archive.items.length,
            isSelected: archive.selectedCategoryId == null,
            isDark: isDark,
            palette: palette,
            onTap: () => archive.setSelectedCategory(null),
          ),

          // Favorites
          _buildCategoryTile(
            icon: Icons.favorite,
            name: 'Favoritos líricos',
            color: const Color(0xFFE63946),
            count: archive.items.where((i) => i.isFavorite).length,
            isSelected: archive.onlyFavorites,
            isDark: isDark,
            palette: palette,
            onTap: () => archive.toggleOnlyFavorites(),
          ),

          // Dynamic Categories
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: archive.categories.length,
              itemBuilder: (context, i) {
                final cat = archive.categories[i];
                final count = archive.items.where((it) => it.categoryId == cat.id).length;
                final isSelected = archive.selectedCategoryId == cat.id;

                return _buildCategoryTile(
                  icon: cat.icon,
                  name: cat.name,
                  color: cat.color,
                  count: count,
                  isSelected: isSelected,
                  isDark: isDark,
                  palette: palette,
                  onTap: () => archive.setSelectedCategory(isSelected ? null : cat.id),
                );
              },
            ),
          ),

          // Bottom Bar (Theme, Settings)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: palette.primary.withAlpha(isDark ? 30 : 20),
                ),
              ),
            ),
            child: Row(
              children: [
                // Theme emoji
                InkWell(
                  onTap: () => _openSettings(context, archive, theme),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(palette.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        palette.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isDark ? 'Modo Oscuro' : 'Modo Claro',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  tooltip: 'Ajustes, Temas y Respaldo',
                  onPressed: () => _openSettings(context, archive, theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required IconData icon,
    required String name,
    required Color color,
    required int count,
    required bool isSelected,
    required bool isDark,
    required ArtisticPalette palette,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(isDark ? 50 : 35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. GALLERY PANE ---
  Widget _buildGalleryPane(
    BuildContext context,
    ArchiveProvider archive,
    ThemeProvider theme,
    ArtisticPalette palette,
    bool isDark,
    TopicCategory currentCat,
  ) {
    final filtered = archive.filteredItems;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar versos, títulos, etiquetas...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        archive.setSearchQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: (val) => archive.setSearchQuery(val),
          ),
        ),

        // Subtopics filter chips (if a specific category is selected)
        if (archive.selectedCategoryId != null)
          SubtopicChipBar(
            currentCategory: currentCat,
            selectedSubtopic: archive.selectedSubtopic,
            palette: palette,
            isDark: isDark,
            onSelectSubtopic: (sub) => archive.setSelectedSubtopic(sub),
            onAddSubtopic: () => _openManageSubtopics(context, archive, theme),
          ),

        // Result count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            children: [
              Text(
                '${filtered.length} escritos encontrados',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const Spacer(),
              if (archive.selectedSubtopic != null)
                InkWell(
                  onTap: () => archive.setSelectedSubtopic(null),
                  child: Text(
                    'Limpiar filtro',
                    style: TextStyle(fontSize: 11, color: palette.primary),
                  ),
                ),
            ],
          ),
        ),

        // Cards list
        Expanded(
          child: filtered.isEmpty
              ? EmptyArtisticState(
                  palette: palette,
                  isDark: isDark,
                  title: 'No hay textos aquí',
                  subtitle: 'Agrega un enlace con tus archivos o escribe un nuevo poema.',
                  actionLabel: 'Añadir desde URL',
                  onAction: () => _openAddUrlDialog(context, archive, theme),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    final cat = archive.categories.firstWhere(
                      (c) => c.id == item.categoryId,
                      orElse: () => archive.categories.first,
                    );
                    final isSelected = archive.selectedItem?.id == item.id;

                    return ArtisticGlassCard(
                      item: item,
                      category: cat,
                      palette: palette,
                      isDark: isDark,
                      isSelected: isSelected,
                      onTap: () => archive.selectItem(item),
                      onToggleFavorite: () => archive.toggleFavorite(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- 3. STUDIO CANVAS PANE ---
  Widget _buildStudioPane(
    BuildContext context,
    ArchiveProvider archive,
    ThemeProvider theme,
    ArtisticPalette palette,
    bool isDark,
  ) {
    final selected = archive.selectedItem;

    if (selected == null) {
      return EmptyArtisticState(
        palette: palette,
        isDark: isDark,
        title: 'Selecciona o crea un texto',
        subtitle: 'Elige un poema del catálogo o importa archivos desde enlaces web.',
        actionLabel: 'Organizar desde URL',
        onAction: () => _openAddUrlDialog(context, archive, theme),
      );
    }

    return PoemCanvasEditor(
      key: ValueKey(selected.id),
      item: selected,
      categories: archive.categories,
      palette: palette,
      isDark: isDark,
      fontSize: theme.poeticFontSize,
      onSave: (updated) => archive.updateTextItem(updated),
      onRefreshUrl: () async {
        await archive.refreshFromUrl(selected.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenido re-sincronizado desde URL 🔄')),
        );
      },
      onOpenAiInspector: () {
        setState(() => _showAiInspector = !_showAiInspector);
      },
    );
  }
}
