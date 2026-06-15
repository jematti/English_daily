import 'package:english_drops_daily/domain/models/app_settings_model.dart';
import 'package:english_drops_daily/features/settings/screens/notification_settings_screen.dart';
import 'package:english_drops_daily/services/storage/app_settings_storage_service.dart';
import 'package:english_drops_daily/services/storage/favorites_storage_service.dart';
import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final AppSettingsStorageService _settingsStorage =
      const AppSettingsStorageService();
  final FavoritesStorageService _favoritesStorage =
      const FavoritesStorageService();

  AppSettingsModel? _settings;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsStorage.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SettingsSection(
                  title: 'Pronunciacion',
                  child: DropdownButtonFormField<PronunciationSpeed>(
                    initialValue: settings.pronunciationSpeed,
                    decoration: const InputDecoration(
                      labelText: 'Velocidad de pronunciacion',
                      border: OutlineInputBorder(),
                    ),
                    items: PronunciationSpeed.values.map((speed) {
                      return DropdownMenuItem(
                        value: speed,
                        child: Text(_speedLabel(speed)),
                      );
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (speed) {
                            if (speed != null) {
                              _save(
                                settings.copyWith(pronunciationSpeed: speed),
                              );
                            }
                          },
                  ),
                ),
                _SettingsSection(
                  title: 'Apariencia',
                  child: DropdownButtonFormField<AppThemePreference>(
                    initialValue: settings.themePreference,
                    decoration: const InputDecoration(
                      labelText: 'Tema visual',
                      border: OutlineInputBorder(),
                    ),
                    items: AppThemePreference.values.map((theme) {
                      return DropdownMenuItem(
                        value: theme,
                        child: Text(_themeLabel(theme)),
                      );
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (theme) {
                            if (theme != null) {
                              _save(settings.copyWith(themePreference: theme));
                            }
                          },
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostrar ayuda de gestos'),
                  subtitle: const Text('Muestra las flechas sobre la tarjeta.'),
                  value: settings.showSwipeHints,
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          _save(settings.copyWith(showSwipeHints: value));
                        },
                ),
                const Divider(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Configurar notificaciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 32),
                Text(
                  'Datos locales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _confirmResetProgress,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reiniciar progreso'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _confirmResetFavorites,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Reiniciar favoritos y notas'),
                ),
              ],
            ),
    );
  }

  Future<void> _save(AppSettingsModel settings) async {
    setState(() => _isSaving = true);
    await _settingsStorage.saveSettings(settings);
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
      _isSaving = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configuracion guardada')));
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await _confirm(
      title: 'Reiniciar progreso',
      message: 'Se eliminara el progreso de aprendizaje guardado localmente.',
    );
    if (!confirmed) {
      return;
    }
    await _settingsStorage.resetProgress();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Progreso reiniciado')));
    }
  }

  Future<void> _confirmResetFavorites() async {
    final confirmed = await _confirm(
      title: 'Reiniciar favoritos y notas',
      message: 'Se eliminaran todos tus favoritos y notas personales.',
    );
    if (!confirmed) {
      return;
    }
    await _favoritesStorage.clearAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favoritos y notas reiniciados')),
      );
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  String _speedLabel(PronunciationSpeed speed) {
    return switch (speed) {
      PronunciationSpeed.slow => 'Lenta',
      PronunciationSpeed.normal => 'Normal',
      PronunciationSpeed.fast => 'Rapida',
    };
  }

  String _themeLabel(AppThemePreference theme) {
    return switch (theme) {
      AppThemePreference.light => 'Claro',
      AppThemePreference.dark => 'Oscuro',
      AppThemePreference.system => 'Sistema',
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
