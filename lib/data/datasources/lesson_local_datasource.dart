import 'dart:convert';

import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:flutter/services.dart';

class LessonLocalDatasource {
  const LessonLocalDatasource();

  Future<List<LessonModel>> getLessons() async {
    final jsonString = await rootBundle.loadString('assets/data/lessons.json');
    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    return jsonData.map((lesson) {
      return LessonModel.fromJson(lesson as Map<String, dynamic>);
    }).toList();
  }
}
