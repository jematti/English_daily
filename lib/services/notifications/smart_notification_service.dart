import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/domain/models/notification_candidate_model.dart';
import 'package:english_drops_daily/services/access/access_service.dart';
import 'package:english_drops_daily/services/lesson_selection_service.dart';
import 'package:english_drops_daily/services/progress/progress_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:english_drops_daily/services/storage/lesson_history_storage_service.dart';

class SmartNotificationService {
  SmartNotificationService([
    this._lessonDatasource = const LessonLocalDatasource(),
    this._accessService = const AccessService(),
    this._lessonSelectionService = const LessonSelectionService(),
    this._progressService = const ProgressService(),
    this._lessonHistoryStorage = const LessonHistoryStorageService(),
    this._favoritesStorage = const FavoritesStorageService(),
  ]);

  final LessonLocalDatasource _lessonDatasource;
  final AccessService _accessService;
  final LessonSelectionService _lessonSelectionService;
  final ProgressService _progressService;
  final LessonHistoryStorageService _lessonHistoryStorage;
  final FavoritesStorageService _favoritesStorage;

  Set<String> _shownLessonIds = const {};
  Set<String> _learnedLessonIds = const {};
  Set<String> _practicedLessonIds = const {};
  Set<String> _favoriteLessonIds = const {};
  String _currentLevel = 'A1';

  Future<LessonModel?> getBestLessonForNotification() async {
    final queue = await getNotificationQueue(1);
    if (queue.isEmpty) {
      return null;
    }

    return queue.first;
  }

  Future<List<LessonModel>> getNotificationQueue(int count) async {
    if (count <= 0) {
      return const [];
    }

    final lessons = await _lessonDatasource.getLessons();
    final accessibleLessons = await _accessService.filterAccessibleLessons(
      lessons,
    );
    if (accessibleLessons.isEmpty) {
      return const [];
    }

    await _loadPriorityContext();

    final unseenLessons = await _lessonSelectionService.getUnseenLessons(
      accessibleLessons,
    );
    final sourceLessons = unseenLessons.isNotEmpty
        ? _mergePriorityFallbacks(unseenLessons, accessibleLessons)
        : accessibleLessons;

    final candidates = sourceLessons.map(_candidateFor).toList()
      ..sort((a, b) {
        final priorityComparison = b.priority.compareTo(a.priority);
        if (priorityComparison != 0) {
          return priorityComparison;
        }

        return a.word.compareTo(b.word);
      });

    final selectedLessonIds = <String>{};
    final selectedLessons = <LessonModel>[];

    for (final candidate in candidates) {
      if (selectedLessonIds.contains(candidate.lessonId)) {
        continue;
      }

      final lesson = sourceLessons.firstWhere(
        (item) => item.id == candidate.lessonId,
      );
      selectedLessons.add(lesson);
      selectedLessonIds.add(lesson.id);

      if (selectedLessons.length == count) {
        break;
      }
    }

    return selectedLessons;
  }

  int calculatePriority(LessonModel lesson) {
    if (_isPendingReview(lesson)) {
      return 500;
    }

    if (!_shownLessonIds.contains(lesson.id) &&
        lesson.level.toUpperCase() == _currentLevel) {
      return 400;
    }

    if (_favoriteLessonIds.contains(lesson.id) &&
        !_practicedLessonIds.contains(lesson.id)) {
      return 300;
    }

    if (!_shownLessonIds.contains(lesson.id)) {
      return 200;
    }

    return 10;
  }

  Future<void> _loadPriorityContext() async {
    final progress = await _progressService.getProgress();
    _shownLessonIds = (await _lessonHistoryStorage.getShownLessonIds()).toSet();
    _learnedLessonIds = progress.learnedLessonIds.toSet();
    _practicedLessonIds = progress.practicedLessonIds.toSet();
    _favoriteLessonIds = (await _favoritesStorage.getFavoriteLessonIds())
        .toSet();
    _currentLevel = _progressService.currentLevelFor(progress);
  }

  List<LessonModel> _mergePriorityFallbacks(
    List<LessonModel> unseenLessons,
    List<LessonModel> accessibleLessons,
  ) {
    final unseenIds = unseenLessons.map((lesson) => lesson.id).toSet();
    final fallbackLessons = accessibleLessons.where((lesson) {
      return !unseenIds.contains(lesson.id);
    });

    return [...unseenLessons, ...fallbackLessons];
  }

  NotificationCandidateModel _candidateFor(LessonModel lesson) {
    return NotificationCandidateModel(
      lessonId: lesson.id,
      word: lesson.word,
      meaningEs: lesson.meaningEs,
      level: lesson.level,
      priority: calculatePriority(lesson),
      reason: _reasonFor(lesson),
    );
  }

  bool _isPendingReview(LessonModel lesson) {
    return _learnedLessonIds.contains(lesson.id) &&
        !_practicedLessonIds.contains(lesson.id);
  }

  String _reasonFor(LessonModel lesson) {
    if (_isPendingReview(lesson)) {
      return 'Pendiente de repaso';
    }

    if (!_shownLessonIds.contains(lesson.id) &&
        lesson.level.toUpperCase() == _currentLevel) {
      return 'Nueva palabra de tu nivel';
    }

    if (_favoriteLessonIds.contains(lesson.id) &&
        !_practicedLessonIds.contains(lesson.id)) {
      return 'Favorita sin practicar';
    }

    if (!_shownLessonIds.contains(lesson.id)) {
      return 'Nueva palabra disponible';
    }

    return 'Refuerzo general';
  }
}
