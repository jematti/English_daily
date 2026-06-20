import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/exercise_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/exercises/screens/practice_session_screen.dart';
import 'package:english_drops_daily/services/access/access_service.dart';
import 'package:flutter/material.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late final Future<List<ExerciseModel>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _loadExercises();
  }

  Future<List<ExerciseModel>> _loadExercises() async {
    final lessons = await const LessonLocalDatasource().getLessons();
    final accessibleLessons = await const AccessService()
        .filterAccessibleLessons(lessons);

    return accessibleLessons
        .expand((LessonModel lesson) => lesson.exercises)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExerciseModel>>(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            appBar: _PracticeAppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            appBar: _PracticeAppBar(),
            body: _MessageView(message: 'No pudimos cargar los ejercicios.'),
          );
        }

        final exercises = snapshot.data ?? const [];

        return PracticeSessionScreen(exercises: exercises);
      },
    );
  }
}

class _PracticeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PracticeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Practica rapida'));
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}
