import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/text_item.dart';
import '../../models/topic_category.dart';
import '../../theme/artistic_palettes.dart';

class PoemCanvasEditor extends StatefulWidget {
  final TextItem item;
  final List<TopicCategory> categories;
  final ArtisticPalette palette;
  final bool isDark;
  final double fontSize;
  final Function(TextItem) onSave;
  final VoidCallback? onRefreshUrl;
  final VoidCallback? onOpenAiInspector;

  const PoemCanvasEditor({
    super.key,
    required this.item,
    required this.categories,
    required this.palette,
    required this.isDark,
    required this.fontSize,
    required this.onSave,
    this.onRefreshUrl,
    this.onOpenAiInspector,
  });

  @override
  State<PoemCanvasEditor> createState() => _PoemCanvasEditorState();
}

class _PoemCanvasEditorState extends State<PoemCanvasEditor> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late String _selectedCategoryId;
  late String _selectedSubtopic;
  late List<String> _tags;
  TextAlign _textAlign = TextAlign.left;
  bool _showLineNumbers = false;

  @override
  void initState() {
    super.initState();
    _initValues(widget.item);
  }

  @override
  void didUpdateWidget(covariant PoemCanvasEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _initValues(widget.item);
      _isEditing = false;
    }
  }

  void _initValues(TextItem item) {
    _titleController = TextEditingController(text: item.title);
    _contentController = TextEditingController(text: item.content);
    _tagInputController = TextEditingController();
    _selectedCategoryId = item.categoryId;
    _selectedSubtopic = item.subtopic;
    _tags = List.from(item.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updated = widget.item.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Sin Título'
          : _titleController.text.trim(),
      content: _contentController.text,
      categoryId: _selectedCategoryId,
      subtopic: _selectedSubtopic,
      tags: _tags,
    );
    widget.onSave(updated);
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Texto guardado y analizado con éxito ✨'),
        backgroundColor: widget.palette.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addTag(String raw) {
    final tag = raw.replaceAll('#', '').trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCat = widget.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : const TopicCategory(
              id: 'cat_poesia',
              name: 'Poesía',
              iconName: 'poem',
              colorValue: 0xFF9D4EDD,
              subtopics: ['General'],
            ),
    );

    return Column(
      children: [
        // Top Toolbar
        _buildToolbar(currentCat),

        // Content Area
        Expanded(
          child: _isEditing
              ? _buildEditorCanvas(currentCat)
              : _buildReaderCanvas(currentCat),
        ),
      ],
    );
  }

  Widget _buildToolbar(TopicCategory currentCat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0x33000000)
            : const Color(0x15000000),
        border: Border(
          bottom: BorderSide(
            color: widget.palette.primary.withAlpha(widget.isDark ? 40 : 25),
          ),
        ),
      ),
      child: Row(
        children: [
          // Mode switch (Reading / Editing)
          Container(
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0x44FFFFFF)
                  : const Color(0x22000000),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeTab(
                  icon: Icons.auto_stories,
                  label: 'Lectura',
                  active: !_isEditing,
                  onTap: () {
                    if (_isEditing) _saveChanges();
                    setState(() => _isEditing = false);
                  },
                ),
                _buildModeTab(
                  icon: Icons.edit_note,
                  label: 'Editar',
                  active: _isEditing,
                  onTap: () => setState(() => _isEditing = true),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // URL sync indicator button
          if (widget.item.isFromUrl)
            Tooltip(
              message: 'Re-sincronizar con el URL original:\n${widget.item.sourceUrl}',
              child: OutlinedButton.icon(
                onPressed: widget.onRefreshUrl,
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Actualizar URL', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.palette.secondary,
                  side: BorderSide(color: widget.palette.secondary.withAlpha(100)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

          const Spacer(),

          // Text alignment buttons (when in reader mode)
          if (!_isEditing) ...[
            IconButton(
              icon: Icon(
                _showLineNumbers
                    ? Icons.format_list_numbered
                    : Icons.format_list_numbered_rtl,
                size: 20,
                color: _showLineNumbers ? widget.palette.primary : null,
              ),
              tooltip: 'Alternar numeración de versos',
              onPressed: () {
                setState(() => _showLineNumbers = !_showLineNumbers);
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_align_left, size: 20),
              tooltip: 'Alinear a la izquierda',
              color: _textAlign == TextAlign.left ? widget.palette.primary : null,
              onPressed: () => setState(() => _textAlign = TextAlign.left),
            ),
            IconButton(
              icon: const Icon(Icons.format_align_center, size: 20),
              tooltip: 'Centrar versos (estilo lírico)',
              color: _textAlign == TextAlign.center ? widget.palette.primary : null,
              onPressed: () => setState(() => _textAlign = TextAlign.center),
            ),
          ],

          // Copy text
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copiar texto completo',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '${widget.item.title}\n\n${widget.item.content}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Texto copiado al portapapeles 📋'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          // AI Literary Inspector toggle button
          if (widget.onOpenAiInspector != null)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.palette.primary, widget.palette.accent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
              tooltip: 'Ver Análisis Literario & Musa IA',
              onPressed: widget.onOpenAiInspector,
            ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? widget.palette.primary.withAlpha(widget.isDark ? 180 : 220)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : (widget.isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reading View ---
  Widget _buildReaderCanvas(TopicCategory currentCat) {
    final rawLines = widget.item.content.split('\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: _textAlign == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              // Category & Subtopic Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: currentCat.color.withAlpha(widget.isDark ? 45 : 30),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: currentCat.color.withAlpha(90)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(currentCat.icon, size: 14, color: currentCat.color),
                        const SizedBox(width: 6),
                        Text(
                          '${currentCat.name}  •  ${widget.item.subtopic}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: currentCat.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (widget.item.analysis != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Color(widget.item.analysis!.moodColorHex)
                            .withAlpha(widget.isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Color(widget.item.analysis!.moodColorHex)
                              .withAlpha(90),
                        ),
                      ),
                      child: Text(
                        '${widget.item.analysis!.moodEmoji} ${widget.item.analysis!.mood}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(widget.item.analysis!.moodColorHex),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // Title
              SelectableText(
                widget.item.title,
                textAlign: _textAlign,
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // Divider with artistic flourish
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            widget.palette.primary.withAlpha(90),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.star_border,
                      size: 14,
                      color: widget.palette.primary.withAlpha(150),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            widget.palette.primary.withAlpha(90),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Poetic Content with optional verse numbers
              ...List.generate(rawLines.length, (index) {
                final line = rawLines[index];
                final verseNum = index + 1;
                final isEmpty = line.trim().isEmpty;

                if (isEmpty) {
                  return const SizedBox(height: 18);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (_showLineNumbers)
                        SizedBox(
                          width: 34,
                          child: Text(
                            '$verseNum',
                            style: GoogleFonts.firaCode(
                              fontSize: 11,
                              color: (widget.isDark
                                      ? Colors.white
                                      : Colors.black)
                                  .withAlpha(60),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SelectableText(
                          line,
                          textAlign: _textAlign,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                            height: 1.6,
                            color: widget.isDark
                                ? const Color(0xFFF3EFFF)
                                : const Color(0xFF1E1730),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 40),

              // Tags row
              if (widget.item.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.item.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.palette.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.palette.primary.withAlpha(60),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.palette.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Editing View ---
  Widget _buildEditorCanvas(TopicCategory currentCat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Subtopic Selectors
              Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría Principal',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: widget.categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Row(
                            children: [
                              Icon(c.icon, size: 16, color: c.color),
                              const SizedBox(width: 8),
                              Text(c.name, style: const TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategoryId = val;
                            final newCat = widget.categories.firstWhere((c) => c.id == val);
                            if (newCat.subtopics.isNotEmpty) {
                              _selectedSubtopic = newCat.subtopics.first;
                            }
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Subtopic Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: currentCat.subtopics.contains(_selectedSubtopic)
                          ? _selectedSubtopic
                          : (currentCat.subtopics.isNotEmpty
                              ? currentCat.subtopics.first
                              : 'General'),
                      decoration: const InputDecoration(
                        labelText: 'Subtema / Colección',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: currentCat.subtopics.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 13.5)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSubtopic = val);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Title input
              TextField(
                controller: _titleController,
                style: GoogleFonts.cinzel(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
                decoration: const InputDecoration(
                  labelText: 'Título de la obra / idea',
                  hintText: 'Ej. Cantar a la luna creciente...',
                ),
              ),

              const SizedBox(height: 18),

              // Content input (multiline textarea)
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 14,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: widget.fontSize,
                  height: 1.6,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Versos, Estrofas, Ideas o Prosa',
                  alignLabelWithHint: true,
                  hintText: 'Comienza a escribir con inspiración lírica...',
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'Limpiar texto',
                      onPressed: () => _contentController.clear(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Tags input & chips
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagInputController,
                      decoration: InputDecoration(
                        labelText: 'Añadir Etiqueta (#poema, #ensayo, #metafora)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addTag(_tagInputController.text),
                        ),
                      ),
                      onSubmitted: _addTag,
                    ),
                  ),
                ],
              ),

              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: widget.palette.primary.withAlpha(35),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Guardar Cambios & Analizar con IA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.palette.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
