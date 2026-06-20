import 'package:english_drops_daily/domain/models/user_progress_model.dart';
import 'package:english_drops_daily/services/storage/progress_storage_service.dart';

class ProgressService {
  const ProgressService([
    this._storage = const ProgressStorageService(),
    DateTime Function()? nowProvider,
  ]) : _nowProvider = nowProvider;

  final ProgressStorageService _storage;
  final DateTime Function()? _nowProvider;

  Future<UserProgressModel> getProgress() {
    return _storage.getProgress();
  }

  Future<void> markLessonLearned(String lessonId, String level) async {
    final progress = await _storage.getProgress();
    final learnedLessonIds = _addUnique(progress.learnedLessonIds, lessonId);
    final levelKey = level.toUpperCase();
    final levelProgress = Map<String, int>.from(progress.levelProgress);
    levelProgress[levelKey] =
        learnedLessonIds.contains(lessonId) &&
            !progress.learnedLessonIds.contains(lessonId)
        ? (levelProgress[levelKey] ?? 0) + 1
        : levelProgress[levelKey] ?? 0;

    final updatedProgress = _withUpdatedStreak(
      progress.copyWith(
        learnedLessonIds: learnedLessonIds,
        levelProgress: levelProgress,
      ),
    );

    await _storage.saveProgress(updatedProgress);
  }

  Future<void> savePracticeResult({
    required String lessonId,
    required int correctAnswers,
    required int wrongAnswers,
  }) async {
    final progress = await _storage.getProgress();
    final updatedProgress = _withUpdatedStreak(
      progress.copyWith(
        practicedLessonIds: _addUnique(progress.practicedLessonIds, lessonId),
        totalPracticeSessions: progress.totalPracticeSessions + 1,
        totalCorrectAnswers: progress.totalCorrectAnswers + correctAnswers,
        totalWrongAnswers: progress.totalWrongAnswers + wrongAnswers,
      ),
    );

    await _storage.saveProgress(updatedProgress);
  }

  Future<void> updateDailyStreak() async {
    final progress = await _storage.getProgress();
    await _storage.saveProgress(_withUpdatedStreak(progress));
  }

  Future<int> getAccuracyPercentage() async {
    final progress = await _storage.getProgress();
    return accuracyPercentageFor(progress);
  }

  Future<Map<String, int>> getLevelProgress() async {
    final progress = await _storage.getProgress();
    return progress.levelProgress;
  }

  int accuracyPercentageFor(UserProgressModel progress) {
    if (progress.totalAnswers == 0) {
      return 0;
    }

    return ((progress.totalCorrectAnswers / progress.totalAnswers) * 100)
        .round();
  }

  UserProgressModel _withUpdatedStreak(UserProgressModel progress) {
    final today = _formatDate(_today());
    final lastStudyDate = progress.lastStudyDate;

    if (lastStudyDate == today) {
      return progress;
    }

    final yesterday = _formatDate(_today().subtract(const Duration(days: 1)));
    final nextStreak = lastStudyDate == yesterday
        ? progress.currentStreak + 1
        : 1;

    return progress.copyWith(
      currentStreak: nextStreak,
      bestStreak: nextStreak > progress.bestStreak
          ? nextStreak
          : progress.bestStreak,
      lastStudyDate: today,
    );
  }

  DateTime _today() {
    final now = _nowProvider?.call() ?? DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _formatDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().split('T').first;
  }

  List<String> _addUnique(List<String> items, String value) {
    if (items.contains(value)) {
      return items;
    }

    return [...items, value];
  }
}
