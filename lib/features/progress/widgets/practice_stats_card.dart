import 'package:english_drops_daily/core/constants/app_colors.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:flutter/material.dart';

class PracticeStatsCard extends StatelessWidget {
  const PracticeStatsCard({
    super.key,
    required this.totalSessions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.accuracyPercentage,
  });

  final int totalSessions;
  final int correctAnswers;
  final int wrongAnswers;
  final int accuracyPercentage;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rendimiento', style: AppTextStyles.cardTitle),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$accuracyPercentage%',
                  style: AppTextStyles.display.copyWith(fontSize: 42),
                ),
              ),
              const Icon(
                Icons.insights_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Aciertos en practica'),
          const SizedBox(height: 14),
          _StatRow(label: 'Sesiones', value: totalSessions),
          _StatRow(label: 'Correctas', value: correctAnswers),
          _StatRow(label: 'Incorrectas', value: wrongAnswers),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '$value',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
