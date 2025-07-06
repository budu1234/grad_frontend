import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:schedule_planner/screens/widgets/customDrawer.dart';
import 'package:schedule_planner/models/scheduled_task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:schedule_planner/screens/widgets/add_task_page.dart';

class CalenderPage extends StatefulWidget {
  final String jwtToken;
  const CalenderPage({super.key, required this.jwtToken});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  late Future<List<ScheduledTask>> _futureSchedule;
  Map<DateTime, List<ScheduledTask>> _events = {};

  // Helper to normalize date to year/month/day only
  DateTime getDayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  Future<List<ScheduledTask>> fetchSchedule() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/schedule/'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List scheduled = data['scheduled'] ?? [];
      return scheduled.map((e) => ScheduledTask.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  void _refreshEvents() {
    setState(() {
      _futureSchedule = fetchSchedule();
    });
    _futureSchedule.then((tasks) {
      setState(() {
        _events = {};
        for (var task in tasks) {
          // Only show pending tasks
          if (task.status != 'completed' && task.isChecked != true) {
            final day = getDayKey(task.slotStart);
            _events.putIfAbsent(day, () => []).add(task);
          }
        }
      });
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _events[getDayKey(_selectedDay ?? _focusedDay)] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
        drawer: CustomDrawer(jwtToken: widget.jwtToken, currentPage: DrawerPage.home),      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_sharp, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: Colors.black),
              onPressed: _goToPreviousMonth,
            ),
            Text(
              '${_focusedDay.monthName()} ${_focusedDay.year}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, color: Colors.black),
              onPressed: _goToNextMonth,
            ),
          ],
        ),
        actions: const [
          Icon(Icons.calendar_today_outlined, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 270,
            right: 0,
            child: Image.asset(
              "assets/img/right_blob.png",
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/img/left_blob.png",
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F7F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => _events[getDayKey(day)] ?? [],
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    headerVisible: false,
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF298267),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(color: Colors.black),
                      selectedTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.black),
                      defaultTextStyle: TextStyle(color: Colors.black),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                      weekendStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 64, color: Colors.green.shade700),
                          const SizedBox(height: 8),
                          const Text(
                            'No events',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView(
                          children: selectedEvents.map((event) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.circle_outlined,
                                          size: 16, color: Colors.grey),
                                      Container(
                                        height: 40,
                                        width: 2,
                                        color: Colors.grey.shade300,
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.taskName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${DateFormat('hh:mm a').format(event.slotStart)} - ${DateFormat('hh:mm a').format(event.slotEnd)}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'Importance: ${event.importance}, Difficulty: ${event.difficulty}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddTaskPage(
                                              jwtToken: widget.jwtToken,
                                              initialTask: event.toJson(),
                                            ),
                                          ),
                                        );
                                        _refreshEvents();
                                      } else if (value == 'complete') {
                                        await http.patch(
                                          Uri.parse('http://10.0.2.2:5000/tasks/${event.taskId}'),
                                          headers: {
                                            'Authorization': 'Bearer ${widget.jwtToken}',
                                            'Content-Type': 'application/json',
                                          },
                                          body: jsonEncode({'status': 'completed', 'is_checked': true}),
                                        );
                                        _refreshEvents();
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Task'),
                                            content: const Text('Are you sure you want to delete this task? This will remove it from all schedules.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await http.delete(
                                            Uri.parse('http://10.0.2.2:5000/tasks/${event.taskId}'),
                                            headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
                                          );
                                          _refreshEvents();
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'complete', child: Text('Mark as Completed')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF298267),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(jwtToken: widget.jwtToken),
            ),
          );
          _refreshEvents();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String monthName() {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[this.month - 1];
  }
}