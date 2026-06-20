import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/memory_active_box.dart';
import 'package:flutter/material.dart';

class DailyWordExerciseSet extends StatefulWidget {
  const DailyWordExerciseSet({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  State<DailyWordExerciseSet> createState() => _DailyWordExerciseSetState();
}

class _DailyWordExerciseSetState extends State<DailyWordExerciseSet> {
  String? _selectedAnswer;

  LessonModel get lesson => widget.lesson;

  @override
  Widget build(BuildContext context) {
    final exercise = lesson.exercises.isNotEmpty
        ? lesson.exercises.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mini reto diario', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        if (exercise != null)
          _ChoiceChallenge(
            exercise: exercise,
            selectedAnswer: _selectedAnswer,
            onSelected: (answer) {
              setState(() {
                _selectedAnswer = answer;
              });
            },
          ),
        const SizedBox(height: 12),
        MemoryActiveBox(
          prompt: _activeRecallPrompt,
          answer: _activeRecallAnswer,
          tip: lesson.learningTip.learningTip,
        ),
        const SizedBox(height: 12),
        _CompletePhraseChallenge(lesson: lesson),
      ],
    );
  }

  String get _activeRecallPrompt {
    final prompt = lesson.learningTip.activeRecallPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      return prompt;
    }

    return 'Como dirias "${lesson.exampleEs}" en ingles?';
  }

  String get _activeRecallAnswer {
    final answer = lesson.learningTip.activeRecallAnswer;
    if (answer != null && answer.trim().isNotEmpty) {
      return answer;
    }

    return lesson.exampleEn;
  }
}

class _ChoiceChallenge extends StatelessWidget {
  const _ChoiceChallenge({
    required this.exercise,
    required this.selectedAnswer,
    required this.onSelected,
  });

  final ExerciseModel exercise;
  final String? selectedAnswer;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _ChallengeShell(
      icon: Icons.quiz_outlined,
      title: 'Elige la mejor opcion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.question,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exercise.options.take(4).map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = option == exercise.correctAnswer;
              final showResult = selectedAnswer != null && isSelected;

              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                avatar: showResult
                    ? Icon(
                        isCorrect
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 18,
                      )
                    : null,
                onSelected: (_) => onSelected(option),
              );
            }).toList(),
          ),
          if (selectedAnswer != null) ...[
            const SizedBox(height: 10),
            Text(exercise.explanation),
          ],
        ],
      ),
    );
  }
}

class _CompletePhraseChallenge extends StatelessWidget {
  const _CompletePhraseChallenge({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final phrase = lesson.exampleEn.replaceFirst(
      RegExp(RegExp.escape(lesson.word), caseSensitive: false),
      '_____',
    );

    return _ChallengeShell(
      icon: Icons.edit_outlined,
      title: 'Completa la frase',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phrase == lesson.exampleEn ? '${lesson.exampleEn} = ?' : phrase,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Respuesta: ${lesson.word}', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _ChallengeShell extends StatelessWidget {
  const _ChallengeShell({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.border),
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
