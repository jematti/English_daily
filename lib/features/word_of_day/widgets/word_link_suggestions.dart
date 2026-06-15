import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/domain/models/word_link_model.dart';
import 'package:flutter/material.dart';

class WordLinkSuggestions extends StatelessWidget {
  const WordLinkSuggestions({
    super.key,
    required this.currentLesson,
    required this.lessons,
    required this.onLessonSelected,
  });

  final LessonModel currentLesson;
  final List<LessonModel> lessons;
  final ValueChanged<LessonModel> onLessonSelected;

  @override
  Widget build(BuildContext context) {
    final suggestions = _buildSuggestions().take(4).toList();

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continua aprendiendo',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SuggestionTile(
                suggestion: suggestion,
                onTap: () => onLessonSelected(suggestion.lesson),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<_ResolvedWordLink> _buildSuggestions() {
    final resolvedLinks = currentLesson.links
        .map(_resolveLink)
        .whereType<_ResolvedWordLink>()
        .toList();

    if (resolvedLinks.isNotEmpty) {
      return resolvedLinks;
    }

    final fallbackLesson = _nextLesson();
    if (fallbackLesson == null) {
      return const [];
    }

    return [
      _ResolvedWordLink(
        lesson: fallbackLesson,
        link: WordLinkModel(
          targetLessonId: fallbackLesson.id,
          label: fallbackLesson.word,
          type: 'next',
          reason: 'Sigue con otra palabra recomendada.',
        ),
      ),
    ];
  }

  _ResolvedWordLink? _resolveLink(WordLinkModel link) {
    for (final lesson in lessons) {
      if (lesson.id == link.targetLessonId) {
        return _ResolvedWordLink(lesson: lesson, link: link);
      }
    }

    return null;
  }

  LessonModel? _nextLesson() {
    if (lessons.length < 2) {
      return null;
    }

    final currentIndex = lessons.indexWhere(
      (lesson) => lesson.id == currentLesson.id,
    );
    final nextIndex = currentIndex == -1
        ? 0
        : (currentIndex + 1) % lessons.length;
    final nextLesson = lessons[nextIndex];

    return nextLesson.id == currentLesson.id ? null : nextLesson;
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final _ResolvedWordLink suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.link.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(_typeLabel(suggestion.link.type)),
                  const SizedBox(height: 4),
                  Text(suggestion.link.reason),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'synonym' => 'Sinonimo',
      'antonym' => 'Antonimo',
      'conjugation' => 'Conjugacion',
      'related' => 'Relacionada',
      'next' => 'Siguiente',
      _ => 'Sugerencia',
    };
  }
}

class _ResolvedWordLink {
  const _ResolvedWordLink({required this.lesson, required this.link});

  final LessonModel lesson;
  final WordLinkModel link;
}
