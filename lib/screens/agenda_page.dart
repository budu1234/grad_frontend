// ...existing imports...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:schedule_planner/screens/widgets/customDrawer.dart';
import 'package:schedule_planner/screens/widgets/add_task_page.dart';
import 'package:schedule_planner/models/scheduled_task.dart';
import 'dart:convert';

class AgendaPage extends StatefulWidget {
  final String jwtToken;
  const AgendaPage({super.key, required this.jwtToken});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _focusedDay = DateTime.now();
  late Future<List<ScheduledTask>> _futureSchedule;

  @override
  void initState() {
    super.initState();
    _futureSchedule = fetchSchedule();
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

  Future<void> updateTaskStatus(int taskId, bool isChecked) async {
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:5000/tasks/$taskId'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': isChecked ? 'completed' : 'pending',
        'is_checked': isChecked,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        _futureSchedule = fetchSchedule();
      });
    } else {
      print('Failed to update task: ${response.body}');
    }
  }

  Future<void> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:5000/tasks/$taskId'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _futureSchedule = fetchSchedule();
      });
    } else {
      print('Failed to delete task: ${response.body}');
    }
  }

  // Group tasks by date (yyyy-MM-dd)
  Map<String, List<ScheduledTask>> groupTasksByDate(List<ScheduledTask> tasks) {
    Map<String, List<ScheduledTask>> grouped = {};
    for (var task in tasks) {
      final dateKey = DateFormat('yyyy-MM-dd').format(task.slotStart);
      grouped.putIfAbsent(dateKey, () => []).add(task);
    }
    return grouped;
  }

  void _showTaskDetailDialog(ScheduledTask task) {
    showDialog(
      context: context,
      builder: (context) {
        final isCompleted = (task.status == 'completed') || (task.isChecked == true);
        return AlertDialog(
          title: Text(task.taskName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('EEEE, MMM d, yyyy').format(task.slotStart)}\n'
                '${DateFormat('hh:mm a').format(task.slotStart)} - ${DateFormat('hh:mm a').format(task.slotEnd)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text('Importance: ${task.importance}'),
              Text('Difficulty: ${task.difficulty}'),
              if ((task.overdue ?? false) == true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text('Overdue!', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (val) {
                      Navigator.pop(context);
                      updateTaskStatus(task.taskId, val ?? false);
                    },
                  ),
                  const Text('Mark as completed'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(
                      jwtToken: widget.jwtToken,
                      initialTask: task.toJson(),
                    ),
                  ),
                ).then((result) {
                  setState(() {
                    _futureSchedule = fetchSchedule();
                  });
                });
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('Are you sure you want to delete this task?'),
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
                  await deleteTask(task.taskId);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(jwtToken: widget.jwtToken, currentPage: DrawerPage.agenda),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          '${DateFormat('MMMM').format(_focusedDay)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<ScheduledTask>>(
        future: _futureSchedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scheduled tasks.'));
          }
          final schedule = snapshot.data!;
          final grouped = groupTasksByDate(schedule);

          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => a.compareTo(b)); // Sort by date

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, dayIndex) {
              final dateKey = sortedKeys[dayIndex];
              final tasks = grouped[dateKey]!;
              final date = DateFormat('yyyy-MM-dd').parse(dateKey);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      DateFormat('EEEE, MMM d, yyyy').format(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...tasks.map((item) {
                    final isCompleted = (item.status == 'completed') || (item.isChecked == true);
                    final isOverdue = (item.overdue ?? false) == true;
                    return Card(
                      color: isOverdue ? Colors.red[50] : null,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Tooltip(
                          message: "Mark as completed",
                          child: Checkbox(
                            value: isCompleted,
                            onChanged: (val) {
                              updateTaskStatus(item.taskId, val ?? false);
                            },
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.taskName,
                                style: TextStyle(
                                  color: isOverdue ? Colors.red[900] : null,
                                  fontWeight: isOverdue ? FontWeight.bold : null,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (isOverdue)
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(Icons.warning, color: Colors.red, size: 20),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${DateFormat('hh:mm a').format(item.slotStart)} - ${DateFormat('hh:mm a').format(item.slotEnd)}\n'
                          'Importance: ${item.importance}, Difficulty: ${item.difficulty}'
                          '${isOverdue ? "\nOverdue!" : ""}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red[900] : null,
                            fontWeight: isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                        onTap: () => _showTaskDetailDialog(item),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF298267),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(jwtToken: widget.jwtToken),
            ),
          );
          if (result == true) {
            setState(() {
              _futureSchedule = fetchSchedule();
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}