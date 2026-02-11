import 'package:flutter/material.dart';

class Task {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final bool isAllDay;
  const Task({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    this.backgroundColor = Colors.grey,
    this.isAllDay = false,
  });
}
