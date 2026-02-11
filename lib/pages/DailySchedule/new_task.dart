/*
import 'package:flutter/material.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _taskController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _saveTask() {
    if (_taskController.text.isNotEmpty) {
      Navigator.of(context).pop({
        'name': _taskController.text,
        'startTime': _startTime,
        'endTime': _endTime,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text('Start Time: ${_startTime.format(context)}'),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text('End Time: ${_endTime.format(context)}'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:carebridge/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewTask extends StatefulWidget {
  final String selectedDate;
  const NewTask({super.key, required this.selectedDate});

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveTask() async {
    if (_taskController.text.isNotEmpty &&
        _startTime != null &&
        _endTime != null) {
      final taskData = {
        "name": _taskController.text,
        "date": widget.selectedDate,
        "start_time": "${_startTime!.hour}:${_startTime!.minute}",
        "end_time": "${_endTime!.hour}:${_endTime!.minute}",
      };

      // Save to Firestore
      await FirebaseFirestore.instance.collection("tasks").add(taskData);

      // Schedule Notification
      DateTime now = DateTime.now();
      DateTime taskTime = DateTime(
        now.year,
        now.month,
        now.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      NotificationService.scheduleNotification(
        taskTime.millisecondsSinceEpoch ~/ 1000,
        "Task Reminder",
        "It's time for ${_taskController.text}",
        taskTime,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: "Task Name"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _startTime != null
                      ? _startTime!.format(context)
                      : "Start Time",
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: Text("Pick Start Time"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_endTime != null ? _endTime!.format(context) : "End Time"),
                ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: Text("Pick End Time"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text("Save Task"),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';

class NewTask extends StatefulWidget {
  final String selectedDate;
  const NewTask({super.key, required this.selectedDate});

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final TextEditingController _taskNameController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _pickTime(bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  void _saveTask() {
    if (_taskNameController.text.isNotEmpty &&
        _startTime != null &&
        _endTime != null) {
      Navigator.pop(context, {
        'name': _taskNameController.text,
        'startTime': _startTime,
        'endTime': _endTime,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => _pickTime(true),
                  child: Text(
                    _startTime == null
                        ? 'Select Start Time'
                        : _startTime!.format(context),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () => _pickTime(false),
                  child: Text(
                    _endTime == null
                        ? 'Select End Time'
                        : _endTime!.format(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
