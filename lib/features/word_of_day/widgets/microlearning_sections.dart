import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/common_mistake_box.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/daily_use_box.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/memory_active_box.dart';
import 'package:flutter/material.dart';

class MicrolearningSections extends StatelessWidget {
  const MicrolearningSections({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final firstExercise = lesson.exercises.isNotEmpty
        ? lesson.exercises.first
        : null;
    final activePrompt = _activeRecallPrompt(lesson);
    final activeAnswer = _activeRecallAnswer(lesson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MicrolearningSectionCard(
          icon: Icons.bolt_outlined,
          title: 'Significado rapido',
          child: Text(lesson.meaningEs, style: AppTextStyles.body),
        ),
        MicrolearningSectionCard(
          icon: Icons.forum_outlined,
          title: 'Ejemplo real',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.exampleEn,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                lesson.exampleEs,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        MicrolearningSectionCard(
          icon: Icons.today_outlined,
          title: 'Uso diario',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.usage, style: AppTextStyles.body),
              const SizedBox(height: 12),
              DailyUseBox(phrases: lesson.dailyUse),
            ],
          ),
        ),
        MicrolearningSectionCard(
          icon: Icons.school_outlined,
          title: 'Mini gramatica',
          child: Text(lesson.grammar, style: AppTextStyles.body),
        ),
        MicrolearningSectionCard(
          icon: Icons.warning_amber_outlined,
          title: 'Error comun',
          child: CommonMistakeBox(mistake: _mainMistake(lesson)),
        ),
        MicrolearningSectionCard(
          icon: Icons.task_alt_outlined,
          title: 'Reto rapido',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemoryActiveBox(
                prompt: activePrompt,
                answer: activeAnswer,
                tip: lesson.learningTip.learningTip,
              ),
              if (firstExercise != null) ...[
                const SizedBox(height: 12),
                QuickExerciseBox(exercise: firstExercise),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _activeRecallPrompt(LessonModel lesson) {
    final prompt = lesson.learningTip.activeRecallPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      return prompt;
    }

    return 'Como dirias "${lesson.exampleEs}" en ingles?';
  }

  String _activeRecallAnswer(LessonModel lesson) {
    final answer = lesson.learningTip.activeRecallAnswer;
    if (answer != null && answer.trim().isNotEmpty) {
      return answer;
    }

    return lesson.exampleEn;
  }

  String _mainMistake(LessonModel lesson) {
    if (lesson.commonMistakes.isNotEmpty) {
      return lesson.commonMistakes.first;
    }

    return 'No memorices "${lesson.word}" como traduccion aislada. Usala dentro de una frase real.';
  }
}

class MicrolearningSectionCard extends StatelessWidget {
  const MicrolearningSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppPalette.darkSurfaceCool.withValues(alpha: 0.44)
            : AppPalette.surfaceCool.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class QuickExerciseBox extends StatelessWidget {
  const QuickExerciseBox({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surfaceWarm.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.coral.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.question,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...exercise.options.take(4).map((option) {
            final isCorrect = option == exercise.correctAnswer;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_outline : Icons.circle,
                    size: isCorrect ? 18 : 8,
                    color: isCorrect
                        ? AppPalette.success
                        : AppPalette.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(option)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            exercise.explanation,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
