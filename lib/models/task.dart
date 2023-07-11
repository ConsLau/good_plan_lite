import 'package:intl/intl.dart';

enum IsComplete { complete, inComplete }

class Task {
  final int? id;
  final IsComplete isComplete;
  final DateTime taskDate;
  final String taskDesc;
  final String taskName;
  final int categoryId;

  Task({
    this.id,
    this.isComplete = IsComplete.inComplete,
    required this.taskDate,
    required this.taskDesc,
    required this.taskName,
    required this.categoryId,
  });

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'isComplete': isComplete.index,
    'taskDate': DateFormat('yyyy-MM-dd').format(taskDate),
    'taskDesc': taskDesc,
    'taskName': taskName,
    'categoryId': categoryId,
  };
}

static Task fromMap(Map<String, dynamic> map) {
  return Task(
    id: map['id'],
    isComplete: IsComplete.values[map['isComplete']],
    taskDate: DateTime.parse(map['taskDate']),
    taskDesc: map['taskDesc'],
    taskName: map['taskName'],
    categoryId: map['categoryId'],
  );
}


// copy
  Task copy({
    int? id,
    IsComplete? isComplete,
    DateTime? taskDate,
    String? taskDesc,
    String? taskName,
    int? categoryId,
  }) =>
      Task(
        id: id ?? this.id,
        isComplete: isComplete ?? this.isComplete,
        taskDate: taskDate ?? this.taskDate,
        taskDesc: taskDesc ?? this.taskDesc,
        taskName: taskName ?? this.taskName,
        categoryId: categoryId ?? this.categoryId,
      );
}
