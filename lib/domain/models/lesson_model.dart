import 'exercise_model.dart';
import 'learning_tip_model.dart';
import 'word_link_model.dart';

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
    required this.level,
    required this.isPremium,
    required this.category,
    required this.packId,
    required this.partOfSpeech,
    required this.isVerb,
    required this.verbType,
    required this.baseForm,
    required this.pastSimple,
    required this.pastParticiple,
    required this.shortNotificationText,
    required this.commonMistakes,
    required this.dailyUse,
    required this.exercises,
    required this.links,
    this.learningTip = const LearningTipModel(),
    this.timesShown,
  });

  final String id;
  final String word;
  final String meaningEs;
  final String pronunciation;
  final String exampleEn;
  final String exampleEs;
  final String usage;
  final String grammar;
  final String level;
  final bool isPremium;
  final String category;
  final String packId;
  final String? partOfSpeech;
  final bool isVerb;
  final String? verbType;
  final String? baseForm;
  final String? pastSimple;
  final String? pastParticiple;
  final String? shortNotificationText;
  final List<String> commonMistakes;
  final List<String> dailyUse;
  final List<ExerciseModel> exercises;
  final List<WordLinkModel> links;
  final LearningTipModel learningTip;
  final int? timesShown;

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
      level: json['level'] as String? ?? 'A1',
      isPremium: json['isPremium'] as bool? ?? false,
      category: json['category'] as String? ?? 'free_basic',
      packId: json['packId'] as String? ?? 'free_basic_1000',
      partOfSpeech: json['partOfSpeech'] as String?,
      isVerb: json['isVerb'] as bool? ?? false,
      verbType: json['verbType'] as String?,
      baseForm: json['baseForm'] as String?,
      pastSimple: json['pastSimple'] as String?,
      pastParticiple: json['pastParticiple'] as String?,
      shortNotificationText: json['shortNotificationText'] as String?,
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
      links: (json['links'] as List<dynamic>? ?? const []).map((link) {
        return WordLinkModel.fromJson(link as Map<String, dynamic>);
      }).toList(),
      learningTip: LearningTipModel.fromJson(json),
      timesShown: json['timesShown'] as int?,
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
      'level': level,
      'isPremium': isPremium,
      'category': category,
      'packId': packId,
      'partOfSpeech': partOfSpeech,
      'isVerb': isVerb,
      'verbType': verbType,
      'baseForm': baseForm,
      'pastSimple': pastSimple,
      'pastParticiple': pastParticiple,
      'shortNotificationText': shortNotificationText,
      'commonMistakes': commonMistakes,
      'dailyUse': dailyUse,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'links': links.map((link) => link.toJson()).toList(),
      ...learningTip.toJson(),
      'timesShown': timesShown,
    };
  }
}
