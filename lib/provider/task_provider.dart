/*
import 'package:carebridge/models/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _task = [];
  List<Task> get task => _task;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TaskProvider() {
    fetchTasks(); // Load tasks when provider is initialized
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Task> get taskOfSelectedDate =>
      _task.where((t) {
        return t.from.year == _selectedDate.year &&
            t.from.month == _selectedDate.month &&
            t.from.day == _selectedDate.day;
      }).toList();

  Future<void> addTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    _task.add(task);
    notifyListeners();

    final taskRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc();

    await taskRef.set({
      'id': taskRef.id,
      'title': task.title,
      'description': task.description,
      'from': task.from.toIso8601String(),
      'to': task.to.toIso8601String(),
      'isAllDay': task.isAllDay,
      'timestamp': FieldValue.serverTimestamp(), // Helps with sorting
    });
  }

  Future<void> deleteTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    _task.remove(task);
    notifyListeners();

    final taskCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    await taskCollection
        .where('title', isEqualTo: task.title) // Match by title
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
  }

  Future<void> editTask(Task newTask, Task oldTask) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    final index = _task.indexOf(oldTask);
    if (index != -1) {
      _task[index] = newTask;
      notifyListeners();
    }

    final taskCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    await taskCollection.where('title', isEqualTo: oldTask.title).get().then((
      snapshot,
    ) {
      for (var doc in snapshot.docs) {
        doc.reference.update({
          'title': newTask.title,
          'description': newTask.description,
          'from': newTask.from.toIso8601String(),
          'to': newTask.to.toIso8601String(),
          'isAllDay': newTask.isAllDay,
        });
      }
    });
  }

  Future<void> fetchTasks() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .orderBy('timestamp', descending: true) // Fetch latest tasks first
            .get();

    _task.clear();
    _task.addAll(
      snapshot.docs.map(
        (doc) => Task(
          title: doc['title'],
          description: doc['description'],
          from: DateTime.parse(doc['from']),
          to: DateTime.parse(doc['to']),
          isAllDay: doc['isAllDay'],
        ),
      ),
    );
    notifyListeners();
  }
}
*/
import 'package:carebridge/models/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _task = [];
  List<Task> get task => _task;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TaskProvider() {
    fetchTasks(); // Load tasks when provider is initialized
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Task> get taskOfSelectedDate =>
      _task.where((t) {
        return t.from.year == _selectedDate.year &&
            t.from.month == _selectedDate.month &&
            t.from.day == _selectedDate.day;
      }).toList();

  Future<void> addTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    _task.add(task);
    notifyListeners();

    final taskRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc();

    await taskRef.set({
      'id': taskRef.id,
      'title': task.title,
      'description': task.description,
      'from': task.from.toIso8601String(),
      'to': task.to.toIso8601String(),
      'isAllDay': task.isAllDay,
      'timestamp': FieldValue.serverTimestamp(), // Helps with sorting
    });
  }

  Future<void> deleteTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    _task.remove(task);
    notifyListeners();

    final taskCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    await taskCollection
        .where('title', isEqualTo: task.title) // Match by title
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
  }

  Future<void> editTask(Task newTask, Task oldTask) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    final index = _task.indexOf(oldTask);
    if (index != -1) {
      _task[index] = newTask;
      notifyListeners();
    }

    final taskCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    await taskCollection.where('title', isEqualTo: oldTask.title).get().then((
      snapshot,
    ) {
      for (var doc in snapshot.docs) {
        doc.reference.update({
          'title': newTask.title,
          'description': newTask.description,
          'from': newTask.from.toIso8601String(),
          'to': newTask.to.toIso8601String(),
          'isAllDay': newTask.isAllDay,
        });
      }
    });
  }

  Future<void> fetchTasks() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .orderBy('timestamp', descending: true) // Fetch latest tasks first
            .get();

    _task.clear();
    _task.addAll(
      snapshot.docs.map(
        (doc) => Task(
          title: doc['title'],
          description: doc['description'],
          from: DateTime.parse(doc['from']),
          to: DateTime.parse(doc['to']),
          isAllDay: doc['isAllDay'],
        ),
      ),
    );
    notifyListeners();
  }
}
