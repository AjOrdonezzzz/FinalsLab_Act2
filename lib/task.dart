import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  String priority;

  @HiveField(5)
  String category;

  @HiveField(6)
  bool isCompleted;

  // New fields (defaults keep previously saved tasks readable)
  @HiveField(7, defaultValue: '')
  String dueTime;

  @HiveField(8, defaultValue: '')
  String assignee;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
    this.dueTime = '',
    this.assignee = '',
  });
}
