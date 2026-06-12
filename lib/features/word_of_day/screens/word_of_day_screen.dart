import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/lesson_card.dart';
import 'package:flutter/material.dart';

class WordOfDayScreen extends StatefulWidget {
  const WordOfDayScreen({super.key, this.initialLessonId});

  final String? initialLessonId;

  @override
  State<WordOfDayScreen> createState() => _WordOfDayScreenState();
}

class _WordOfDayScreenState extends State<WordOfDayScreen> {
  late final Future<List<LessonModel>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = const LessonLocalDatasource().getLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('English Drops Daily')),
      body: FutureBuilder<List<LessonModel>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _MessageView(
              message:
                  'No pudimos cargar la leccion de hoy. Intentalo de nuevo.',
            );
          }

          final lessons = snapshot.data ?? const [];
          if (lessons.isEmpty) {
            return const _MessageView(
              message: 'No hay lecciones disponibles por ahora.',
            );
          }

          final selectedLesson = _findSelectedLesson(lessons);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LessonCard(lesson: selectedLesson),
            ),
          );
        },
      ),
    );
  }

  LessonModel _findSelectedLesson(List<LessonModel> lessons) {
    final lessonId = widget.initialLessonId;
    if (lessonId == null) {
      return lessons.first;
    }

    return lessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => lessons.first,
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
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
