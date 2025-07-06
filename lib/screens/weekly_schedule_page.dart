import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule_planner/screens/widgets/customDrawer.dart';
import 'package:schedule_planner/models/scheduled_task.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeeklySchedulePage extends StatefulWidget {
  final String jwtToken;
  const WeeklySchedulePage({super.key, required this.jwtToken});

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  late Future<List<ScheduledTask>> _futureSchedule;
  List<dynamic> userBreaks = [];
  DateTime _sunday = DateTime.now();

  // Timeline settings
  final int timelineStartHour = 6; // 6:00 AM
  final int timelineEndHour = 24;  // Midnight
  final int minTimelineHours = 12; // Minimum hours to show
  final double hourHeight = 60;    // Height per hour in pixels

  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _timeLabelController = ScrollController();

  double _verticalOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _sunday = _findSunday(DateTime.now());
    _futureSchedule = fetchSchedule();
    fetchBreaks();
    _verticalScrollController.addListener(_syncVerticalOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentHour());
  }

  @override
  void dispose() {
    _verticalScrollController.removeListener(_syncVerticalOffset);
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _timeLabelController.dispose();
    super.dispose();
  }

  void _syncVerticalOffset() {
    setState(() {
      _verticalOffset = _verticalScrollController.offset;
    });
    // Sync time label scroll
    if (_timeLabelController.hasClients &&
        _timeLabelController.offset != _verticalScrollController.offset) {
      _timeLabelController.jumpTo(_verticalScrollController.offset);
    }
  }

  DateTime _findSunday(DateTime date) =>
      date.subtract(Duration(days: date.weekday % 7));

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

  Future<void> fetchBreaks() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/breaks/'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          userBreaks = jsonDecode(response.body);
        });
      }
    }
  }

  void _goToPreviousWeek() {
    setState(() {
      _sunday = _sunday.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _sunday = _sunday.add(const Duration(days: 7));
    });
  }

  void _scrollToCurrentHour() {
    final now = DateTime.now();
    final hour = now.hour + now.minute / 60.0;
    if (hour >= timelineStartHour && hour <= timelineEndHour) {
      final offset = (hour - timelineStartHour) * hourHeight;
      if (_verticalScrollController.hasClients) {
        _verticalScrollController.jumpTo(
          offset.clamp(0, _verticalScrollController.position.maxScrollExtent),
        );
      }
    }
  }

  // --- ADD THIS: Importance color mapping ---
  Color getImportanceColor(String importance) {
    switch (importance.toLowerCase()) {
      case 'low':
        return Colors.lightGreen;
      case 'medium':
        return Colors.green;
      case 'high':
        return Colors.teal;
      default:
        return const Color(0xFF35746C).withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => _sunday.add(Duration(days: i))); // Sun-Sat
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF0F7),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: Colors.black),
              onPressed: _goToPreviousWeek,
            ),
            Text(
              "${DateFormat('MMMM').format(_sunday)} From ${_sunday.day}-${_sunday.add(const Duration(days: 6)).day}",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, color: Colors.black),
              onPressed: _goToNextWeek,
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.calendar_today_outlined, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      drawer: CustomDrawer(jwtToken: widget.jwtToken, currentPage: DrawerPage.weeklySchedule),
      body: FutureBuilder<List<ScheduledTask>>(
        future: _futureSchedule,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allTasks = snapshot.data!;
          // Filter tasks for this week (Sun-Sat)
          final weekStart = _sunday;
          final weekEnd = _sunday.add(const Duration(days: 7));
          final weekTasks = allTasks.where((task) =>
              task.slotStart.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              task.slotStart.isBefore(weekEnd)).toList();

          // Group tasks by day (Sunday=0)
          Map<int, List<ScheduledTask>> dayTasks = {};
          for (int i = 0; i < 7; i++) {
            dayTasks[i] = [];
          }
          for (var task in weekTasks) {
            int dayIndex = (task.slotStart.weekday % 7); // Sunday=0, Monday=1, ..., Saturday=6
            if (dayIndex >= 0 && dayIndex < 7) {
              dayTasks[dayIndex]!.add(task);
            }
          }

          // Group breaks by day_of_week (0=Sunday, 6=Saturday)
          Map<int, List<dynamic>> breaksByDay = {};
          for (var br in userBreaks) {
            final day = br['day_of_week'];
            int dayIdx = (day == 0 || day == 7) ? 0 : day; // Sunday=0 or 7
            if (dayIdx >= 0 && dayIdx <= 6) {
              breaksByDay.putIfAbsent(dayIdx, () => []).add(br);
            }
          }

          // Calculate the max timeline hours for all columns (for sticky time labels)
          double maxEndHour = timelineEndHour.toDouble();
          for (var task in weekTasks) {
            final endHour = task.slotEnd.hour + task.slotEnd.minute / 60.0;
            if (endHour > maxEndHour) maxEndHour = endHour;
          }
          for (var br in userBreaks) {
            final endHour = (br['end_hour'] as int).toDouble();
            if (endHour > maxEndHour) maxEndHour = endHour;
          }
          final timelineHours = ((maxEndHour - timelineStartHour).ceil()).clamp(minTimelineHours, 24);

          return LayoutBuilder(
            builder: (context, constraints) {
              final double visibleHeight = constraints.maxHeight - 16; // 16 for padding
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time labels (ListView, not user scrollable, synced with schedule)
                    SizedBox(
                      width: 48,
                      height: visibleHeight,
                      child: ListView.builder(
                        controller: _timeLabelController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timelineHours + 2, // +2 for alignment
                        itemExtent: hourHeight,
                        itemBuilder: (context, h) {
                          if (h == 0) return const SizedBox(height: 32); // For alignment with day labels
                          final hour = (timelineStartHour + h - 1) % 24;
                          return Container(
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              "$hour:00",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Horizontally scrollable day columns (with vertical scroll sync)
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: _NoScrollbarBehavior(),
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification &&
                                  notification.metrics.axis == Axis.vertical) {
                                if (_timeLabelController.hasClients &&
                                    _verticalScrollController.hasClients) {
                                  _timeLabelController.jumpTo(_verticalScrollController.offset);
                                }
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _verticalScrollController,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(7, (i) {
                                  final day = days[i];
                                  final tasks = dayTasks[i]!;
                                  final breaks = breaksByDay[i] ?? [];
                                  final isToday = day.year == today.year &&
                                      day.month == today.month &&
                                      day.day == today.day;

                                  return Container(
                                    width: 110,
                                    margin: const EdgeInsets.only(left: 4, right: 4),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? const Color(0xFFB2DFDB).withOpacity(0.3)
                                          : Colors.transparent,
                                      border: isToday
                                          ? Border.all(
                                              color: const Color(0xFF35746C),
                                              width: 2,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('E').format(day).toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isToday
                                                ? const Color(0xFF35746C)
                                                : const Color(0xFF35746C).withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Timeline column, height is dynamic but at least minTimelineHours
                                        SizedBox(
                                          height: (timelineHours + 1) * hourHeight,
                                          child: Stack(
                                            children: [
                                              // Timeline background with hour lines
                                              Column(
                                                children: List.generate(timelineHours + 1, (h) {
                                                  return Container(
                                                    height: hourHeight,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        top: BorderSide(
                                                          color: Colors.grey[300]!,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                              // Breaks as positioned blocks
                                              ...breaks.map((br) {
                                                final startHour = br['start_hour'] as int;
                                                final endHour = br['end_hour'] as int;
                                                final top = (startHour - timelineStartHour) * hourHeight;
                                                final height = (endHour - startHour) * hourHeight;
                                                return Positioned(
                                                  top: top,
                                                  left: 0,
                                                  right: 0,
                                                  height: height,
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFD9EDE6),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Break\n${startHour}:00 - ${endHour}:00",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.green[900],
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                              // Tasks as positioned blocks
                                              ...tasks.map((task) {
                                                final startHour = task.slotStart.hour + task.slotStart.minute / 60.0;
                                                final endHour = task.slotEnd.hour + task.slotEnd.minute / 60.0;
                                                final top = (startHour - timelineStartHour) * hourHeight;
                                                final height = (endHour - startHour) * hourHeight;
                                                // --- Color code by importance ---
                                                final Color importanceColor = getImportanceColor(
                                                  (task.importance ?? 'Medium').toString(),
                                                );
                                                return Positioned(
                                                  top: top,
                                                  left: 0,
                                                  right: 0,
                                                  height: height > 48 ? height : 48, // Minimum height for visibility
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                    decoration: BoxDecoration(
                                                      color: importanceColor,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6.0),
                                                      child: SingleChildScrollView(
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            AutoSizeText(
                                                              task.taskName,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                              // If no events at all, show "No events"
                                              if (tasks.isEmpty && breaks.isEmpty)
                                                Center(
                                                  child: Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      "No events",
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Custom ScrollBehavior to hide horizontal scrollbar
class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}