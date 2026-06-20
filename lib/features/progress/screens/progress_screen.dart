import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/domain/models/user_progress_model.dart';
import 'package:english_drops_daily/features/progress/widgets/learned_words_card.dart';
import 'package:english_drops_daily/features/progress/widgets/level_progress_card.dart';
import 'package:english_drops_daily/features/progress/widgets/practice_stats_card.dart';
import 'package:english_drops_daily/features/progress/widgets/streak_summary_card.dart';
import 'package:english_drops_daily/services/progress/progress_service.dart';
import 'package:english_drops_daily/services/storage/progress_storage_service.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressService _progressService = const ProgressService();
  final ProgressStorageService _progressStorage =
      const ProgressStorageService();
  late Future<UserProgressModel> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _progressService.getProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar progreso',
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _resetProgress,
          ),
        ],
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
        child: FutureBuilder<UserProgressModel>(
          future: _progressFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const _MessageView(
                message: 'No pudimos cargar tu progreso.',
              );
            }

            final progress = snapshot.data ?? const UserProgressModel();
            final accuracy = _progressService.accuracyPercentageFor(progress);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StreakSummaryCard(
                  currentStreak: progress.currentStreak,
                  bestStreak: progress.bestStreak,
                ),
                const SizedBox(height: 12),
                LearnedWordsCard(
                  learnedWords: progress.learnedLessonIds.length,
                  practicedWords: progress.practicedLessonIds.length,
                ),
                const SizedBox(height: 12),
                PracticeStatsCard(
                  totalSessions: progress.totalPracticeSessions,
                  correctAnswers: progress.totalCorrectAnswers,
                  wrongAnswers: progress.totalWrongAnswers,
                  accuracyPercentage: accuracy,
                ),
                const SizedBox(height: 12),
                LevelProgressCard(levelProgress: progress.levelProgress),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _resetProgress() async {
    await _progressStorage.resetProgress();

    if (!mounted) {
      return;
    }

    setState(() {
      _progressFuture = _progressService.getProgress();
    });
  }
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
