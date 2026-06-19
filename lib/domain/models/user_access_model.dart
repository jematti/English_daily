class UserAccessModel {
  const UserAccessModel({
    required this.isPremium,
    required this.unlockedPackIds,
    required this.unlockedLevels,
  });

  final bool isPremium;
  final List<String> unlockedPackIds;
  final List<String> unlockedLevels;

  static const UserAccessModel free = UserAccessModel(
    isPremium: false,
    unlockedPackIds: ['free_basic_1000'],
    unlockedLevels: ['A1', 'A2'],
  );

  factory UserAccessModel.fromJson(Map<String, dynamic> json) {
    return UserAccessModel(
      isPremium: json['isPremium'] as bool? ?? free.isPremium,
      unlockedPackIds: List<String>.from(
        json['unlockedPackIds'] as List<dynamic>? ?? free.unlockedPackIds,
      ),
      unlockedLevels: List<String>.from(
        json['unlockedLevels'] as List<dynamic>? ?? free.unlockedLevels,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'unlockedPackIds': unlockedPackIds,
      'unlockedLevels': unlockedLevels,
    };
  }
}
