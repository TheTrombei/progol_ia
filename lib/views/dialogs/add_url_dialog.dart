import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/topic_category.dart';
import '../../theme/artistic_palettes.dart';

class AddUrlDialog extends StatefulWidget {
  final List<TopicCategory> categories;
  final String? initialCategoryId;
  final String? initialSubtopic;
  final ArtisticPalette palette;
  final bool isDark;
  final Future<void> Function({
    required String url,
    required String categoryId,
    required String subtopic,
    required List<String> tags,
  }) onConfirm;

  const AddUrlDialog({
    super.key,
    required this.categories,
    this.initialCategoryId,
    this.initialSubtopic,
    required this.palette,
    required this.isDark,
    required this.onConfirm,
  });

  @override
  State<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends State<AddUrlDialog> {
  final _urlController = TextEditingController();
  final _tagController = TextEditingController();
  final _newSubtopicController = TextEditingController();

  late String _selectedCategoryId;
  late String _selectedSubtopic;
  final List<String> _tags = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showCustomSubtopicInput = false;

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
    _urlController.dispose();
    _tagController.dispose();
    _newSubtopicController.dispose();
    super.dispose();
  }

  Future<void> _pasteClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
      });
    }
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un enlace o URL válido.');
      return;
    }

    final subtopic = _showCustomSubtopicInput &&
            _newSubtopicController.text.trim().isNotEmpty
        ? _newSubtopicController.text.trim()
        : _selectedSubtopic;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        url: url,
        categoryId: _selectedCategoryId,
        subtopic: subtopic,
        tags: _tags,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
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
        constraints: const BoxConstraints(maxWidth: 540),
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
                          colors: [widget.palette.primary, widget.palette.secondary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.link, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organizar desde URL',
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'GitHub raw, Gists, Pastebin o archivo web',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // URL Input Field
                TextField(
                  controller: _urlController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'URL del archivo de texto',
                    hintText: 'https://raw.githubusercontent.com/...',
                    prefixIcon: const Icon(Icons.public, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste),
                      tooltip: 'Pegar del portapapeles',
                      onPressed: _pasteClipboard,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Hint chips
                Wrap(
                  spacing: 6,
                  children: [
                    _buildHintChip('GitHub Raw / Blobs'),
                    _buildHintChip('GitHub Gists'),
                    _buildHintChip('Pastebin'),
                    _buildHintChip('Texto .txt / .md'),
                  ],
                ),

                const SizedBox(height: 18),

                // Category & Subtopic Selection
                Row(
                  children: [
                    // Category
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

                    // Subtopic
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
                          if (val != null) {
                            setState(() => _selectedSubtopic = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // Custom Subtopic Toggle
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCustomSubtopicInput = !_showCustomSubtopicInput;
                      });
                    },
                    icon: Icon(
                      _showCustomSubtopicInput ? Icons.remove : Icons.add,
                      size: 14,
                    ),
                    label: Text(
                      _showCustomSubtopicInput
                          ? 'Usar subtema existente'
                          : '+ Crear nuevo subtema',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),

                if (_showCustomSubtopicInput)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _newSubtopicController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del nuevo subtema',
                        hintText: 'Ej. Sonetos de juventud...',
                      ),
                    ),
                  ),

                // Tags Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: 'Etiquetas (#inspiración, #poema)',
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
                    ),
                  ],
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

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
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
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download),
                      label: Text(
                        _isLoading ? 'Descargando y analizando...' : 'Descargar & Organizar',
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

  Widget _buildHintChip(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (widget.isDark ? Colors.white : Colors.black).withAlpha(12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          color: widget.isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }
}
