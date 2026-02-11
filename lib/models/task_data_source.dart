import 'package:carebridge/models/task.dart';
import 'package:flutter/material.dart';
import "package:syncfusion_flutter_calendar/calendar.dart";

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> appointments) {
    this.appointments = appointments;
  }
  Task getTask(int index) => appointments![index] as Task;
  @override
  DateTime getStartTime(int index) => getTask(index).from;
  @override
  DateTime getEndTime(int index) => getTask(index).to;
  @override
  String getSubject(int index) => getTask(index).title;
  @override
  Color getColor(int index) => getTask(index).backgroundColor;
  @override
  bool isAllDay(int index) => getTask(index).isAllDay;
}
