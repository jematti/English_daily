class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>? ?? const []),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}
