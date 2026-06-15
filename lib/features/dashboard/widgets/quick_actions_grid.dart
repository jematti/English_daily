import 'package:english_drops_daily/features/progress/screens/review_screen.dart';
import 'package:english_drops_daily/features/exercises/screens/exercises_screen.dart';
import 'package:english_drops_daily/features/favorites/screens/favorites_screen.dart';
import 'package:english_drops_daily/features/settings/screens/app_settings_screen.dart';
import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickAction(label: 'Ejercicios', icon: Icons.quiz_outlined),
      _QuickAction(label: 'Favoritos', icon: Icons.favorite_border),
      _QuickAction(label: 'Repasos', icon: Icons.replay_outlined),
      _QuickAction(label: 'Configuracion', icon: Icons.settings_outlined),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accesos rapidos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: actions.map((action) {
                return OutlinedButton.icon(
                  onPressed: () {
                    if (action.label == 'Ejercicios') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ExercisesScreen(),
                        ),
                      );
                      return;
                    }

                    if (action.label == 'Favoritos') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                      return;
                    }

                    if (action.label == 'Repasos') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ReviewScreen(),
                        ),
                      );
                      return;
                    }

                    if (action.label == 'Configuracion') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AppSettingsScreen(),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Disponible en proxima fase'),
                      ),
                    );
                  },
                  icon: Icon(action.icon),
                  label: Text(action.label),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
