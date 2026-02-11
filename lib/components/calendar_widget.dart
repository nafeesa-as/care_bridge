import "package:carebridge/components/task_widget.dart";
import "package:carebridge/models/task_data_source.dart";
import "package:carebridge/provider/task_provider.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:syncfusion_flutter_calendar/calendar.dart";

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final task = Provider.of<TaskProvider>(context).task;
    return SfCalendar(
      view: CalendarView.month,
      dataSource: TaskDataSource(task),
      initialSelectedDate: DateTime.now(),
      cellBorderColor: Colors.transparent,
      onTap: (details) {
        final provider = Provider.of<TaskProvider>(context, listen: false);
        provider.setDate(details.date!);
        showModalBottomSheet(
          context: context,
          builder: (context) => TaskWidget(),
        );
      },
    );
  }
}
