import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/favorites/widgets/favorite_lesson_card.dart';
import 'package:english_drops_daily/services/access/access_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesStorageService _favoritesStorage =
      const FavoritesStorageService();
  late Future<_FavoritesData> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<_FavoritesData> _loadFavorites() async {
    final lessons = await const LessonLocalDatasource().getLessons();
    final accessibleLessons = await const AccessService()
        .filterAccessibleLessons(lessons);
    final favoriteIds = await _favoritesStorage.getFavoriteLessonIds();
    final notes = await _favoritesStorage.getNotes();
    final favoriteLessons = accessibleLessons.where((lesson) {
      return favoriteIds.contains(lesson.id);
    }).toList();

    return _FavoritesData(lessons: favoriteLessons, notes: notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: FutureBuilder<_FavoritesData>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _MessageView(
              message: 'No pudimos cargar tus favoritos.',
            );
          }

          final data = snapshot.data;
          if (data == null || data.lessons.isEmpty) {
            return const _MessageView(
              message: 'Todavia no tienes palabras favoritas.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = data.lessons[index];
              return FavoriteLessonCard(
                lesson: lesson,
                note: data.notes[lesson.id],
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoritesData {
  const _FavoritesData({required this.lessons, required this.notes});

  final List<LessonModel> lessons;
  final Map<String, String> notes;
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
