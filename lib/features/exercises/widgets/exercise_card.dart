import 'package:english_drops_daily/core/constants/app_colors.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/features/exercises/widgets/answer_feedback_box.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatefulWidget {
  const ExerciseCard({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  String? _selectedAnswer;

  bool get _hasAnswered => _selectedAnswer != null;

  bool get _isCorrect => _selectedAnswer == widget.exercise.correctAnswer;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Elige la respuesta correcta',
                  style: AppTextStyles.label.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.exercise.question, style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          ...widget.exercise.options.map(_buildOptionButton),
          if (_hasAnswered) ...[
            const SizedBox(height: 8),
            AnswerFeedbackBox(
              isCorrect: _isCorrect,
              correctAnswer: widget.exercise.correctAnswer,
              explanation: widget.exercise.explanation,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final isSelected = option == _selectedAnswer;
    final isCorrectAnswer = option == widget.exercise.correctAnswer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color? borderColor;
    Color? backgroundColor;
    IconData icon = Icons.radio_button_unchecked;

    if (_hasAnswered && isCorrectAnswer) {
      borderColor = AppColors.success;
      backgroundColor = AppColors.successSoft.withValues(
        alpha: isDark ? 0.14 : 1,
      );
      icon = Icons.check_circle;
    } else if (_hasAnswered && isSelected) {
      borderColor = AppColors.error;
      backgroundColor = AppColors.errorSoft.withValues(
        alpha: isDark ? 0.14 : 1,
      );
      icon = Icons.cancel;
    } else if (isSelected) {
      borderColor = Theme.of(context).colorScheme.primary;
      icon = Icons.radio_button_checked;
    }

    final foregroundColor =
        borderColor ?? Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _hasAnswered ? null : () => _selectAnswer(option),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledForegroundColor: foregroundColor,
            side: borderColor == null
                ? null
                : BorderSide(color: borderColor, width: 1.4),
          ),
          icon: Icon(icon, size: 20),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(option, textAlign: TextAlign.left),
          ),
        ),
      ),
    );
  }

  void _selectAnswer(String option) {
    setState(() {
      _selectedAnswer = option;
    });
  }
}
