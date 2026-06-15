import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:flutter/material.dart';

class FavoriteLessonCard extends StatelessWidget {
  const FavoriteLessonCard({super.key, required this.lesson, this.note});

  final LessonModel lesson;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final noteText = note?.trim();
    final colorScheme = Theme.of(context).colorScheme;

    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.favorite, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.word, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 3),
                    Text(lesson.meaningEs),
                  ],
                ),
              ),
            ],
          ),
          if (noteText != null && noteText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note_outlined,
                        size: 19,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      const Text('Nota personal', style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(noteText),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
