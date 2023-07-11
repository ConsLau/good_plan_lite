import 'package:flutter/material.dart';
import 'package:good_plan_lite/database/database_helper.dart';
import 'package:good_plan_lite/models/task.dart';  // Added import
import 'package:good_plan_lite/models/task_category.dart';  // Added import
import 'package:intl/intl.dart';


class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  String _taskDesc = '';
  DateTime _taskDate = DateTime.now();
  String _cateName = '';
  bool _isComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Task'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(   // Changed Column to ListView
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Task Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task name';
                  }
                  return null;
                },
                onSaved: (value) => _taskName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Task Description'),
                onSaved: (value) => _taskDesc = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Task Category'),
                onSaved: (value) => _cateName = value!,
              ),
              TextButton(
                child: Text("Task Date: ${DateFormat('yyyy-MM-dd').format(_taskDate)}"),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _taskDate = date;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: Text("Is Task Complete?"),
                value: _isComplete,
                onChanged: (value) {
                  setState(() {
                    _isComplete = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: Icon(Icons.check),
      ),
    );
  }

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Create your task and task category objects
    var task = Task(
      taskName: _taskName,
      taskDesc: _taskDesc,
      taskDate: _taskDate,
      isComplete: _isComplete ? IsComplete.complete : IsComplete.inComplete,  // Update here
      categoryId: 1,  // Modify as necessary
    );

    var category = TaskCategory(
      cateName: _cateName,
    );

    // Save your task and category in database and print out the id
    var taskId = await DatabaseHelper.instance.createTask(task);
    var categoryId = await DatabaseHelper.instance.createTaskCategory(category);

    // Print the task and category ids
    print('New task id: $taskId');
    print('New category id: $categoryId');

    // Optionally, you can navigate back to the previous screen
    Navigator.pop(context);
  }
}




}
