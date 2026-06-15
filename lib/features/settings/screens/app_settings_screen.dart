import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/core/widgets/section_title.dart';
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
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                Text(
                  'Personaliza tu experiencia sin perder tus avances.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                _SettingsSection(
                  title: 'Pronunciacion',
                  subtitle: 'Ajusta el ritmo del audio en ingles.',
                  icon: Icons.record_voice_over_outlined,
                  child: DropdownButtonFormField<PronunciationSpeed>(
                    initialValue: settings.pronunciationSpeed,
                    decoration: const InputDecoration(
                      labelText: 'Velocidad de pronunciacion',
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
                const SizedBox(height: 14),
                _SettingsSection(
                  title: 'Apariencia',
                  subtitle: 'Elige como quieres ver la aplicacion.',
                  icon: Icons.palette_outlined,
                  child: DropdownButtonFormField<AppThemePreference>(
                    initialValue: settings.themePreference,
                    decoration: const InputDecoration(labelText: 'Tema visual'),
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
                const SizedBox(height: 14),
                PrimaryCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      Icons.swipe_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Mostrar ayuda de gestos'),
                    subtitle: const Text(
                      'Muestra las direcciones disponibles sobre la tarjeta.',
                    ),
                    value: settings.showSwipeHints,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            _save(settings.copyWith(showSwipeHints: value));
                          },
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Notificaciones',
                        subtitle: 'Elige cuando recibir nuevas palabras.',
                        icon: Icons.notifications_outlined,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Configurar notificaciones',
                        icon: Icons.arrow_forward,
                        variant: AppButtonVariant.tonal,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Datos locales',
                        subtitle: 'Estas acciones requieren confirmacion.',
                        icon: Icons.storage_outlined,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Reiniciar progreso',
                        icon: Icons.restart_alt,
                        variant: AppButtonVariant.outlined,
                        onPressed: _isSaving ? null : _confirmResetProgress,
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        label: 'Reiniciar favoritos y notas',
                        icon: Icons.delete_outline,
                        variant: AppButtonVariant.danger,
                        onPressed: _isSaving ? null : _confirmResetFavorites,
                      ),
                    ],
                  ),
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
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, subtitle: subtitle, icon: icon),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
