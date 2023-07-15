// File: /lib/database/database_helper.dart
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:good_plan_lite/models/task.dart'; // Update this import to your actual Task model path
import 'package:good_plan_lite/models/task_category.dart'; // Update this import to your actual TaskCategory model path

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = join(await getDatabasesPath(), filePath);
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final taskQuery = '''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        isComplete INTEGER, 
        taskDate INTEGER, 
        taskDesc TEXT, 
        taskName TEXT, 
        categoryId INTEGER
      )
    ''';

    final categoryQuery = '''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        cateName TEXT
      )
    ''';

    await db.execute(taskQuery);
    await db.execute(categoryQuery);
  }

  Future<int?> createTask(Task task) async {  // Updated to return int
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return id;
  }

  Future<int?> createTaskCategory(TaskCategory category) async {  // Updated to return int
    final db = await instance.database;
    final id = await db.insert('categories', category.toMap());
    return id;
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;

    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Add this method to your DatabaseHelper class
  Future<List<Task>> fetchTasksByDate(DateTime date) async {
    final db = await instance.database;

    // Format the DateTime object to a string in 'yyyy-MM-dd' format
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    // Query the database
    final maps = await db.query(
      'tasks',
      where:
          "DATE(taskDate) = ?", // The date column needs to be of TEXT data type in SQLite
      whereArgs: [dateString],
    );

    // Convert the List<Map<String, dynamic>> into a List<Task>.
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

// Fetch tasks completed today
Future<int> fetchTasksCompletedToday() async {
  final db = await instance.database;

  final today = DateTime.now();
  final dateString = DateFormat('yyyy-MM-dd').format(today);

  final result = await db.rawQuery('''
  SELECT COUNT(*) 
  FROM tasks 
  WHERE DATE(taskDate) = ? AND isComplete = 1
''', [dateString]);

  final completedTasks = Sqflite.firstIntValue(result) ?? 0;

  return completedTasks;
}

// Fetch total tasks today
Future<int> fetchTotalTasksToday() async {
  final db = await instance.database;

  final today = DateTime.now();
  final dateString = DateFormat('yyyy-MM-dd').format(today);

  final result = await db.rawQuery('''
  SELECT COUNT(*) 
  FROM tasks 
  WHERE DATE(taskDate) = ?
''', [dateString]);

  final totalTasks = Sqflite.firstIntValue(result) ?? 0;

  return totalTasks;
}

// Calculate the percentage of completed tasks for today
Future<int> calculateCompletionPercentageForToday() async {
  int completedTasks = await fetchTasksCompletedToday();
  int totalTasks = await fetchTotalTasksToday();

  if (totalTasks == 0) {
    return 0;
  }

  final int percentage = (completedTasks * 100) ~/ totalTasks;  // Percentage

  return percentage;
}



// Fetch tasks completed this week
Future<int> fetchTasksCompletedThisWeek() async {
  final db = await instance.database;

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(Duration(days: 6));
  final startString = DateFormat('yyyy-MM-dd').format(startOfWeek);
  final endString = DateFormat('yyyy-MM-dd').format(endOfWeek);

  final result = await db.rawQuery('''
    SELECT COUNT(*) 
    FROM tasks 
    WHERE DATE(taskDate) BETWEEN ? AND ? AND isComplete = 1
  ''', [startString, endString]);

  return Sqflite.firstIntValue(result) ?? 0;
}

// Fetch total tasks for this week
Future<int> fetchTotalTasksThisWeek() async {
  final db = await instance.database;

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(Duration(days: 6));
  final startString = DateFormat('yyyy-MM-dd').format(startOfWeek);
  final endString = DateFormat('yyyy-MM-dd').format(endOfWeek);

  final result = await db.rawQuery('''
    SELECT COUNT(*) 
    FROM tasks 
    WHERE DATE(taskDate) BETWEEN ? AND ?
  ''', [startString, endString]);

  return Sqflite.firstIntValue(result) ?? 0;
}

// Calculate the completion percentage for the current week
Future<int> calculateCompletionPercentageForCurrentWeek() async {
  int completedTasks = await fetchTasksCompletedThisWeek();
  int totalTasks = await fetchTotalTasksThisWeek();

  if (totalTasks == 0) {
    return 0;
  }

  final int percentage = (completedTasks * 100) ~/ totalTasks;  // Percentage

  return percentage;
}

// Fetch tasks completed this month
Future<int> fetchTasksCompletedThisMonth() async {
  final db = await instance.database;

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  final startString = DateFormat('yyyy-MM-dd').format(startOfMonth);
  final endString = DateFormat('yyyy-MM-dd').format(endOfMonth);

  final result = await db.rawQuery('''
    SELECT COUNT(*) 
    FROM tasks 
    WHERE DATE(taskDate) BETWEEN ? AND ? AND isComplete = 1
  ''', [startString, endString]);

  return Sqflite.firstIntValue(result) ?? 0;
}

// Fetch total tasks for this month
Future<int> fetchTotalTasksThisMonth() async {
  final db = await instance.database;

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  final startString = DateFormat('yyyy-MM-dd').format(startOfMonth);
  final endString = DateFormat('yyyy-MM-dd').format(endOfMonth);

  final result = await db.rawQuery('''
    SELECT COUNT(*) 
    FROM tasks 
    WHERE DATE(taskDate) BETWEEN ? AND ?
  ''', [startString, endString]);

  return Sqflite.firstIntValue(result) ?? 0;
}

// Calculate the completion percentage for the current month
Future<int> calculateCompletionPercentageForCurrentMonth() async {
  int completedTasks = await fetchTasksCompletedThisMonth();
  int totalTasks = await fetchTotalTasksThisMonth();

  if (totalTasks == 0) {
    return 0;
  }

  final int percentage = (completedTasks * 100) ~/ totalTasks;  // Percentage

  return percentage;
}



  Stream<int> streamTasksCompletedToday() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // Poll every second
      yield await calculateCompletionPercentageForToday();
    }
  }

  Stream<int> streamTasksCompletedThisWeek() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // Poll every second
      yield await calculateCompletionPercentageForCurrentWeek();
    }
  }

  Stream<int> streamTasksCompletedThisMonth() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1)); // Poll every second
      yield await calculateCompletionPercentageForCurrentMonth();
    }
  }

}