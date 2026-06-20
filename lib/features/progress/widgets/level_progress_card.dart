import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:flutter/material.dart';

class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({super.key, required this.levelProgress});

  final Map<String, int> levelProgress;

  @override
  Widget build(BuildContext context) {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    final maxValue = _maxProgress(levels);

    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Avance por nivel', style: AppTextStyles.cardTitle),
          const SizedBox(height: 14),
          ...levels.map((level) {
            final value = levelProgress[level] ?? 0;
            final progress = maxValue == 0 ? 0.0 : value / maxValue;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          level,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text('$value palabras'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress.clamp(0, 1),
                      backgroundColor: AppPalette.border.withValues(
                        alpha: 0.46,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  int _maxProgress(List<String> levels) {
    var maxValue = 0;
    for (final level in levels) {
      final value = levelProgress[level] ?? 0;
      if (value > maxValue) {
        maxValue = value;
      }
    }

    return maxValue;
  }
}
