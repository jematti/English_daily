import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/services/storage/user_access_storage_service.dart';

class AccessService {
  const AccessService([
    this._storageService = const UserAccessStorageService(),
  ]);

  final UserAccessStorageService _storageService;

  Future<bool> canAccessLesson(LessonModel lesson) async {
    final access = await _storageService.getUserAccess();

    if (access.isPremium) {
      return true;
    }

    return !lesson.isPremium &&
        access.unlockedPackIds.contains(lesson.packId) &&
        access.unlockedLevels.contains(lesson.level.toUpperCase());
  }

  Future<List<LessonModel>> filterAccessibleLessons(
    List<LessonModel> lessons,
  ) async {
    final accessibleLessons = <LessonModel>[];

    for (final lesson in lessons) {
      if (await canAccessLesson(lesson)) {
        accessibleLessons.add(lesson);
      }
    }

    return accessibleLessons;
  }

  Future<bool> canAccessPack(String packId) async {
    final access = await _storageService.getUserAccess();
    return access.isPremium || access.unlockedPackIds.contains(packId);
  }

  Future<bool> canAccessLevel(String level) async {
    final access = await _storageService.getUserAccess();
    return access.isPremium ||
        access.unlockedLevels.contains(level.toUpperCase());
  }
}
