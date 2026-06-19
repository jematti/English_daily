import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:flutter/material.dart';

class WordOfDayFab extends StatelessWidget {
  const WordOfDayFab({super.key, required this.lesson, required this.onOpen});

  final LessonModel lesson;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showWordOfDay(context),
      backgroundColor: AppPalette.sunshine,
      foregroundColor: AppPalette.textPrimary,
      icon: const Icon(Icons.card_giftcard),
      label: const Text('Bonus diario'),
    );
  }

  void _showWordOfDay(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppPalette.sunshine.withValues(alpha: 0.26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome),
                  ),
                  const SizedBox(width: 12),
                  Text('Palabra del dia', style: AppTextStyles.sectionTitle),
                ],
              ),
              const SizedBox(height: 18),
              Text(lesson.word, style: AppTextStyles.display),
              const SizedBox(height: 6),
              Text(
                lesson.meaningEs,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                lesson.exampleEn,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                lesson.exampleEs,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Abrir microleccion',
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpen();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
