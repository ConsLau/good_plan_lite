class TaskCategory {
  final int? id;
  final String cateName;

  TaskCategory({
    this.id,
    required this.cateName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cateName': cateName,
    };
  }

  static TaskCategory fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      id: map['id'],
      cateName: map['cateName'],
    );
  }

// copy
  TaskCategory copy({
    int? id,
    String? cateName,
  }) =>
      TaskCategory(
        id: id ?? this.id,
        cateName: cateName ?? this.cateName,
      );
}
