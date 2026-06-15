import 'dart:convert';

import 'package:english_drops_daily/domain/models/favorite_note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorageService {
  const FavoritesStorageService();

  static const String _favoriteLessonIdsKey = 'favorite_lesson_ids';
  static const String _notesKey = 'favorite_notes';

  Future<List<String>> getFavoriteLessonIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_favoriteLessonIdsKey) ?? const [];
  }

  Future<void> toggleFavorite(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final favoriteIds = preferences.getStringList(_favoriteLessonIdsKey) ?? [];

    if (favoriteIds.contains(lessonId)) {
      favoriteIds.remove(lessonId);
    } else {
      favoriteIds.add(lessonId);
    }

    await preferences.setStringList(_favoriteLessonIdsKey, favoriteIds);
  }

  Future<void> addFavorite(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final favoriteIds = preferences.getStringList(_favoriteLessonIdsKey) ?? [];

    if (favoriteIds.contains(lessonId)) {
      return;
    }

    favoriteIds.add(lessonId);
    await preferences.setStringList(_favoriteLessonIdsKey, favoriteIds);
  }

  Future<bool> isFavorite(String lessonId) async {
    final favoriteIds = await getFavoriteLessonIds();
    return favoriteIds.contains(lessonId);
  }

  Future<Map<String, String>> getNotes() async {
    final noteModels = await _getNoteModels();

    return noteModels.map((lessonId, model) {
      return MapEntry(lessonId, model.note);
    });
  }

  Future<void> saveNote(String lessonId, String note) async {
    final preferences = await SharedPreferences.getInstance();
    final noteModels = await _getNoteModels();
    final now = DateTime.now().toIso8601String();
    final existingNote = noteModels[lessonId];

    noteModels[lessonId] = existingNote == null
        ? FavoriteNoteModel(
            lessonId: lessonId,
            note: note,
            createdAt: now,
            updatedAt: now,
          )
        : existingNote.copyWith(note: note, updatedAt: now);

    final jsonNotes = noteModels.map((key, value) {
      return MapEntry(key, value.toJson());
    });

    await preferences.setString(_notesKey, jsonEncode(jsonNotes));
  }

  Future<String?> getNote(String lessonId) async {
    final notes = await getNotes();
    return notes[lessonId];
  }

  Future<Map<String, FavoriteNoteModel>> _getNoteModels() async {
    final preferences = await SharedPreferences.getInstance();
    final rawNotes = preferences.getString(_notesKey);

    if (rawNotes == null) {
      return {};
    }

    try {
      final jsonNotes = jsonDecode(rawNotes) as Map<String, dynamic>;
      return jsonNotes.map((lessonId, value) {
        return MapEntry(
          lessonId,
          FavoriteNoteModel.fromJson(value as Map<String, dynamic>),
        );
      });
    } on Object {
      return {};
    }
  }
}
