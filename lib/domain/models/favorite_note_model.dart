class FavoriteNoteModel {
  const FavoriteNoteModel({
    required this.lessonId,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String lessonId;
  final String note;
  final String createdAt;
  final String updatedAt;

  factory FavoriteNoteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteNoteModel(
      lessonId: json['lessonId'] as String,
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  FavoriteNoteModel copyWith({String? note, String? updatedAt}) {
    return FavoriteNoteModel(
      lessonId: lessonId,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
