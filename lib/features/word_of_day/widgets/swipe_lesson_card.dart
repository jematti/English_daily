import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/lesson_card.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/swipe_hint_bar.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
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
  static const double _swipeThreshold = 48;
  double _horizontalDrag = 0;
  double _verticalDrag = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => _horizontalDrag = 0,
          onHorizontalDragUpdate: (details) {
            _horizontalDrag += details.delta.dx;
          },
          onHorizontalDragEnd: (_) => _finishHorizontalDrag(),
          onVerticalDragStart: (_) => _verticalDrag = 0,
          onVerticalDragUpdate: (details) {
            _verticalDrag += details.delta.dy;
          },
          onVerticalDragEnd: (_) => _finishVerticalDrag(),
          child: PrimaryCard(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.48),
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'PALABRA ACTUAL',
                      style: AppTextStyles.label.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(widget.lesson.word, style: AppTextStyles.display),
                const SizedBox(height: 6),
                Text(
                  widget.lesson.meaningEs,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.lesson.pronunciation,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: AppSettingsStorageService.settingsNotifier,
                  builder: (context, settings, _) {
                    if (!settings.showSwipeHints) {
                      return const SizedBox.shrink();
                    }
                    return const Column(
                      children: [
                        SwipeHintBar(),
                        SizedBox(height: 8),
                        Text('Desliza sobre esta tarjeta'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
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

  void _finishHorizontalDrag() {
    final distance = _horizontalDrag;
    _horizontalDrag = 0;

    if (distance <= -_swipeThreshold) {
      widget.onNext();
    } else if (distance >= _swipeThreshold) {
      widget.onSaveFavorite();
    }
  }

  void _finishVerticalDrag() {
    final distance = _verticalDrag;
    _verticalDrag = 0;

    if (distance <= -_swipeThreshold) {
      widget.onRelated();
    } else if (distance >= _swipeThreshold) {
      widget.onPrevious();
    }
  }
}
