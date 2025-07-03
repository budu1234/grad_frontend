import 'package:intl/intl.dart';

class ScheduledTask {
  final int scheduleId;
  final DateTime slotStart;
  final DateTime slotEnd;
  final int taskId;
  final String taskName;
  final String importance;   // "High", "Medium", "Low"
  final String difficulty;   // "High", "Medium", "Low"
  final DateTime deadline;
  final String? status;
  final bool? isChecked;
  final String? type; // "task", "break", "exam", etc.
  final bool? overdue; // <-- Make nullable

  ScheduledTask({
    required this.scheduleId,
    required this.slotStart,
    required this.slotEnd,
    required this.taskId,
    required this.taskName,
    required this.importance,
    required this.difficulty,
    required this.deadline,
    this.status,
    this.isChecked,
    this.type,
    this.overdue, // <-- Nullable
  });

  factory ScheduledTask.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic s) {
      if (s == null) return DateTime.now();
      if (s is DateTime) return s;
      if (s is int) return DateTime.fromMillisecondsSinceEpoch(s);
      if (s is String) {
        // Try ISO8601 first
        try {
          return DateTime.parse(s).toUtc();
        } catch (_) {
          // Try custom format
          s = s.replaceAll(' GMT', '');
          return DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US').parseUtc(s);
        }
      }
      return DateTime.now();
    }

    return ScheduledTask(
      scheduleId: json['schedule_id'] ?? json['id'] ?? -1,
      slotStart: parseDate(json['slot_start'] ?? json['created_at']),
      slotEnd: parseDate(json['slot_end'] ?? json['deadline']),
      taskId: json['task_id'] ?? json['id'] ?? -1,
      taskName: json['task_name'] ?? json['name'] ?? '',
      importance: json['importance'] ?? '',
      difficulty: json['difficulty'] ?? '',
      deadline: parseDate(json['deadline']),
      status: json['status'],
      isChecked: json['is_checked'] == 1 || json['is_checked'] == true,
      type: json['type'] ?? json['status'],
      overdue: json['overdue'] == null ? false : json['overdue'] == true, // <-- Always bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'slot_start': slotStart.toUtc().toIso8601String(),
      'slot_end': slotEnd.toUtc().toIso8601String(),
      'task_id': taskId,
      'task_name': taskName,
      'importance': importance,
      'difficulty': difficulty,
      'deadline': deadline.toUtc().toIso8601String(),
      'status': status,
      'is_checked': isChecked,
      'type': type,
      'overdue': overdue ?? false, // <-- Always bool
    };
  }
}