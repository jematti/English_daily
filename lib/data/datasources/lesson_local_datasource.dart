import 'dart:convert';

import 'package:english_drops_daily/data/datasources/content_pack_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:flutter/services.dart';

class LessonLocalDatasource {
  const LessonLocalDatasource();

  Future<List<LessonModel>> getLessons() async {
    final packedLessons = await _getPackedLessons();
    if (packedLessons.isNotEmpty) {
      return packedLessons;
    }

    final jsonString = await rootBundle.loadString('assets/data/lessons.json');
    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    return jsonData.map((lesson) {
      return LessonModel.fromJson(lesson as Map<String, dynamic>);
    }).toList();
  }

  Future<List<LessonModel>> _getPackedLessons() async {
    try {
      return const ContentPackDatasource().loadAllLessons();
    } on Object {
      return const [];
    }
  }
}
