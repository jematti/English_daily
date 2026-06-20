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

  Future<List<ContentPackModel>> getFreePacks() async {
    final packs = await getAvailablePacks();
    return packs.where((pack) => !pack.isPremium).toList();
  }

  Future<List<ContentPackModel>> getPremiumPreviewPacks() async {
    final packs = await getAvailablePacks();
    return packs.where((pack) => pack.isPremium).toList();
  }

  List<ContentPackModel> getUpcomingPremiumPacks() {
    return const [
      ContentPackModel(
        id: 'premium_5000',
        name: 'Premium 5000 palabras',
        description: 'Vocabulario amplio para avanzar desde bases solidas.',
        level: 'A1 - B2',
        isPremium: true,
        assetPath: '',
        totalLessons: 5000,
      ),
      ContentPackModel(
        id: 'premium_10000',
        name: 'Premium 10000+ palabras',
        description: 'Ruta completa para estudio continuo y repaso profundo.',
        level: 'A1 - C1',
        isPremium: true,
        assetPath: '',
        totalLessons: 10000,
      ),
      ContentPackModel(
        id: 'irregular_verbs',
        name: 'Verbos irregulares',
        description: 'Formas verbales, ejemplos y practica enfocada.',
        level: 'A2 - B2',
        isPremium: true,
        assetPath: '',
        totalLessons: 250,
      ),
      ContentPackModel(
        id: 'phrasal_verbs',
        name: 'Phrasal verbs',
        description: 'Phrasal verbs frecuentes con contexto real.',
        level: 'B1 - C1',
        isPremium: true,
        assetPath: '',
        totalLessons: 600,
      ),
      ContentPackModel(
        id: 'travel_english',
        name: 'Ingles para viajes',
        description: 'Frases utiles para aeropuertos, hoteles y ciudad.',
        level: 'A1 - B1',
        isPremium: true,
        assetPath: '',
        totalLessons: 400,
      ),
      ContentPackModel(
        id: 'work_english',
        name: 'Ingles para trabajo',
        description: 'Vocabulario para reuniones, correos y entrevistas.',
        level: 'B1 - C1',
        isPremium: true,
        assetPath: '',
        totalLessons: 700,
      ),
      ContentPackModel(
        id: 'tech_english',
        name: 'Ingles tecnologico',
        description: 'Terminos utiles para software, datos y producto.',
        level: 'B1 - C1',
        isPremium: true,
        assetPath: '',
        totalLessons: 500,
      ),
    ];
  }
}
