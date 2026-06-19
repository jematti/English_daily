import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/services/storage/lesson_history_storage_service.dart';

class LessonSelectionService {
  const LessonSelectionService([
    this._historyStorage = const LessonHistoryStorageService(),
  ]);

  final LessonHistoryStorageService _historyStorage;

  Future<LessonModel?> getNextUnseenLesson(List<LessonModel> lessons) async {
    return _getNextUnseenFrom(lessons);
  }

  Future<LessonModel?> getNextUnseenByLevel(
    List<LessonModel> lessons,
    String level,
  ) async {
    final levelLessons = lessons.where((lesson) {
      return lesson.level.toUpperCase() == level.toUpperCase();
    }).toList();

    return _getNextUnseenFrom(levelLessons);
  }

  Future<LessonModel?> getNextUnseenByPack(
    List<LessonModel> lessons,
    String packId,
  ) async {
    final packLessons = lessons.where((lesson) {
      return lesson.packId == packId;
    }).toList();

    return _getNextUnseenFrom(packLessons);
  }

  Future<LessonModel?> getFallbackLesson(List<LessonModel> lessons) async {
    if (lessons.isEmpty) {
      return null;
    }

    return lessons.first;
  }

  Future<LessonModel?> _getNextUnseenFrom(List<LessonModel> lessons) async {
    if (lessons.isEmpty) {
      return null;
    }

    final shownLessonIds = await _historyStorage.getShownLessonIds();
    for (final lesson in lessons) {
      if (!shownLessonIds.contains(lesson.id)) {
        return lesson;
      }
    }

    return getFallbackLesson(lessons);
  }
}
