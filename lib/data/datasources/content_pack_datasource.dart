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
      name: 'Basicas A2',
      description: 'Segundo bloque gratis para seguir practicando.',
      level: 'A2',
      isPremium: false,
      assetPath: 'assets/data/packs/free_basic_1000/a2_basic_words.json',
      totalLessons: 5,
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
