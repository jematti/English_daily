import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/swipe_lesson_card.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:flutter/material.dart';

class WordOfDayScreen extends StatefulWidget {
  const WordOfDayScreen({super.key, this.initialLessonId});

  final String? initialLessonId;

  @override
  State<WordOfDayScreen> createState() => _WordOfDayScreenState();
}

class _WordOfDayScreenState extends State<WordOfDayScreen> {
  late final Future<List<LessonModel>> _lessonsFuture;
  final FavoritesStorageService _favoritesStorage =
      const FavoritesStorageService();
  String? _selectedLessonId;
  int _favoriteRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _selectedLessonId = widget.initialLessonId;
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
              child: SwipeLessonCard(
                lesson: selectedLesson,
                lessons: lessons,
                onPrevious: () => _showPreviousLesson(lessons),
                onNext: () => _showNextLesson(lessons),
                onSaveFavorite: () => _saveFavorite(selectedLesson),
                onRelated: () => _showRelatedLesson(selectedLesson, lessons),
                onLessonSelected: _selectLesson,
                favoriteRefreshToken: _favoriteRefreshToken,
              ),
            ),
          );
        },
      ),
    );
  }

  LessonModel _findSelectedLesson(List<LessonModel> lessons) {
    final lessonId = _selectedLessonId;
    if (lessonId == null) {
      return lessons.first;
    }

    return lessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => lessons.first,
    );
  }

  void _selectLesson(LessonModel lesson) {
    setState(() {
      _selectedLessonId = lesson.id;
    });
  }

  void _showNextLesson(List<LessonModel> lessons) {
    _selectLessonAtOffset(lessons, 1);
  }

  void _showPreviousLesson(List<LessonModel> lessons) {
    _selectLessonAtOffset(lessons, -1);
  }

  void _selectLessonAtOffset(List<LessonModel> lessons, int offset) {
    final currentIndex = lessons.indexWhere(
      (lesson) => lesson.id == _selectedLessonId,
    );
    final safeCurrentIndex = currentIndex == -1 ? 0 : currentIndex;
    final nextIndex = (safeCurrentIndex + offset) % lessons.length;
    _selectLesson(lessons[nextIndex]);
  }

  Future<void> _saveFavorite(LessonModel lesson) async {
    await _favoritesStorage.addFavorite(lesson.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _favoriteRefreshToken++;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado en favoritos')));
  }

  void _showRelatedLesson(
    LessonModel currentLesson,
    List<LessonModel> lessons,
  ) {
    for (final link in currentLesson.links) {
      for (final lesson in lessons) {
        if (lesson.id == link.targetLessonId) {
          _selectLesson(lesson);
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay palabra relacionada todavía')),
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
