import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/widgets/section_title.dart';
import 'package:english_drops_daily/domain/models/content_pack_model.dart';
import 'package:english_drops_daily/features/packs/widgets/content_pack_card.dart';
import 'package:english_drops_daily/features/packs/widgets/premium_pack_card.dart';
import 'package:english_drops_daily/features/premium/screens/premium_preview_screen.dart';
import 'package:english_drops_daily/services/content/content_pack_service.dart';
import 'package:flutter/material.dart';

class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  final ContentPackService _contentPackService = const ContentPackService();
  late Future<_PacksData> _packsFuture;

  @override
  void initState() {
    super.initState();
    _packsFuture = _loadPacks();
  }

  Future<_PacksData> _loadPacks() async {
    final previewPacks = await _contentPackService.getPremiumPreviewPacks();
    final upcomingPacks = _contentPackService.getUpcomingPremiumPacks();

    return _PacksData(previewPacks: previewPacks, upcomingPacks: upcomingPacks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packs')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppPalette.background,
              AppPalette.surfaceCool,
              AppPalette.surfaceWarm,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<_PacksData>(
          future: _packsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const _MessageView(
                message: 'No pudimos cargar los packs.',
              );
            }

            final data = snapshot.data!;
            final freeSummary = _buildFreeSummary();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionTitle(
                  title: 'Gratis',
                  subtitle: 'Contenido incluido para aprender sin pagar.',
                  icon: Icons.card_giftcard_outlined,
                ),
                const SizedBox(height: 12),
                ContentPackCard(
                  pack: freeSummary,
                  features: const [
                    'Niveles A1 - A2',
                    'Ejercicios basicos',
                    'Notificaciones inteligentes',
                    'Progreso y racha',
                  ],
                ),
                const SizedBox(height: 22),
                const SectionTitle(
                  title: 'Premium',
                  subtitle: 'Vista previa y packs preparados para el futuro.',
                  icon: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: 12),
                ...data.previewPacks.map((pack) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumPackCard(
                      pack: pack,
                      onOpenPreview: _openPremiumPreview,
                    ),
                  );
                }),
                const SizedBox(height: 10),
                const SectionTitle(
                  title: 'Proximamente',
                  subtitle: 'Catalogo planificado. Compras aun no activadas.',
                  icon: Icons.lock_clock_outlined,
                ),
                const SizedBox(height: 12),
                ...data.upcomingPacks.map((pack) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumPackCard(
                      pack: pack,
                      onOpenPreview: _openPremiumPreview,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  ContentPackModel _buildFreeSummary() {
    return ContentPackModel(
      id: 'free_basic_1000_summary',
      name: '1000 palabras basicas',
      description: 'Pack gratuito para construir una base diaria simple.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: '',
      totalLessons: 1000,
    );
  }

  void _openPremiumPreview() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PremiumPreviewScreen()),
    );
  }
}

class _PacksData {
  const _PacksData({required this.previewPacks, required this.upcomingPacks});

  final List<ContentPackModel> previewPacks;
  final List<ContentPackModel> upcomingPacks;
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
