import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/premium/widgets/premium_feature_card.dart';
import 'package:english_drops_daily/services/content/content_pack_service.dart';
import 'package:flutter/material.dart';

class PremiumPreviewScreen extends StatelessWidget {
  const PremiumPreviewScreen({super.key});

  Future<List<LessonModel>> _loadPreviewLessons() {
    return const ContentPackService().loadLessonsByPack('premium_preview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Desbloquea English Drops Premium',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Vista previa del catalogo premium. Las compras todavia no estan activas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            const PremiumFeatureCard(
              icon: Icons.auto_stories_outlined,
              title: 'mas de 10.000 palabras',
            ),
            const PremiumFeatureCard(
              icon: Icons.school_outlined,
              title: 'niveles B1, B2 y C1',
            ),
            const PremiumFeatureCard(
              icon: Icons.work_outline,
              title: 'packs de viajes, trabajo y phrasal verbs',
            ),
            const PremiumFeatureCard(
              icon: Icons.quiz_outlined,
              title: 'mas ejercicios',
            ),
            const PremiumFeatureCard(
              icon: Icons.block_outlined,
              title: 'sin anuncios en el futuro',
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<LessonModel>>(
              future: _loadPreviewLessons(),
              builder: (context, snapshot) {
                final lessons = snapshot.data ?? const [];
                if (lessons.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Muestra B1',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...lessons.map((lesson) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.lock_outline),
                        title: Text(lesson.word),
                        subtitle: Text(lesson.meaningEs),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const AppButton(
              label: 'Disponible proximamente',
              icon: Icons.lock_clock_outlined,
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
