import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progol_service.dart';
import '../theme/app_theme.dart';

/// Diálogo de configuración para personalizar la URL del repositorio de GitHub
class SettingsDialog extends StatefulWidget {
  final ProgolService progolService;

  const SettingsDialog({
    super.key,
    required this.progolService,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.progolService.currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      title: Row(
        children: [
          const Icon(Icons.settings_outlined, color: AppTheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            'Configurar Fuente de Datos',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La aplicación lee el archivo progol_data.json generado automáticamente por GitHub Actions.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'URL Raw de GitHub:',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              style: GoogleFonts.robotoMono(fontSize: 12, color: AppTheme.textPrimary),
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardSurface,
                hintText: 'https://raw.githubusercontent.com/.../progol_data.json',
                hintStyle: GoogleFonts.robotoMono(fontSize: 11, color: AppTheme.textMuted),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                _controller.text = ProgolService.defaultRawUrl;
              },
              icon: const Icon(Icons.restore, size: 16, color: AppTheme.textSecondary),
              label: Text(
                'Restablecer URL por defecto',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            widget.progolService.updateRawUrl(_controller.text);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('URL de origen actualizada y sincronizando...'),
                backgroundColor: AppTheme.surface,
              ),
            );
          },
          child: Text(
            'Guardar y Sincronizar',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
