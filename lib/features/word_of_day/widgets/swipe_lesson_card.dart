import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/animated_swipe_card.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/lesson_card.dart';
import 'package:flutter/material.dart';

class SwipeLessonCard extends StatefulWidget {
  const SwipeLessonCard({
    super.key,
    required this.lesson,
    required this.lessons,
    required this.onPrevious,
    required this.onNext,
    required this.onSaveFavorite,
    required this.onRelated,
    required this.onLessonSelected,
    this.favoriteRefreshToken = 0,
  });

  final LessonModel lesson;
  final List<LessonModel> lessons;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSaveFavorite;
  final VoidCallback onRelated;
  final ValueChanged<LessonModel> onLessonSelected;
  final int favoriteRefreshToken;

  @override
  State<SwipeLessonCard> createState() => _SwipeLessonCardState();
}

class _SwipeLessonCardState extends State<SwipeLessonCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwipeCard(
          lesson: widget.lesson,
          onPrevious: widget.onPrevious,
          onNext: widget.onNext,
          onSaveFavorite: widget.onSaveFavorite,
          onRelated: widget.onRelated,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = (constraints.maxWidth - 10) / 2;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: AppButton(
                    label: 'Anterior',
                    icon: Icons.arrow_back,
                    variant: AppButtonVariant.outlined,
                    onPressed: widget.onPrevious,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: AppButton(
                    label: 'Pasar',
                    icon: Icons.arrow_forward,
                    variant: AppButtonVariant.outlined,
                    onPressed: widget.onNext,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: AppButton(
                    label: 'Guardar',
                    icon: Icons.favorite_border,
                    variant: AppButtonVariant.tonal,
                    onPressed: widget.onSaveFavorite,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: AppButton(
                    label: 'Relacionada',
                    icon: Icons.link,
                    variant: AppButtonVariant.tonal,
                    onPressed: widget.onRelated,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        LessonCard(
          lesson: widget.lesson,
          lessons: widget.lessons,
          onLessonSelected: widget.onLessonSelected,
          showHeader: false,
          favoriteRefreshToken: widget.favoriteRefreshToken,
        ),
      ],
    );
  }
}
