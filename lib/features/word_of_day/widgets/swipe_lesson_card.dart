import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/lesson_card.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/swipe_hint_bar.dart';
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
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    widget.lesson.word,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SwipeHintBar(),
                  const SizedBox(height: 8),
                  Text(
                    'Desliza sobre esta tarjeta',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: widget.onPrevious,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
            ),
            OutlinedButton.icon(
              onPressed: widget.onNext,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Pasar'),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.onSaveFavorite,
              icon: const Icon(Icons.favorite_border),
              label: const Text('Guardar'),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.onRelated,
              icon: const Icon(Icons.link),
              label: const Text('Relacionada'),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
