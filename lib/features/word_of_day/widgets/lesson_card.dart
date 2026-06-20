import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/core/widgets/section_title.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/microlearning_sections.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/word_link_suggestions.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:english_drops_daily/services/tts/tts_service.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatefulWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.lessons = const [],
    this.onLessonSelected,
    this.showHeader = true,
    this.showAudioActions = true,
    this.showPersonalNotebook = true,
    this.favoriteRefreshToken = 0,
  });

  final LessonModel lesson;
  final List<LessonModel> lessons;
  final ValueChanged<LessonModel>? onLessonSelected;
  final bool showHeader;
  final bool showAudioActions;
  final bool showPersonalNotebook;
  final int favoriteRefreshToken;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  final TtsService _ttsService = TtsService();
  final FavoritesStorageService _favoritesStorage =
      const FavoritesStorageService();
  final TextEditingController _noteController = TextEditingController();
  bool _isFavorite = false;
  bool _isLoadingFavoriteData = true;

  LessonModel get lesson => widget.lesson;

  @override
  void initState() {
    super.initState();
    _loadFavoriteData();
  }

  @override
  void didUpdateWidget(covariant LessonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.id != widget.lesson.id ||
        oldWidget.favoriteRefreshToken != widget.favoriteRefreshToken) {
      _loadFavoriteData();
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) ...[
            Text(lesson.word, style: AppTextStyles.display),
            const SizedBox(height: 6),
            Text(
              lesson.meaningEs,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              lesson.pronunciation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.showAudioActions) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(
                  label: 'Escuchar palabra',
                  icon: Icons.volume_up_outlined,
                  expanded: false,
                  onPressed: () => _speakWord(context),
                ),
                AppButton(
                  label: 'Escuchar ejemplo',
                  icon: Icons.record_voice_over_outlined,
                  variant: AppButtonVariant.tonal,
                  expanded: false,
                  onPressed: () => _speakExample(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'El audio depende del motor de texto a voz del dispositivo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
          ],
          if (widget.showPersonalNotebook) ...[
            _FavoriteNoteSection(
              isFavorite: _isFavorite,
              isLoading: _isLoadingFavoriteData,
              noteController: _noteController,
              onToggleFavorite: _toggleFavorite,
              onSaveNote: _saveNote,
            ),
            const SizedBox(height: 24),
          ],
          MicrolearningSections(lesson: lesson),
          const SizedBox(height: 10),
          WordLinkSuggestions(
            currentLesson: lesson,
            lessons: widget.lessons,
            onLessonSelected: (selectedLesson) {
              widget.onLessonSelected?.call(selectedLesson);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _speakWord(BuildContext context) async {
    await _speak(context, () => _ttsService.speakWord(lesson.word));
  }

  Future<void> _speakExample(BuildContext context) async {
    await _speak(context, () => _ttsService.speakSentence(lesson.exampleEn));
  }

  Future<void> _speak(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo reproducir audio en este dispositivo. Prueba en un celular fisico o revisa el motor de texto a voz.',
          ),
        ),
      );
    }
  }

  Future<void> _loadFavoriteData() async {
    setState(() {
      _isLoadingFavoriteData = true;
    });

    final isFavorite = await _favoritesStorage.isFavorite(lesson.id);
    final note = await _favoritesStorage.getNote(lesson.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
      _noteController.text = note ?? '';
      _isLoadingFavoriteData = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoritesStorage.toggleFavorite(lesson.id);
    final isFavorite = await _favoritesStorage.isFavorite(lesson.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Agregado a favoritos' : 'Quitado de favoritos',
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    await _favoritesStorage.saveNote(lesson.id, _noteController.text.trim());

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nota guardada')));
  }
}

class _FavoriteNoteSection extends StatelessWidget {
  const _FavoriteNoteSection({
    required this.isFavorite,
    required this.isLoading,
    required this.noteController,
    required this.onToggleFavorite,
    required this.onSaveNote,
  });

  final bool isFavorite;
  final bool isLoading;
  final TextEditingController noteController;
  final VoidCallback onToggleFavorite;
  final VoidCallback onSaveNote;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cuaderno personal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppButton(
            label: isFavorite ? 'Favorito activo' : 'Agregar favorito',
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            variant: AppButtonVariant.outlined,
            expanded: false,
            onPressed: isLoading ? null : onToggleFavorite,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Nota personal',
              hintText: 'Escribe una idea para recordar esta palabra.',
            ),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Guardar nota',
            icon: Icons.save_outlined,
            expanded: false,
            onPressed: isLoading ? null : onSaveNote,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
