enum PronunciationSpeed {
  slow,
  normal,
  fast;

  double get speechRate {
    return switch (this) {
      PronunciationSpeed.slow => 0.32,
      PronunciationSpeed.normal => 0.45,
      PronunciationSpeed.fast => 0.58,
    };
  }
}

enum AppThemePreference { light, dark, system }

class AppSettingsModel {
  const AppSettingsModel({
    required this.pronunciationSpeed,
    required this.themePreference,
    required this.showSwipeHints,
  });

  static const AppSettingsModel initial = AppSettingsModel(
    pronunciationSpeed: PronunciationSpeed.normal,
    themePreference: AppThemePreference.system,
    showSwipeHints: true,
  );

  final PronunciationSpeed pronunciationSpeed;
  final AppThemePreference themePreference;
  final bool showSwipeHints;

  AppSettingsModel copyWith({
    PronunciationSpeed? pronunciationSpeed,
    AppThemePreference? themePreference,
    bool? showSwipeHints,
  }) {
    return AppSettingsModel(
      pronunciationSpeed: pronunciationSpeed ?? this.pronunciationSpeed,
      themePreference: themePreference ?? this.themePreference,
      showSwipeHints: showSwipeHints ?? this.showSwipeHints,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      pronunciationSpeed: PronunciationSpeed.values.firstWhere(
        (value) => value.name == json['pronunciationSpeed'],
        orElse: () => PronunciationSpeed.normal,
      ),
      themePreference: AppThemePreference.values.firstWhere(
        (value) => value.name == json['themePreference'],
        orElse: () => AppThemePreference.system,
      ),
      showSwipeHints: json['showSwipeHints'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pronunciationSpeed': pronunciationSpeed.name,
      'themePreference': themePreference.name,
      'showSwipeHints': showSwipeHints,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppSettingsModel &&
            other.pronunciationSpeed == pronunciationSpeed &&
            other.themePreference == themePreference &&
            other.showSwipeHints == showSwipeHints;
  }

  @override
  int get hashCode {
    return Object.hash(pronunciationSpeed, themePreference, showSwipeHints);
  }
}
