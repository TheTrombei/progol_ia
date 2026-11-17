import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/archive_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/artistic_palettes.dart';

class SettingsDialog extends StatefulWidget {
  final ThemeProvider themeProvider;
  final ArchiveProvider archiveProvider;

  const SettingsDialog({
    super.key,
    required this.themeProvider,
    required this.archiveProvider,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _geminiController;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _geminiController =
        TextEditingController(text: widget.themeProvider.geminiApiKey);
    _fontSize = widget.themeProvider.poeticFontSize;
  }

  @override
  void dispose() {
    _geminiController.dispose();
    super.dispose();
  }

  Future<void> _exportBackup() async {
    final json = await widget.archiveProvider.exportArchiveJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Archivo JSON copiado al portapapeles. ¡Guárdalo en tus notas o archivo! 📦'),
        ),
      );
    }
  }

  Future<void> _importBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );

    if (files.isNotEmpty) {
      try {
        final jsonStr = await files.first.xFile.readAsString();
        final count = await widget.archiveProvider.importArchiveJson(jsonStr);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se importaron con éxito $count textos literarios ✨'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al importar archivo: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeProvider.currentPalette;
    final isDark = widget.themeProvider.isDark;

    return Dialog(
      backgroundColor: isDark ? palette.surfaceDark : palette.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: palette.primary.withAlpha(70)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
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
                      gradient: LinearGradient(
                        colors: [palette.primary, palette.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.palette_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajustes & Estética',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Paletas artísticas, tipografía y sincronización',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
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
              const Divider(),

              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 8),

                    // Palette Selector
                    Text(
                      'PALETAS ARTÍSTICAS',
                      style: GoogleFonts.cinzel(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.3,
                      ),
                      itemCount: ArtisticPalette.allPalettes.length,
                      itemBuilder: (context, i) {
                        final p = ArtisticPalette.allPalettes[i];
                        final isSelected = p.type == palette.type;
                        return InkWell(
                          onTap: () => widget.themeProvider.setPalette(p),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? p.surfaceDark : p.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? p.primary
                                    : (isDark ? Colors.white24 : Colors.black12),
                                width: isSelected ? 2.2 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: p.primary.withAlpha(70),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(p.emoji, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        p.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _colorCircle(p.primary),
                                          _colorCircle(p.secondary),
                                          _colorCircle(p.accent),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, size: 16, color: p.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Dark / Light Mode Switch
                    Row(
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: palette.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo Nocturno / Diurno',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                isDark
                                    ? 'Fondo oscuro con atmósfera luminosa'
                                    : 'Fondo claro pergamino',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isDark,
                          activeThumbColor: palette.primary,
                          onChanged: (val) => widget.themeProvider.setIsDark(val),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Poetic Font Size Slider
                    Text(
                      'TAMAÑO DE TIPOGRAFÍA POÉTICA (${_fontSize.toInt()} px)',
                      style: GoogleFonts.cinzel(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: palette.primary,
                      ),
                    ),
                    Slider(
                      value: _fontSize,
                      min: 15.0,
                      max: 26.0,
                      divisions: 11,
                      activeColor: palette.primary,
                      label: '${_fontSize.toInt()} px',
                      onChanged: (val) {
                        setState(() => _fontSize = val);
                        widget.themeProvider.setPoeticFontSize(val);
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Gemini API Key
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFF4A261), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'CLAVE GOOGLE GEMINI AI (OPCIONAL)',
                          style: GoogleFonts.cinzel(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: const Color(0xFFF4A261),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Para exégesis crítica y sugerencias avanzadas de la Musa IA. (El motor de análisis local y similitudes funciona siempre sin clave).',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _geminiController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'AIzaSy...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save),
                          tooltip: 'Guardar clave',
                          onPressed: () {
                            widget.themeProvider.setGeminiApiKey(_geminiController.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Clave de Gemini guardada ✨')),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Export / Import JSON
                    Text(
                      'COPIA DE SEGURIDAD & MIGRACIÓN',
                      style: GoogleFonts.cinzel(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: palette.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Exporta tus escritos e impórtalos fácilmente entre tu celular Android y tu PC (o GitHub Pages).',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _exportBackup,
                            icon: const Icon(Icons.copy_all, size: 16),
                            label: const Text('Copiar Respaldo JSON'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: palette.primary,
                              side: BorderSide(color: palette.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _importBackup,
                            icon: const Icon(Icons.file_upload_outlined, size: 16),
                            label: const Text('Importar Archivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
