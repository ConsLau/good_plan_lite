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
    where: "DATE(taskDate) = ?",  // The date column needs to be of TEXT data type in SQLite
    whereArgs: [dateString],
  );

  // Convert the List<Map<String, dynamic>> into a List<Task>.
  return List.generate(maps.length, (i) {
    return Task.fromMap(maps[i]);
  });
}
}
