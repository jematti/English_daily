import 'package:english_drops_daily/core/constants/app_colors.dart';
import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/features/exercises/widgets/answer_feedback_box.dart';
import 'package:english_drops_daily/features/exercises/widgets/practice_progress_header.dart';
import 'package:english_drops_daily/features/exercises/widgets/practice_result_screen.dart';
import 'package:english_drops_daily/services/progress/progress_service.dart';
import 'package:flutter/material.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({
    super.key,
    required this.exercises,
    this.title = 'Practica rapida',
    this.emptyMessage = 'No hay ejercicios disponibles por ahora.',
    this.lessonId,
  });

  final List<ExerciseModel> exercises;
  final String title;
  final String emptyMessage;
  final String? lessonId;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  static const int _maxExercises = 5;

  int _currentIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _hasSavedResult = false;
  final ProgressService _progressService = const ProgressService();

  List<ExerciseModel> get _sessionExercises {
    return widget.exercises.take(_maxExercises).toList();
  }

  bool get _hasAnswered => _selectedAnswer != null;

  @override
  Widget build(BuildContext context) {
    final exercises = _sessionExercises;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppPalette.background,
              AppPalette.surfaceCool,
              AppPalette.surfaceWarm,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: exercises.isEmpty
              ? _MessageView(message: widget.emptyMessage)
              : _showResult
              ? PracticeResultScreen(
                  correctAnswers: _correctAnswers,
                  incorrectAnswers: exercises.length - _correctAnswers,
                  totalQuestions: exercises.length,
                  onRestart: _restart,
                  onReturnHome: _returnHome,
                )
              : _PracticeQuestionView(
                  exercise: exercises[_currentIndex],
                  currentQuestion: _currentIndex + 1,
                  totalQuestions: exercises.length,
                  selectedAnswer: _selectedAnswer,
                  onAnswerSelected: _selectAnswer,
                  onContinue: _continue,
                ),
        ),
      ),
    );
  }

  void _selectAnswer(String answer) {
    if (_hasAnswered) {
      return;
    }

    final exercise = _sessionExercises[_currentIndex];

    setState(() {
      _selectedAnswer = answer;
      if (answer == exercise.correctAnswer) {
        _correctAnswers++;
      }
    });
  }

  void _continue() {
    final exercises = _sessionExercises;
    if (_currentIndex >= exercises.length - 1) {
      _finishSession();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
    });
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _selectedAnswer = null;
      _showResult = false;
      _hasSavedResult = false;
    });
  }

  void _returnHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _finishSession() async {
    if (!_hasSavedResult) {
      await _progressService.savePracticeResult(
        lessonId: widget.lessonId ?? 'general_practice',
        correctAnswers: _correctAnswers,
        wrongAnswers: _sessionExercises.length - _correctAnswers,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasSavedResult = true;
      _showResult = true;
    });
  }
}

class _PracticeQuestionView extends StatelessWidget {
  const _PracticeQuestionView({
    required this.exercise,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.onContinue,
  });

  final ExerciseModel exercise;
  final int currentQuestion;
  final int totalQuestions;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onContinue;

  bool get _hasAnswered => selectedAnswer != null;

  bool get _isCorrect => selectedAnswer == exercise.correctAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        PracticeProgressHeader(
          currentQuestion: currentQuestion,
          totalQuestions: totalQuestions,
        ),
        const SizedBox(height: 18),
        PrimaryCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elige la respuesta correcta',
                style: AppTextStyles.label.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(exercise.question, style: AppTextStyles.cardTitle),
              const SizedBox(height: 18),
              ...exercise.options.take(4).map(_buildOptionButton),
              if (_hasAnswered) ...[
                const SizedBox(height: 8),
                AnswerFeedbackBox(
                  isCorrect: _isCorrect,
                  correctAnswer: exercise.correctAnswer,
                  explanation: exercise.explanation,
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: currentQuestion == totalQuestions
                      ? 'Ver resultado'
                      : 'Siguiente',
                  icon: currentQuestion == totalQuestions
                      ? Icons.flag_outlined
                      : Icons.arrow_forward,
                  onPressed: onContinue,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String option) {
    final isSelected = option == selectedAnswer;
    final isCorrectAnswer = option == exercise.correctAnswer;

    Color? borderColor;
    Color? backgroundColor;
    IconData icon = Icons.radio_button_unchecked;

    if (_hasAnswered && isCorrectAnswer) {
      borderColor = AppColors.success;
      backgroundColor = AppColors.successSoft;
      icon = Icons.check_circle;
    } else if (_hasAnswered && isSelected) {
      borderColor = AppColors.error;
      backgroundColor = AppColors.errorSoft;
      icon = Icons.cancel;
    } else if (isSelected) {
      icon = Icons.radio_button_checked;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _hasAnswered ? null : () => onAnswerSelected(option),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: backgroundColor,
            disabledForegroundColor: borderColor,
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
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
