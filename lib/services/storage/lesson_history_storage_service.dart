import 'package:shared_preferences/shared_preferences.dart';

class LessonHistoryStorageService {
  const LessonHistoryStorageService();

  static const String _shownLessonIdsKey = 'shown_lesson_ids';

  Future<List<String>> getShownLessonIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_shownLessonIdsKey) ?? const [];
  }

  Future<void> markLessonAsShown(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final shownLessonIds = preferences.getStringList(_shownLessonIdsKey) ?? [];

    if (shownLessonIds.contains(lessonId)) {
      return;
    }

    shownLessonIds.add(lessonId);
    await preferences.setStringList(_shownLessonIdsKey, shownLessonIds);
  }

  Future<void> resetShownLessons() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_shownLessonIdsKey);
  }

  Future<bool> wasLessonShown(String lessonId) async {
    final shownLessonIds = await getShownLessonIds();
    return shownLessonIds.contains(lessonId);
  }
}
