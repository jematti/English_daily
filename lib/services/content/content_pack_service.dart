import 'package:english_drops_daily/data/datasources/content_pack_datasource.dart';
import 'package:english_drops_daily/domain/models/content_pack_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/services/access/access_service.dart';

class ContentPackService {
  const ContentPackService([
    this._datasource = const ContentPackDatasource(),
    this._accessService = const AccessService(),
  ]);

  final ContentPackDatasource _datasource;
  final AccessService _accessService;

  Future<List<LessonModel>> loadFreeBasicLessons() {
    return loadLessonsByPack('free_basic_1000');
  }

  Future<List<LessonModel>> loadLessonsByPack(String packId) {
    return _datasource.loadLessonsByPack(packId);
  }

  Future<List<LessonModel>> loadAllAccessibleLessons() async {
    final lessons = await _datasource.loadAllLessons();
    return _accessService.filterAccessibleLessons(lessons);
  }

  Future<List<ContentPackModel>> getAvailablePacks() {
    return _datasource.getPacks();
  }
}
