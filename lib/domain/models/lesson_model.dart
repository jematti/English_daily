import 'exercise_model.dart';

class LessonModel {
  const LessonModel({
    required this.id,
    required this.word,
    required this.meaningEs,
    required this.pronunciation,
    required this.exampleEn,
    required this.exampleEs,
    required this.usage,
    required this.grammar,
    required this.commonMistakes,
    required this.dailyUse,
    required this.exercises,
  });

  final String id;
  final String word;
  final String meaningEs;
  final String pronunciation;
  final String exampleEn;
  final String exampleEs;
  final String usage;
  final String grammar;
  final List<String> commonMistakes;
  final List<String> dailyUse;
  final List<ExerciseModel> exercises;

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      word: json['word'] as String,
      meaningEs: json['meaningEs'] as String,
      pronunciation: json['pronunciation'] as String,
      exampleEn: json['exampleEn'] as String,
      exampleEs: json['exampleEs'] as String,
      usage: json['usage'] as String,
      grammar: json['grammar'] as String,
      commonMistakes: List<String>.from(
        json['commonMistakes'] as List<dynamic>? ?? const [],
      ),
      dailyUse: List<String>.from(
        json['dailyUse'] as List<dynamic>? ?? const [],
      ),
      exercises: (json['exercises'] as List<dynamic>? ?? const []).map((
        exercise,
      ) {
        return ExerciseModel.fromJson(exercise as Map<String, dynamic>);
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaningEs': meaningEs,
      'pronunciation': pronunciation,
      'exampleEn': exampleEn,
      'exampleEs': exampleEs,
      'usage': usage,
      'grammar': grammar,
      'commonMistakes': commonMistakes,
      'dailyUse': dailyUse,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }
}
