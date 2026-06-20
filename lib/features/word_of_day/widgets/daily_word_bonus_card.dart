import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/verb_cards_section.dart';
import 'package:flutter/material.dart';

class DailyWordBonusCard extends StatelessWidget {
  const DailyWordBonusCard({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppPalette.sunshine,
            AppPalette.surfaceWarm,
            AppPalette.surfaceAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.coral.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppPalette.coral),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gota especial del dia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            lesson.word,
            style: AppTextStyles.display.copyWith(
              color: AppPalette.textPrimary,
              fontSize: 44,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.meaningEs,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _ExampleBubble(lesson: lesson),
          if (lesson.isVerb) ...[
            const SizedBox(height: 12),
            VerbCardsSection(lesson: lesson, compact: true),
          ],
        ],
      ),
    );
  }
}

class _ExampleBubble extends StatelessWidget {
  const _ExampleBubble({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.exampleEn,
            style: AppTextStyles.body.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            lesson.exampleEs,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
          ),
        ],
      ),
    );
  }
}
