import 'package:english_drops_daily/domain/models/exercise_model.dart';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exercise.question,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.exercise.options.map(_buildOptionButton),
            if (_hasAnswered) ...[
              const SizedBox(height: 12),
              Text(
                _isCorrect ? 'Correcto' : 'Incorrecto',
                style: TextStyle(
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text('Respuesta correcta: ${widget.exercise.correctAnswer}'),
              const SizedBox(height: 6),
              Text(widget.exercise.explanation),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final isSelected = option == _selectedAnswer;
    final isCorrectAnswer = option == widget.exercise.correctAnswer;

    Color? borderColor;
    if (_hasAnswered && isSelected) {
      borderColor = isCorrectAnswer ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _hasAnswered ? null : () => _selectAnswer(option),
          style: OutlinedButton.styleFrom(
            side: borderColor == null ? null : BorderSide(color: borderColor),
          ),
          child: Align(alignment: Alignment.centerLeft, child: Text(option)),
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
