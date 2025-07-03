import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback? onAssignmentTap;
  final VoidCallback? onExamTap;
  final VoidCallback? onReminderTap;

  const CustomFAB({
    Key? key,
    this.onAssignmentTap,
    this.onExamTap,
    this.onReminderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
return SpeedDial(
        icon: Icons.add,
        label: const Text('New Event', style: TextStyle(color: Color(0xFF298267))),
        iconTheme: const IconThemeData(color: Color(0xFF298267)), // green icon
        backgroundColor: const Color(0xFF298267).withOpacity(0.2),
        shape: const CircleBorder(),
      // children: [
      //   SpeedDialChild(
      //     child: const Icon(Icons.notifications_none, color: Colors.white),
      //     backgroundColor: const Color(0xFF298267),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     label: 'Reminder',
      //     labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      //     onTap: onReminderTap,
      //   ),
      //   SpeedDialChild(
      //     child: const Icon(Icons.school, color: Colors.white),
      //     backgroundColor: const Color(0xFF298267),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     label: 'Exam',
      //     labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      //     onTap: onExamTap,
      //   ),
      //   SpeedDialChild(
      //     child: const Icon(Icons.menu_book, color: Colors.white),
      //     backgroundColor: const Color(0xFF298267),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     label: 'Assignment',
      //     labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      //     onTap: onAssignmentTap,
      //   ),
      // ],
    );
  }
}
