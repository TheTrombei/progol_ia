import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/topic_category.dart';
import '../../providers/archive_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_decorations.dart';
import '../dialogs/add_text_dialog.dart';
import '../dialogs/add_url_dialog.dart';
import '../dialogs/manage_subtopics_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../widgets/artistic_glass_card.dart';
import '../widgets/empty_artistic_state.dart';
import '../widgets/subtopic_chip_bar.dart';
import 'mobile_detail_view.dart';

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({super.key});

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

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

  void _showActionSheet(BuildContext context, ArchiveProvider archive, ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.isDark
          ? theme.currentPalette.surfaceDark
          : theme.currentPalette.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.currentPalette.primary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.link, color: theme.currentPalette.primary),
                ),
                title: const Text('Organizar desde URL', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('GitHub raw, Gists, Pastebin o archivo web'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openAddUrlDialog(context, archive, theme);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.currentPalette.secondary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, color: theme.currentPalette.secondary),
                ),
                title: const Text('Escribir nuevo poema', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Verso libre, ideas o prosa poética'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openAddTextDialog(context, archive, theme);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.currentPalette.accent.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bookmarks_outlined, color: theme.currentPalette.accent),
                ),
                title: const Text('Gestionar subtemas', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Crea y organiza tus colecciones temáticas'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openManageSubtopics(context, archive, theme);
                },
              ),
            ],
          ),
        ),
      ),
    );
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

    final filtered = archive.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Buscar en todo el archivo...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => archive.setSearchQuery(val),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.primary, palette.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CALÍOPE',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  archive.setSearchQuery('');
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              archive.onlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: archive.onlyFavorites ? const Color(0xFFE63946) : null,
            ),
            tooltip: 'Ver solo favoritos',
            onPressed: () => archive.toggleOnlyFavorites(),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Ajustes y Temas',
            onPressed: () => _openSettings(context, archive, theme),
          ),
        ],
      ),
      body: AppDecorations.artisticBackground(
        palette: palette,
        isDark: isDark,
        child: Column(
          children: [
            // Horizontal Categories Scroll
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                children: [
                  // "Todos" Chip
                  _buildCatChip(
                    name: 'Todos',
                    icon: Icons.all_inclusive,
                    color: palette.primary,
                    isSelected: archive.selectedCategoryId == null,
                    isDark: isDark,
                    onTap: () => archive.setSelectedCategory(null),
                  ),

                  ...archive.categories.map((cat) {
                    final isSel = archive.selectedCategoryId == cat.id;
                    return _buildCatChip(
                      name: cat.name,
                      icon: cat.icon,
                      color: cat.color,
                      isSelected: isSel,
                      isDark: isDark,
                      onTap: () => archive.setSelectedCategory(isSel ? null : cat.id),
                    );
                  }),
                ],
              ),
            ),

            // Subtopics bar (if category selected)
            if (archive.selectedCategoryId != null)
              SubtopicChipBar(
                currentCategory: currentCat,
                selectedSubtopic: archive.selectedSubtopic,
                palette: palette,
                isDark: isDark,
                onSelectSubtopic: (sub) => archive.setSelectedSubtopic(sub),
                onAddSubtopic: () => _openManageSubtopics(context, archive, theme),
              ),

            // Stream of Poems / Items
            Expanded(
              child: filtered.isEmpty
                  ? EmptyArtisticState(
                      palette: palette,
                      isDark: isDark,
                      title: 'Sin escritos aún',
                      subtitle: 'Comienza a organizar tus poemas o descarga archivos desde un URL.',
                      actionLabel: 'Organizar desde URL',
                      onAction: () => _openAddUrlDialog(context, archive, theme),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        final cat = archive.categories.firstWhere(
                          (c) => c.id == item.categoryId,
                          orElse: () => archive.categories.first,
                        );

                        return ArtisticGlassCard(
                          item: item,
                          category: cat,
                          palette: palette,
                          isDark: isDark,
                          isSelected: false,
                          onTap: () {
                            archive.selectItem(item);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MobileDetailView(itemId: item.id),
                              ),
                            );
                          },
                          onToggleFavorite: () => archive.toggleFavorite(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionSheet(context, archive, theme),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Crear u Organizar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCatChip({
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(isDark ? 210 : 230)
                : (isDark ? Colors.white : Colors.black).withAlpha(12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white : Colors.black).withAlpha(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
