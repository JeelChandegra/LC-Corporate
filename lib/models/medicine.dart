import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dose;

  @HiveField(3)
  final int hour;

  @HiveField(4)
  final int minute;

  @HiveField(5)
  final bool isEnabled;

  @HiveField(6)
  final List<ReminderTime>? reminderTimes;

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.reminderTimes,
  });

  /// Get all reminder times (supports both old single time and new multiple times)
  List<ReminderTime> get allReminderTimes {
    if (reminderTimes != null && reminderTimes!.isNotEmpty) {
      return reminderTimes!;
    }
    // Fallback to single time for backward compatibility
    return [ReminderTime(hour: hour, minute: minute)];
  }

  String get formattedTime {
    final times = allReminderTimes;
    if (times.length == 1) {
      return times.first.formattedTime;
    }
    return '${times.length} reminders';
  }

  String get formattedTimeDetailed {
    final times = allReminderTimes;
    return times.map((t) => t.formattedTime).join(', ');
  }

  int get timeInMinutes => hour * 60 + minute;

  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    int? hour,
    int? minute,
    bool? isEnabled,
    List<ReminderTime>? reminderTimes,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }
}

@HiveType(typeId: 1)
class ReminderTime extends HiveObject {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  ReminderTime({
    required this.hour,
    required this.minute,
  });

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  int get timeInMinutes => hour * 60 + minute;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderTime && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
