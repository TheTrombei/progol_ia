import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/archive_provider.dart';
import '../../theme/artistic_palettes.dart';

class ManageSubtopicsDialog extends StatefulWidget {
  final ArchiveProvider archiveProvider;
  final ArtisticPalette palette;
  final bool isDark;

  const ManageSubtopicsDialog({
    super.key,
    required this.archiveProvider,
    required this.palette,
    required this.isDark,
  });

  @override
  State<ManageSubtopicsDialog> createState() => _ManageSubtopicsDialogState();
}

class _ManageSubtopicsDialogState extends State<ManageSubtopicsDialog> {
  final _newSubtopicController = TextEditingController();
  late String _selectedCatId;

  @override
  void initState() {
    super.initState();
    _selectedCatId = widget.archiveProvider.categories.isNotEmpty
        ? widget.archiveProvider.categories.first.id
        : 'cat_poesia';
  }

  @override
  void dispose() {
    _newSubtopicController.dispose();
    super.dispose();
  }

  void _addSubtopic() {
    final text = _newSubtopicController.text.trim();
    if (text.isNotEmpty) {
      widget.archiveProvider.addSubtopicToCategory(_selectedCatId, text);
      _newSubtopicController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.archiveProvider.categories;
    final cat = categories.firstWhere(
      (c) => c.id == _selectedCatId,
      orElse: () => categories.first,
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
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cat.color.withAlpha(widget.isDark ? 50 : 35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category_outlined, color: cat.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestor de Subtemas',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Organiza las ramas de tus escritos',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Selector Tabs
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final isSel = c.id == _selectedCatId;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCatId = c.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? c.color.withAlpha(widget.isDark ? 70 : 45)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? c.color : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(c.icon, size: 14, color: isSel ? c.color : Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel
                                      ? (widget.isDark ? Colors.white : Colors.black87)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Add new subtopic input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSubtopicController,
                      decoration: InputDecoration(
                        labelText: 'Nuevo subtema para ${cat.name}',
                        hintText: 'Ej. Odas al mar, Epigramas...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _addSubtopic(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addSubtopic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cat.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Añadir'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // List of current subtopics
              Expanded(
                child: ListView.builder(
                  itemCount: cat.subtopics.length,
                  itemBuilder: (context, i) {
                    final subtopic = cat.subtopics[i];
                    final count = widget.archiveProvider.items
                        .where((it) =>
                            it.categoryId == cat.id &&
                            it.subtopic.toLowerCase() == subtopic.toLowerCase())
                        .length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: (widget.isDark ? Colors.white : Colors.black).withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (widget.isDark ? Colors.white : Colors.black).withAlpha(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_border, size: 16, color: cat.color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              subtopic,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cat.color.withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count escritos',
                              style: TextStyle(fontSize: 11, color: cat.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
