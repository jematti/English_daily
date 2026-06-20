import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:flutter/material.dart';

class LearnedWordsCard extends StatelessWidget {
  const LearnedWordsCard({
    super.key,
    required this.learnedWords,
    required this.practicedWords,
  });

  final int learnedWords;
  final int practicedWords;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _MetricBlock(
            icon: Icons.school_outlined,
            label: 'Aprendidas',
            value: learnedWords,
            color: AppPalette.ocean,
          ),
          const SizedBox(width: 12),
          _MetricBlock(
            icon: Icons.quiz_outlined,
            label: 'Practicadas',
            value: practicedWords,
            color: AppPalette.violet,
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text('$value', style: AppTextStyles.display.copyWith(fontSize: 32)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
