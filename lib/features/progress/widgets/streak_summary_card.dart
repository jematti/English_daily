import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:flutter/material.dart';

class StreakSummaryCard extends StatelessWidget {
  const StreakSummaryCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  final int currentStreak;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      color: AppPalette.surfaceWarm,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppPalette.sunshine.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_fire_department, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Racha actual', style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(
                  '$currentStreak dias',
                  style: AppTextStyles.display.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 4),
                Text('Mejor racha: $bestStreak dias'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
