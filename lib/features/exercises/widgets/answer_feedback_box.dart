import 'package:english_drops_daily/core/constants/app_colors.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AnswerFeedbackBox extends StatelessWidget {
  const AnswerFeedbackBox({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isCorrect ? AppColors.success : AppColors.error;
    final background = isCorrect ? AppColors.successSoft : AppColors.errorSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background.withValues(alpha: isDark ? 0.14 : 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect ? 'Correcto' : 'Sigue practicando',
                  style: AppTextStyles.cardTitle.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isCorrect) ...[
            Text(
              'Respuesta correcta: $correctAnswer',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
          ],
          Text(explanation, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
