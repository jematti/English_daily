import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/daily_word_bonus_card.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/daily_word_exercise_set.dart';
import 'package:english_drops_daily/services/access/access_service.dart';
import 'package:english_drops_daily/services/lesson_selection_service.dart';
import 'package:flutter/material.dart';

class DailyWordSpecialScreen extends StatefulWidget {
  const DailyWordSpecialScreen({super.key, this.currentLessonId});

  final String? currentLessonId;

  @override
  State<DailyWordSpecialScreen> createState() => _DailyWordSpecialScreenState();
}

class _DailyWordSpecialScreenState extends State<DailyWordSpecialScreen> {
  late final Future<LessonModel?> _dailyLessonFuture;

  @override
  void initState() {
    super.initState();
    _dailyLessonFuture = _loadDailyLesson();
  }

  Future<LessonModel?> _loadDailyLesson() async {
    final lessons = await const LessonLocalDatasource().getLessons();
    final accessibleLessons = await const AccessService()
        .filterAccessibleLessons(lessons);
    if (accessibleLessons.isEmpty) {
      return null;
    }

    final differentLessons = accessibleLessons.where((lesson) {
      return lesson.id != widget.currentLessonId;
    }).toList();
    final selectionPool = differentLessons.isNotEmpty
        ? differentLessons
        : accessibleLessons;

    final selectionService = const LessonSelectionService();
    final nextUnseenLesson = await selectionService.getNextUnseenLesson(
      selectionPool,
    );

    return nextUnseenLesson ??
        await selectionService.getFallbackLesson(selectionPool);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gota del dia')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppPalette.surfaceWarm,
              AppPalette.background,
              AppPalette.surfaceAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<LessonModel?>(
          future: _dailyLessonFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const _MessageView(
                message: 'No hay gota especial disponible por ahora.',
              );
            }

            final lesson = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                DailyWordBonusCard(lesson: lesson),
                const SizedBox(height: 18),
                DailyWordExerciseSet(lesson: lesson),
              ],
            );
          },
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
