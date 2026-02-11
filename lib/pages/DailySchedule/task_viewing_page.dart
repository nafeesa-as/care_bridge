import 'package:carebridge/pages/DailySchedule/task_editing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carebridge/utils.dart';
import "package:carebridge/provider/task_provider.dart";
import 'package:carebridge/models/task.dart';

class TaskViewingPage extends StatelessWidget {
  final Task task;
  const TaskViewingPage({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: CloseButton(color: Colors.white),
        actions: buildViewingActions(context, task),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildDateTime(task),
            SizedBox(height: 32),
            Text(
              task.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateTime(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDate('From', task.from),
        SizedBox(height: 16),
        if (!task.isAllDay) buildDate('To', task.to),
      ],
    );
  }

  Widget buildDate(String title, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          Utils.formatDateTime(date),
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ],
    );
  }

  List<Widget> buildViewingActions(BuildContext context, Task task) {
    return [
      IconButton(
        icon: Icon(Icons.edit, color: Colors.white),
        onPressed:
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TaskEditingPage(task: task),
              ),
            ),
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.white),
        onPressed: () {
          final provider = Provider.of<TaskProvider>(context, listen: false);
          provider.deleteTask(task);
          Navigator.of(context).pop();
        },
      ),
    ];
  }
}
