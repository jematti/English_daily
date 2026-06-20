class LearningTipModel {
  const LearningTipModel({
    this.activeRecallPrompt,
    this.activeRecallAnswer,
    this.learningTip,
  });

  final String? activeRecallPrompt;
  final String? activeRecallAnswer;
  final String? learningTip;

  bool get hasActiveRecall {
    return _hasText(activeRecallPrompt) || _hasText(activeRecallAnswer);
  }

  bool get hasLearningTip => _hasText(learningTip);

  factory LearningTipModel.fromJson(Map<String, dynamic> json) {
    return LearningTipModel(
      activeRecallPrompt: json['activeRecallPrompt'] as String?,
      activeRecallAnswer: json['activeRecallAnswer'] as String?,
      learningTip: json['learningTip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeRecallPrompt': activeRecallPrompt,
      'activeRecallAnswer': activeRecallAnswer,
      'learningTip': learningTip,
    };
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
