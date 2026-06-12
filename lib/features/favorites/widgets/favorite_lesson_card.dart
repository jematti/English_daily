import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:flutter/material.dart';

class FavoriteLessonCard extends StatelessWidget {
  const FavoriteLessonCard({super.key, required this.lesson, this.note});

  final LessonModel lesson;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final noteText = note?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.word,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(lesson.meaningEs),
            if (noteText != null && noteText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Nota personal',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(noteText),
            ],
          ],
        ),
      ),
    );
  }
}
