class NotificationSettingsModel {
  const NotificationSettingsModel({
    required this.enabled,
    required this.frequencyType,
    required this.notificationsPerDay,
    required this.startHour,
    required this.endHour,
  });

  final bool enabled;
  final String frequencyType;
  final int notificationsPerDay;
  final int startHour;
  final int endHour;

  static const NotificationSettingsModel initial = NotificationSettingsModel(
    enabled: true,
    frequencyType: 'daily',
    notificationsPerDay: 1,
    startHour: 8,
    endHour: 20,
  );

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enabled: json['enabled'] as bool? ?? initial.enabled,
      frequencyType: json['frequencyType'] as String? ?? initial.frequencyType,
      notificationsPerDay:
          json['notificationsPerDay'] as int? ?? initial.notificationsPerDay,
      startHour: json['startHour'] as int? ?? initial.startHour,
      endHour: json['endHour'] as int? ?? initial.endHour,
    );
  }

  factory NotificationSettingsModel.fromOption(String option) {
    return switch (option) {
      'off' => const NotificationSettingsModel(
        enabled: false,
        frequencyType: 'off',
        notificationsPerDay: 0,
        startHour: 8,
        endHour: 20,
      ),
      'three_daily' => const NotificationSettingsModel(
        enabled: true,
        frequencyType: 'daily',
        notificationsPerDay: 3,
        startHour: 8,
        endHour: 20,
      ),
      'five_daily' => const NotificationSettingsModel(
        enabled: true,
        frequencyType: 'daily',
        notificationsPerDay: 5,
        startHour: 8,
        endHour: 20,
      ),
      'ten_daily' => const NotificationSettingsModel(
        enabled: true,
        frequencyType: 'daily',
        notificationsPerDay: 10,
        startHour: 8,
        endHour: 20,
      ),
      'hourly' => const NotificationSettingsModel(
        enabled: true,
        frequencyType: 'hourly',
        notificationsPerDay: 13,
        startHour: 8,
        endHour: 20,
      ),
      _ => initial,
    };
  }

  String get optionKey {
    if (!enabled) {
      return 'off';
    }

    if (frequencyType == 'hourly') {
      return 'hourly';
    }

    return switch (notificationsPerDay) {
      3 => 'three_daily',
      5 => 'five_daily',
      10 => 'ten_daily',
      _ => 'one_daily',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequencyType': frequencyType,
      'notificationsPerDay': notificationsPerDay,
      'startHour': startHour,
      'endHour': endHour,
    };
  }
}
