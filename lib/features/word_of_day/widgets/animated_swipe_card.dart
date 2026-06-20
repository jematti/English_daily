import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/swipe_hint_bar.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
import 'package:flutter/material.dart';

class AnimatedSwipeCard extends StatefulWidget {
  const AnimatedSwipeCard({
    super.key,
    required this.lesson,
    required this.onPrevious,
    required this.onNext,
    required this.onSaveFavorite,
    required this.onRelated,
  });

  final LessonModel lesson;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSaveFavorite;
  final VoidCallback onRelated;

  @override
  State<AnimatedSwipeCard> createState() => _AnimatedSwipeCardState();
}

class _AnimatedSwipeCardState extends State<AnimatedSwipeCard> {
  static const double _swipeThreshold = 78;
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final rotation = (_dragOffset.dx / 420).clamp(-0.12, 0.12);
    final opacity = (1 - (_dragOffset.distance / 520)).clamp(0.78, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (_) => _finishDrag(),
      onPanCancel: _resetDrag,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: Offset(_dragOffset.dx / 320, _dragOffset.dy / 520),
        child: Transform.rotate(
          angle: rotation,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: opacity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: _SwipeContent(
                key: ValueKey(widget.lesson.id),
                lesson: widget.lesson,
                dragOffset: _dragOffset,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _finishDrag() {
    final offset = _dragOffset;
    _resetDrag();

    if (offset.dx <= -_swipeThreshold) {
      widget.onNext();
      return;
    }

    if (offset.dx >= _swipeThreshold) {
      widget.onSaveFavorite();
      return;
    }

    if (offset.dy <= -_swipeThreshold) {
      widget.onRelated();
      return;
    }

    if (offset.dy >= _swipeThreshold) {
      widget.onPrevious();
    }
  }

  void _resetDrag() {
    if (!mounted) {
      return;
    }

    setState(() {
      _dragOffset = Offset.zero;
    });
  }
}

class _SwipeContent extends StatelessWidget {
  const _SwipeContent({
    super.key,
    required this.lesson,
    required this.dragOffset,
  });

  final LessonModel lesson;
  final Offset dragOffset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final action = _actionForOffset(dragOffset);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 330),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.72),
            AppPalette.surfaceWarm.withValues(alpha: 0.86),
            AppPalette.surfaceAccent.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ocean.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _LevelBadge(level: lesson.level, category: lesson.category),
          ),
          const SizedBox(height: 22),
          Icon(Icons.touch_app_outlined, color: colorScheme.primary, size: 30),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              lesson.word,
              textAlign: TextAlign.center,
              style: AppTextStyles.display.copyWith(
                fontSize: 48,
                color: AppPalette.textPrimary,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.meaningEs,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.pronunciation,
            style: AppTextStyles.label.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            lesson.exampleEn,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppPalette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.exampleEs,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _SwipeLearningPreview(lesson: lesson),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: action == null
                ? ValueListenableBuilder(
                    valueListenable: AppSettingsStorageService.settingsNotifier,
                    builder: (context, settings, _) {
                      if (!settings.showSwipeHints) {
                        return const SizedBox.shrink();
                      }
                      return const SwipeHintBar();
                    },
                  )
                : _ActionChip(key: ValueKey(action.label), action: action),
          ),
        ],
      ),
    );
  }

  _SwipeAction? _actionForOffset(Offset offset) {
    if (offset.dx.abs() < 42 && offset.dy.abs() < 42) {
      return null;
    }

    if (offset.dx.abs() >= offset.dy.abs()) {
      return offset.dx < 0
          ? const _SwipeAction(Icons.arrow_forward, 'Siguiente')
          : const _SwipeAction(Icons.favorite, 'Guardar');
    }

    return offset.dy < 0
        ? const _SwipeAction(Icons.link, 'Relacionada')
        : const _SwipeAction(Icons.arrow_back, 'Anterior');
  }
}

class _SwipeLearningPreview extends StatelessWidget {
  const _SwipeLearningPreview({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final dailyPhrase = lesson.dailyUse.isNotEmpty
        ? lesson.dailyUse.first
        : lesson.usage;
    final mistake = lesson.commonMistakes.isNotEmpty
        ? lesson.commonMistakes.first
        : 'Usala dentro de una frase real.';

    return Column(
      children: [
        _MiniLearningRow(
          icon: Icons.today_outlined,
          label: 'Uso diario',
          text: dailyPhrase,
          color: AppPalette.success,
        ),
        const SizedBox(height: 8),
        _MiniLearningRow(
          icon: Icons.warning_amber_outlined,
          label: 'Error comun',
          text: mistake,
          color: AppPalette.coral,
        ),
      ],
    );
  }
}

class _MiniLearningRow extends StatelessWidget {
  const _MiniLearningRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppPalette.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.category});

  final String level;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(label: level, color: AppPalette.ocean),
        _Pill(label: category.replaceAll('_', ' '), color: AppPalette.coral),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({super.key, required this.action});

  final _SwipeAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.violet.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon),
          const SizedBox(width: 8),
          Text(action.label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _SwipeAction {
  const _SwipeAction(this.icon, this.label);

  final IconData icon;
  final String label;
}
