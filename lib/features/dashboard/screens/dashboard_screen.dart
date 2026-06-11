import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/dashboard/widgets/progress_summary_card.dart';
import 'package:english_drops_daily/features/dashboard/widgets/quick_actions_grid.dart';
import 'package:english_drops_daily/features/dashboard/widgets/streak_card.dart';
import 'package:english_drops_daily/features/word_of_day/screens/word_of_day_screen.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<List<LessonModel>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = const LessonLocalDatasource().getLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<LessonModel>>(
          future: _lessonsFuture,
          builder: (context, snapshot) {
            final lessons = snapshot.data ?? const [];
            final lesson = lessons.isNotEmpty ? lessons.first : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DashboardHeader(),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    const _MessageCard(
                      message:
                          'No pudimos cargar la palabra del dia. Intentalo de nuevo.',
                    )
                  else if (lesson == null)
                    const _MessageCard(
                      message: 'No hay lecciones disponibles por ahora.',
                    )
                  else
                    _WordOfDayPreview(lesson: lesson),
                  const SizedBox(height: 16),
                  const ProgressSummaryCard(),
                  const SizedBox(height: 16),
                  const StreakCard(),
                  const SizedBox(height: 16),
                  _NotificationTestButton(),
                  const SizedBox(height: 16),
                  const QuickActionsGrid(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () async {
          final notificationService = NotificationService();
          final granted = await notificationService.requestPermissions();

          if (!context.mounted) {
            return;
          }

          if (!granted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permiso de notificaciones no concedido'),
              ),
            );
            return;
          }

          await notificationService.showTestNotification();

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Notificacion enviada')));
        },
        icon: const Icon(Icons.notifications_active_outlined),
        label: const Text('Probar notificacion'),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'English Drops Daily',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Aprende ingles en gotas diarias',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _WordOfDayPreview extends StatelessWidget {
  const _WordOfDayPreview({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Palabra del dia',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              lesson.word,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(lesson.meaningEs),
            const SizedBox(height: 10),
            Text(
              lesson.exampleEn,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(lesson.exampleEs),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WordOfDayScreen(),
                    ),
                  );
                },
                child: const Text('Ver microleccion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
    );
  }
}
