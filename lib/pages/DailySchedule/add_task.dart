import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = "";
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Task Name"),
                onChanged: (value) => _taskName = value,
                validator:
                    (value) => value!.isEmpty ? "Enter a task name" : null,
              ),
              const SizedBox(height: 10),
              _buildTimePicker("Start Time", _startTime, (newTime) {
                setState(() => _startTime = newTime);
              }),
              const SizedBox(height: 10),
              _buildTimePicker("End Time", _endTime, (newTime) {
                setState(() => _endTime = newTime);
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label: ${time.format(context)}"),
        ElevatedButton(
          onPressed: () async {
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) onTimeChanged(picked);
          },
          child: const Text("Pick"),
        ),
      ],
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('tasks').add({
        'name': _taskName,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'startTime': _startTime.format(context),
        'endTime': _endTime.format(context),
      });
      Navigator.pop(context);
    }
  }
}
