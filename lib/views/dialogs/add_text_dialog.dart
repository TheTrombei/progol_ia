import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/topic_category.dart';
import '../../theme/artistic_palettes.dart';

class AddTextDialog extends StatefulWidget {
  final List<TopicCategory> categories;
  final String? initialCategoryId;
  final String? initialSubtopic;
  final ArtisticPalette palette;
  final bool isDark;
  final Future<void> Function({
    required String title,
    required String content,
    required String categoryId,
    required String subtopic,
    required List<String> tags,
  }) onConfirm;

  const AddTextDialog({
    super.key,
    required this.categories,
    this.initialCategoryId,
    this.initialSubtopic,
    required this.palette,
    required this.isDark,
    required this.onConfirm,
  });

  @override
  State<AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<AddTextDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  late String _selectedCategoryId;
  late String _selectedSubtopic;
  final List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : 'cat_poesia');

    final cat = widget.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => widget.categories.first,
    );

    _selectedSubtopic = widget.initialSubtopic ??
        (cat.subtopics.isNotEmpty ? cat.subtopics.first : 'General');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe al menos unos versos o ideas.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onConfirm(
        title: title.isEmpty ? 'Borrador sin título' : title,
        content: content,
        categoryId: _selectedCategoryId,
        subtopic: _selectedSubtopic,
        tags: _tags,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => widget.categories.first,
    );

    return Dialog(
      backgroundColor: widget.isDark
          ? widget.palette.surfaceDark
          : widget.palette.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: widget.palette.primary.withAlpha(70)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.palette.primary, widget.palette.accent],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.create, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo Poema / Escrito',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Organiza tus ideas, poemas y reflexiones',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Category & Subtopic
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Tema Principal',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: widget.categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(c.icon, size: 15, color: c.color),
                                const SizedBox(width: 6),
                                Text(c.name, style: const TextStyle(fontSize: 13)),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: cat.subtopics.contains(_selectedSubtopic)
                            ? _selectedSubtopic
                            : (cat.subtopics.isNotEmpty ? cat.subtopics.first : 'General'),
                        decoration: const InputDecoration(
                          labelText: 'Subtema',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: cat.subtopics.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSubtopic = val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título de la obra',
                    hintText: 'Ej. Soneto al amanecer...',
                  ),
                ),

                const SizedBox(height: 14),

                // Content
                TextField(
                  controller: _contentController,
                  maxLines: 10,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 17,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Versos o texto',
                    hintText: 'Escribe aquí...',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 14),

                // Tags
                TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    labelText: 'Añadir Etiquetas',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final t = _tagController.text.replaceAll('#', '').trim();
                        if (t.isNotEmpty && !_tags.contains(t)) {
                          setState(() {
                            _tags.add(t);
                            _tagController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),

                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text('#$tag'),
                        deleteIcon: const Icon(Icons.close, size: 12),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: const Icon(Icons.check),
                      label: Text(
                        _isLoading ? 'Guardando...' : 'Crear & Analizar',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.palette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
