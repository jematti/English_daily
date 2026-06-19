import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/dashboard/screens/dashboard_screen.dart';
import 'package:english_drops_daily/features/exercises/screens/exercises_screen.dart';
import 'package:english_drops_daily/features/favorites/screens/favorites_screen.dart';
import 'package:english_drops_daily/features/premium/screens/premium_preview_screen.dart';
import 'package:english_drops_daily/features/progress/screens/review_screen.dart';
import 'package:english_drops_daily/features/settings/screens/app_settings_screen.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/swipe_lesson_card.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/word_of_day_fab.dart';
import 'package:english_drops_daily/services/access/access_service.dart';
import 'package:english_drops_daily/services/lesson_selection_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:english_drops_daily/services/storage/lesson_history_storage_service.dart';
import 'package:flutter/material.dart';

class HomeMicrolessonScreen extends StatefulWidget {
  const HomeMicrolessonScreen({
    super.key,
    this.initialLessonId,
    this.showAppBar = false,
  });

  final String? initialLessonId;
  final bool showAppBar;

  @override
  State<HomeMicrolessonScreen> createState() => _HomeMicrolessonScreenState();
}

class _HomeMicrolessonScreenState extends State<HomeMicrolessonScreen> {
  late final Future<List<LessonModel>> _lessonsFuture;
  final FavoritesStorageService _favoritesStorage =
      const FavoritesStorageService();
  final LessonHistoryStorageService _lessonHistoryStorage =
      const LessonHistoryStorageService();
  final LessonSelectionService _lessonSelectionService =
      const LessonSelectionService();
  final AccessService _accessService = const AccessService();
  String? _selectedLessonId;
  int _favoriteRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _selectedLessonId = widget.initialLessonId;
    _lessonsFuture = _loadLessons();
  }

  Future<List<LessonModel>> _loadLessons() async {
    final lessons = await const LessonLocalDatasource().getLessons();
    if (lessons.isEmpty) {
      return lessons;
    }

    final initialLesson = _findLessonById(lessons, widget.initialLessonId);
    final accessibleLessons = await _accessService.filterAccessibleLessons(
      lessons,
    );

    if (initialLesson != null &&
        !await _accessService.canAccessLesson(initialLesson)) {
      _openPremiumPreviewAfterBuild();
    }

    if (accessibleLessons.isEmpty) {
      return accessibleLessons;
    }

    final canUseInitialLesson =
        initialLesson != null &&
        await _accessService.canAccessLesson(initialLesson);
    final selectedLesson = canUseInitialLesson
        ? initialLesson
        : await _lessonSelectionService.getNextUnseenLesson(
                accessibleLessons,
              ) ??
              accessibleLessons.first;

    _selectedLessonId = selectedLesson.id;
    await _lessonHistoryStorage.markLessonAsShown(selectedLesson.id);

    return accessibleLessons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: !widget.showAppBar,
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Microleccion'))
          : null,
      floatingActionButton: FutureBuilder<List<LessonModel>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          final lessons = snapshot.data ?? const [];
          if (lessons.isEmpty) {
            return const SizedBox.shrink();
          }

          return WordOfDayFab(
            lesson: lessons.first,
            onOpen: () => _selectLesson(lessons.first),
          );
        },
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppPalette.background,
              AppPalette.surfaceCool,
              AppPalette.surfaceWarm,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<LessonModel>>(
            future: _lessonsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const _MessageView(
                  message:
                      'No pudimos cargar tu microleccion. Intentalo de nuevo.',
                );
              }

              final lessons = snapshot.data ?? const [];
              if (lessons.isEmpty) {
                return const _MessageView(
                  message: 'No hay microlecciones disponibles por ahora.',
                );
              }

              final selectedLesson = _findSelectedLesson(lessons);

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HomeHeader(
                          currentIndex:
                              lessons.indexWhere(
                                (lesson) => lesson.id == selectedLesson.id,
                              ) +
                              1,
                          totalLessons: lessons.length,
                        ),
                        const SizedBox(height: 16),
                        SwipeLessonCard(
                          lesson: selectedLesson,
                          lessons: lessons,
                          onPrevious: () => _showPreviousLesson(lessons),
                          onNext: () => _showNextLesson(lessons),
                          onSaveFavorite: () => _saveFavorite(selectedLesson),
                          onRelated: () =>
                              _showRelatedLesson(selectedLesson, lessons),
                          onLessonSelected: _selectLesson,
                          favoriteRefreshToken: _favoriteRefreshToken,
                        ),
                        const SizedBox(height: 16),
                        _QuickDock(onOpen: _openSecondaryScreen),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  LessonModel _findSelectedLesson(List<LessonModel> lessons) {
    final lessonId = _selectedLessonId;
    if (lessonId == null) {
      return lessons.first;
    }

    return _findLessonById(lessons, lessonId) ?? lessons.first;
  }

  LessonModel? _findLessonById(List<LessonModel> lessons, String? lessonId) {
    if (lessonId == null) {
      return null;
    }

    for (final lesson in lessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }

    return null;
  }

  void _selectLesson(LessonModel lesson) {
    _selectAccessibleLesson(lesson);
  }

  Future<void> _selectAccessibleLesson(LessonModel lesson) async {
    if (!await _accessService.canAccessLesson(lesson)) {
      if (!mounted) {
        return;
      }

      _openPremiumPreview();
      return;
    }

    await _lessonHistoryStorage.markLessonAsShown(lesson.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLessonId = lesson.id;
    });
  }

  Future<void> _showNextLesson(List<LessonModel> lessons) async {
    final nextUnseenLesson = await _lessonSelectionService.getNextUnseenLesson(
      lessons,
    );

    if (!mounted) {
      return;
    }

    if (nextUnseenLesson != null && nextUnseenLesson.id != _selectedLessonId) {
      _selectLesson(nextUnseenLesson);
      return;
    }

    _selectLessonAtOffset(lessons, 1);
  }

  void _showPreviousLesson(List<LessonModel> lessons) {
    _selectLessonAtOffset(lessons, -1);
  }

  void _selectLessonAtOffset(List<LessonModel> lessons, int offset) {
    final currentIndex = lessons.indexWhere(
      (lesson) => lesson.id == _selectedLessonId,
    );
    final safeCurrentIndex = currentIndex == -1 ? 0 : currentIndex;
    final nextIndex = (safeCurrentIndex + offset) % lessons.length;
    _selectLesson(lessons[nextIndex]);
  }

  Future<void> _saveFavorite(LessonModel lesson) async {
    await _favoritesStorage.addFavorite(lesson.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _favoriteRefreshToken++;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado en favoritos')));
  }

  void _showRelatedLesson(
    LessonModel currentLesson,
    List<LessonModel> lessons,
  ) {
    for (final link in currentLesson.links) {
      for (final lesson in lessons) {
        if (lesson.id == link.targetLessonId) {
          _selectLesson(lesson);
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay palabra relacionada todavia')),
    );
  }

  void _openSecondaryScreen(_HomeDestination destination) {
    final screen = switch (destination) {
      _HomeDestination.exercises => const ExercisesScreen(),
      _HomeDestination.favorites => const FavoritesScreen(),
      _HomeDestination.review => const ReviewScreen(),
      _HomeDestination.settings => const AppSettingsScreen(),
      _HomeDestination.dashboard => const DashboardScreen(),
      _HomeDestination.premium => const PremiumPreviewScreen(),
    };

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openPremiumPreviewAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _openPremiumPreview();
    });
  }

  void _openPremiumPreview() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PremiumPreviewScreen()),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.currentIndex, required this.totalLessons});

  final int currentIndex;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aprende ahora',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Microleccion $currentIndex de $totalLessons',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppPalette.sunshine.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, size: 18),
              const SizedBox(width: 6),
              Text('Gota diaria', style: AppTextStyles.label),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickDock extends StatelessWidget {
  const _QuickDock({required this.onOpen});

  final ValueChanged<_HomeDestination> onOpen;

  @override
  Widget build(BuildContext context) {
    const items = [
      _DockItem(_HomeDestination.exercises, Icons.quiz_outlined, 'Ejercicios'),
      _DockItem(_HomeDestination.favorites, Icons.favorite_border, 'Favoritos'),
      _DockItem(_HomeDestination.review, Icons.replay_outlined, 'Repasos'),
      _DockItem(_HomeDestination.settings, Icons.settings_outlined, 'Ajustes'),
      _DockItem(_HomeDestination.dashboard, Icons.dashboard_outlined, 'Centro'),
      _DockItem(
        _HomeDestination.premium,
        Icons.workspace_premium_outlined,
        'Premium',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return ActionChip(
            avatar: Icon(item.icon, size: 18),
            label: Text(item.label),
            onPressed: () => onOpen(item.destination),
          );
        }).toList(),
      ),
    );
  }
}

enum _HomeDestination {
  exercises,
  favorites,
  review,
  settings,
  dashboard,
  premium,
}

class _DockItem {
  const _DockItem(this.destination, this.icon, this.label);

  final _HomeDestination destination;
  final IconData icon;
  final String label;
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
