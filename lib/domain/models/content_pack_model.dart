class ContentPackModel {
  const ContentPackModel({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.isPremium,
    required this.assetPath,
    required this.totalLessons,
  });

  final String id;
  final String name;
  final String description;
  final String level;
  final bool isPremium;
  final String assetPath;
  final int totalLessons;
}
