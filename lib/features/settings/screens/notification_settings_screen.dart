import 'package:english_drops_daily/data/datasources/lesson_local_datasource.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/domain/models/notification_settings_model.dart';
import 'package:english_drops_daily/services/notifications/notification_service.dart';
import 'package:english_drops_daily/services/storage/settings_storage_service.dart';
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final SettingsStorageService _storageService = const SettingsStorageService();
  final NotificationService _notificationService = NotificationService();
  final LessonLocalDatasource _lessonDatasource = const LessonLocalDatasource();

  late Future<_NotificationSettingsData> _dataFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_NotificationSettingsData> _loadData() async {
    final settings = await _storageService.getNotificationSettings();
    final lessons = await _lessonDatasource.getLessons();

    return _NotificationSettingsData(settings: settings, lessons: lessons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: FutureBuilder<_NotificationSettingsData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _MessageView(
              message: 'No pudimos cargar la configuracion.',
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const _MessageView(
              message: 'No hay configuracion disponible.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Frecuencia de aprendizaje',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'shared_preferences se usa para guardar esta preferencia localmente sin base de datos.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ..._options.map((option) {
                final isSelected = option.key == data.settings.optionKey;

                return ListTile(
                  enabled: !_isSaving,
                  onTap: _isSaving
                      ? null
                      : () => _selectOption(option.key, data.lessons),
                  title: Text(option.label),
                  trailing: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                );
              }),
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectOption(
    String? optionKey,
    List<LessonModel> lessons,
  ) async {
    if (optionKey == null) {
      return;
    }

    final settings = NotificationSettingsModel.fromOption(optionKey);

    setState(() {
      _isSaving = true;
    });

    try {
      await _storageService.saveNotificationSettings(settings);
      await _notificationService.cancelAllNotifications();

      if (settings.enabled) {
        final granted = await _notificationService.requestPermissions();
        if (!granted) {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudieron activar las notificaciones. Revisa los permisos del dispositivo.',
              ),
            ),
          );
        } else {
          await _notificationService.scheduleNotificationsBySettings(
            settings,
            lessons,
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _dataFuture = Future.value(
          _NotificationSettingsData(settings: settings, lessons: lessons),
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preferencia guardada')));
    } on Object {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos guardar la preferencia de notificaciones.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _NotificationSettingsData {
  const _NotificationSettingsData({
    required this.settings,
    required this.lessons,
  });

  final NotificationSettingsModel settings;
  final List<LessonModel> lessons;
}

class _NotificationOption {
  const _NotificationOption({required this.key, required this.label});

  final String key;
  final String label;
}

const List<_NotificationOption> _options = [
  _NotificationOption(key: 'off', label: 'Desactivadas'),
  _NotificationOption(key: 'one_daily', label: '1 al dia'),
  _NotificationOption(key: 'three_daily', label: '3 al dia'),
  _NotificationOption(key: 'five_daily', label: '5 al dia'),
  _NotificationOption(key: 'ten_daily', label: '10 al dia'),
  _NotificationOption(key: 'hourly', label: '1 cada hora'),
];

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}
