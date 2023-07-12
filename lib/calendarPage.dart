import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:good_plan_lite/createTaskPage.dart';
import 'package:good_plan_lite/database/database_helper.dart';
import 'package:good_plan_lite/models/task.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();  // Fetch tasks when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = selectedDay;
                  _fetchTasks();  // Fetch tasks when a day is selected
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Dismissible(
                    key: Key('${task.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteTask(task.id!); // Delete the task when dismissed
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      color: Colors.red,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      leading: InkWell(
                        onTap: () {
                          _toggleTaskCompletion(task); // Toggle the task completion status when icon is tapped
                        },
                        child: Icon(
                          task.isComplete == IsComplete.complete ? Icons.check_circle : Icons.check_circle_outline,
                        ),
                      ),
                      title: Text(task.taskName!),
                      subtitle: Text(task.taskDesc!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskPage()),
          ).then((_) {
            _fetchTasks();  // Fetch tasks again when returned from CreateTaskPage
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _fetchTasks() async {
    if (_selectedDay != null) {
      _tasks = await DatabaseHelper.instance.fetchTasksByDate(_selectedDay!);
      setState(() {});
    }
  }

  void _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _fetchTasks();
  }

  void _toggleTaskCompletion(Task task) async {
    Task updatedTask = task.copy(
      isComplete: task.isComplete == IsComplete.complete ? IsComplete.inComplete : IsComplete.complete,
    );
    await DatabaseHelper.instance.updateTask(updatedTask);
    _fetchTasks();
  }
}
