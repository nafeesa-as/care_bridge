import "package:carebridge/models/task_data_source.dart";
import "package:carebridge/pages/DailySchedule/task_viewing_page.dart";
import "package:carebridge/provider/task_provider.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:syncfusion_flutter_calendar/calendar.dart";
// ignore: depend_on_referenced_packages
import "package:syncfusion_flutter_core/theme.dart";

class TaskWidget extends StatefulWidget {
  const TaskWidget({super.key});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final selectedTask = provider.taskOfSelectedDate;
    if (selectedTask.isEmpty) {
      return Center(
        child: Text(
          'No Events Found!',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
      );
    }
    return SfCalendarTheme(
      data: SfCalendarThemeData(
        timeTextStyle: TextStyle(fontSize: 16, color: Colors.black),
      ),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        dataSource: TaskDataSource(provider.task),
        initialDisplayDate: provider.selectedDate,
        appointmentBuilder: appointmentBuilder,
        headerHeight: 0,
        todayHighlightColor: Colors.black,
        selectionDecoration: BoxDecoration(color: Colors.transparent),
        onTap: (details) {
          if (details.appointments == null) return;
          final task = details.appointments!.first;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskViewingPage(task: task),
            ),
          );
        },
      ),
    );
  }

  Widget appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final tasks = details.appointments.first;
    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: tasks.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          tasks.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
