import 'package:english_drops_daily/core/constants/app_colors.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/core/widgets/section_title.dart';
import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/dashboard/widgets/progress_summary_card.dart';
import 'package:english_drops_daily/features/dashboard/widgets/quick_actions_grid.dart';
import 'package:english_drops_daily/features/dashboard/widgets/streak_card.dart';
import 'package:english_drops_daily/features/word_of_day/screens/word_of_day_screen.dart';
import 'package:english_drops_daily/services/lesson_selection_service.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:english_drops_daily/services/storage/settings_storage_service.dart';
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
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DashboardHeader(),
                  const SizedBox(height: 24),
                  const SectionTitle(
                    title: 'Tu leccion de hoy',
                    subtitle: 'Una palabra breve para avanzar cada dia.',
                    icon: Icons.auto_stories_outlined,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 20),
                  const SectionTitle(
                    title: 'Tu progreso',
                    subtitle: 'Sigue construyendo el habito paso a paso.',
                    icon: Icons.insights_outlined,
                  ),
                  const SizedBox(height: 12),
                  const ProgressSummaryCard(),
                  const SizedBox(height: 12),
                  const StreakCard(),
                  const SizedBox(height: 20),
                  _NotificationTestButton(lessons: lessons),
                  const SizedBox(height: 20),
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
  const _NotificationTestButton({required this.lessons});

  final List<LessonModel> lessons;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Recordatorio diario',
            subtitle: 'Prueba como llegara tu proxima palabra.',
            icon: Icons.notifications_active_outlined,
          ),
          const SizedBox(height: 14),
          FutureBuilder(
            future: const SettingsStorageService().getNotificationSettings(),
            builder: (context, snapshot) {
              final settings = snapshot.data;
              final text = settings == null
                  ? 'Frecuencia inicial: 1 al dia'
                  : _settingsLabel(settings.optionKey);

              return Text(text, style: Theme.of(context).textTheme.bodySmall);
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Probar notificacion',
            icon: Icons.notifications_active_outlined,
            onPressed: () async {
              final notificationService = NotificationService();
              final granted = await notificationService.requestPermissions();

              if (!context.mounted) {
                return;
              }

              if (!granted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se pudieron activar las notificaciones. Revisa los permisos del dispositivo.',
                    ),
                  ),
                );
                return;
              }

              final wordOfDay =
                  await const LessonSelectionService().getNextUnseenLesson(
                    lessons,
                  ) ??
                  (lessons.isNotEmpty ? lessons.first : null);

              if (!context.mounted) {
                return;
              }

              if (wordOfDay == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No hay palabra del dia para notificar'),
                  ),
                );
                return;
              }

              await notificationService.showLessonNotification(wordOfDay);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificacion enviada')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _settingsLabel(String optionKey) {
    return switch (optionKey) {
      'off' => 'Notificaciones desactivadas',
      'three_daily' => 'Frecuencia actual: 3 al dia',
      'five_daily' => 'Frecuencia actual: 5 al dia',
      'ten_daily' => 'Frecuencia actual: 10 al dia',
      'hourly' => 'Frecuencia actual: 1 cada hora',
      _ => 'Frecuencia actual: 1 al dia',
    };
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            Color.lerp(colorScheme.primary, AppColors.secondary, 0.45)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English Drops Daily',
                  style: AppTextStyles.pageTitle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  'Aprende ingles en gotas diarias',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordOfDayPreview extends StatelessWidget {
  const _WordOfDayPreview({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PrimaryCard(
      color: colorScheme.primaryContainer.withValues(alpha: 0.55),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'PALABRA DEL DIA',
                style: AppTextStyles.label.copyWith(
                  color: colorScheme.primary,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(lesson.word, style: AppTextStyles.display),
          const SizedBox(height: 5),
          Text(
            lesson.meaningEs,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            lesson.exampleEn,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(lesson.exampleEs, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          AppButton(
            label: 'Ver microleccion',
            icon: Icons.arrow_forward,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WordOfDayScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(child: Text(message));
  }
}
