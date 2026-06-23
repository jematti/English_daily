import 'dart:convert';

import 'package:english_drops_daily/domain/models/content_pack_model.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:flutter/services.dart';

class ContentPackDatasource {
  const ContentPackDatasource();

  static const List<ContentPackModel> _packs = [
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Basicas A1',
      description: 'Primer bloque de palabras basicas para empezar.',
      level: 'A1',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a1_basic_words.json',
      totalLessons: 10,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Basicas A1 batch 001',
      description: 'Primer lote ampliado de palabras A1 gratis.',
      level: 'A1',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a1_batch_001.json',
      totalLessons: 20,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Basicas A1 batch 002',
      description: 'Segundo lote ampliado de palabras A1 gratis.',
      level: 'A1',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a1_batch_002.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Basicas A2',
      description: 'Segundo bloque gratis para seguir practicando.',
      level: 'A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a2_basic_words.json',
      totalLessons: 5,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Basicas A2 batch 001',
      description: 'Primer lote ampliado de palabras A2 gratis.',
      level: 'A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a2_batch_001.json',
      totalLessons: 10,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Basicas A2 batch 002',
      description: 'Segundo lote ampliado de palabras A2 gratis.',
      level: 'A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a2_batch_002.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Verbos basicos batch 001',
      description: 'Verbos frecuentes con conjugaciones y ejemplos.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/verbs_basic_batch_001.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 003',
      description: 'Vocabulario contextual A1 y A2.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_003.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 004',
      description: 'Ingles util para viajes y ciudad.',
      level: 'A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_004.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 005',
      description: 'Casa, estudio, trabajo y tecnologia.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_005.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 006',
      description: 'Salud, emociones, tiempo y vida diaria.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_006.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 007',
      description: 'Tecnologia y comunicacion digital.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_007.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 008',
      description: 'Frases utiles para conversaciones reales.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_008.json',
      totalLessons: 100,
    ),
    ContentPackModel(
      id: 'free_basic_1000',
      name: 'Contenido gratis batch 009',
      description: 'Repaso esencial y frases de supervivencia.',
      level: 'A1 - A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/free_batch_009.json',
      totalLessons: 60,
    ),
    ContentPackModel(
      id: 'premium_preview',
      name: 'Vista previa B1',
      description: 'Muestra de contenido intermedio para Premium futuro.',
      level: 'B1',
      isPremium: true,
      assetPath: 'assets/data/packs/premium_preview/b1_preview_words.json',
      totalLessons: 3,
    ),
  ];

  Future<List<ContentPackModel>> getPacks() async {
    return _packs;
  }

  Future<List<LessonModel>> loadLessonsByPack(String packId) async {
    final packs = _packs.where((pack) => pack.id == packId);
    final lessons = <LessonModel>[];

    for (final pack in packs) {
      lessons.addAll(await loadLessonsFromAsset(pack.assetPath));
    }

    return lessons;
  }

  Future<List<LessonModel>> loadAllLessons() async {
    final lessons = <LessonModel>[];

    for (final pack in _packs) {
      lessons.addAll(await loadLessonsFromAsset(pack.assetPath));
    }

    return lessons;
  }

  Future<List<LessonModel>> loadLessonsFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    return jsonData.map((lesson) {
      return LessonModel.fromJson(lesson as Map<String, dynamic>);
    }).toList();
  }
}
