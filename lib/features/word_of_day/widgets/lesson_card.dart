import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/services/tts/tts_service.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatefulWidget {
  const LessonCard({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  final TtsService _ttsService = TtsService();

  LessonModel get lesson => widget.lesson;

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstExercise = lesson.exercises.isNotEmpty
        ? lesson.exercises.first
        : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.word,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              lesson.meaningEs,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              lesson.pronunciation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _speakWord(context),
                  icon: const Icon(Icons.volume_up_outlined),
                  label: const Text('Escuchar palabra'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _speakExample(context),
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: const Text('Escuchar ejemplo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'El audio depende del motor de texto a voz del dispositivo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'Ejemplo',
              child: _ExampleBlock(lesson: lesson),
            ),
            _TextSection(title: 'Uso', text: lesson.usage),
            _TextSection(title: 'Mini gramatica', text: lesson.grammar),
            _ListSection(
              title: 'Errores comunes',
              items: lesson.commonMistakes,
            ),
            _ListSection(title: 'Uso diario', items: lesson.dailyUse),
            if (firstExercise != null)
              _ExerciseSection(exercise: firstExercise),
          ],
        ),
      ),
    );
  }

  Future<void> _speakWord(BuildContext context) async {
    await _speak(context, () => _ttsService.speakWord(lesson.word));
  }

  Future<void> _speakExample(BuildContext context) async {
    await _speak(context, () => _ttsService.speakSentence(lesson.exampleEn));
  }

  Future<void> _speak(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo reproducir audio en este dispositivo. Prueba en un celular físico o revisa el motor de texto a voz.',
          ),
        ),
      );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _Section(title: title, child: Text(text));
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('- $item'),
          );
        }).toList(),
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  const _ExampleBlock({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lesson.exampleEn,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(lesson.exampleEs),
      ],
    );
  }
}

class _ExerciseSection extends StatelessWidget {
  const _ExerciseSection({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Ejercicio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.question,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...exercise.options.map((option) {
            final isCorrect = option == exercise.correctAnswer;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isCorrect ? 'Correct: ' : '- '),
                  Expanded(child: Text(option)),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Text(exercise.explanation),
        ],
      ),
    );
  }
}
