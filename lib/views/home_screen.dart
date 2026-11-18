import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiniela_model.dart';
import '../services/progol_service.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';
import '../widgets/status_header.dart';
import '../widgets/settings_dialog.dart';

/// Pantalla Principal con dos pestañas (TabBar): Progol y Media Semana
class HomeScreen extends StatefulWidget {
  final ProgolService progolService;

  const HomeScreen({
    super.key,
    required this.progolService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final success = await widget.progolService.fetchQuinielas(isManual: true);
    if (!mounted) return;

    if (!success && widget.progolService.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.progolService.errorMessage!,
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () => widget.progolService.fetchQuinielas(isManual: true),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.progolService,
      builder: (context, _) {
        final data = widget.progolService.data;
        final isLoading = widget.progolService.isLoading;

        final progolQuiniela = data?.progol;
        final mediaSemanaQuiniela = data?.mediaSemana;

        final progolCount = progolQuiniela?.partidos.length ?? 0;
        final mediaSemanaCount = mediaSemanaQuiniela?.partidos.length ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_soccer, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Progol IA',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Botón "Actualizar Quiniela"
              IconButton(
                tooltip: 'Actualizar Quiniela',
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: AppTheme.primary),
                onPressed: isLoading ? null : _handleRefresh,
              ),

              // Botón de Configuración de Fuente de Datos
              IconButton(
                tooltip: 'Configurar Fuente de Datos',
                icon: const Icon(Icons.tune_rounded, color: AppTheme.textSecondary, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SettingsDialog(progolService: widget.progolService),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Progol'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.cardBorder, width: 0.8),
                        ),
                        child: Text(
                          progolCount > 0 ? '$progolCount' : '14',
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Media Semana'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.cardBorder, width: 0.8),
                        ),
                        child: Text(
                          mediaSemanaCount > 0 ? '$mediaSemanaCount' : '9',
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.predVisita,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Pestaña 1: Progol (14 partidos)
              _buildQuinielaList(
                quiniela: progolQuiniela,
                emptyMessage: 'No hay partidos disponibles para Progol Fin de Semana.',
                actualizadoEn: data?.actualizadoEn,
              ),

              // Pestaña 2: Media Semana (9 partidos)
              _buildQuinielaList(
                quiniela: mediaSemanaQuiniela,
                emptyMessage: 'No hay partidos disponibles para Progol Media Semana.',
                actualizadoEn: data?.actualizadoEn,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la lista limpia de tarjetas para cada pestaña con soporte Pull-to-Refresh
  Widget _buildQuinielaList({
    required Quiniela? quiniela,
    required String emptyMessage,
    required DateTime? actualizadoEn,
  }) {
    if (quiniela == null || quiniela.partidos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_soccer_outlined, size: 50, color: AppTheme.textMuted),
                  const SizedBox(height: 14),
                  Text(
                    emptyMessage,
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar Quiniela'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: quiniela.partidos.length + 1, // +1 para el header de estado
        itemBuilder: (context, index) {
          if (index == 0) {
            return StatusHeader(
              quiniela: quiniela,
              actualizadoEn: actualizadoEn,
            );
          }

          final partido = quiniela.partidos[index - 1];
          return MatchCard(partido: partido);
        },
      ),
    );
  }
}
