import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:schedule_planner/screens/widgets/add_task_page.dart';
import 'package:schedule_planner/screens/widgets/customDrawer.dart';
import 'package:schedule_planner/models/scheduled_task.dart';

class HomePage extends StatefulWidget {
  final String jwtToken;
  const HomePage({Key? key, required this.jwtToken}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  late Future<Map<String, dynamic>> _futureSchedule;
  Future<List<ScheduledTask>> _futureCompleted = Future.value([]);

  @override
  void initState() {
    super.initState();
    fetchUser();
    _futureSchedule = fetchSchedule();
    _futureCompleted = fetchCompleted();
  }

  Future<void> fetchUser() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/users/me'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      setState(() {
        user = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        user = null;
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchSchedule() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/schedule/'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      return {"scheduled": [], "unscheduled": []};
    }
  }

  Future<List<ScheduledTask>> fetchCompleted() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/schedule/completed'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final completedList = (data['completed'] as List)
          .map((e) => ScheduledTask.fromJson(e))
          .toList();
      return completedList;
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
        _futureCompleted = fetchCompleted();
      });
    } else {
      print('Failed to update task: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('d MMM yyyy').format(DateTime.now());

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: Text('Failed to load user data')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(jwtToken: widget.jwtToken),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Checklist",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0EEE6),
          foregroundColor: const Color(0xFF2A5E59),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage(jwtToken: widget.jwtToken)),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "+ New event",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureSchedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data.'));
          }

          final allScheduled = (snapshot.data!['scheduled'] as List)
              .map((e) => ScheduledTask.fromJson(e))
              .toList();
          final scheduled = allScheduled
              .where((item) => item.status != 'completed' && item.isChecked != true)
              .toList();
          final unscheduled = snapshot.data!['unscheduled'] as List;

          return FutureBuilder<List<ScheduledTask>>(
            future: _futureCompleted,
            builder: (context, completedSnapshot) {
              final completed = completedSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Header
                  Text(
                    "Hello, ${user!['username']} 👋",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.chevron_left),
                      Text(
                        today,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pending Events Card
                  Card(
                    color: const Color(0xFFF5FAF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bookmark_border,
                                  color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Pending Events",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          scheduled.isEmpty
                              ? const Center(child: Text('No pending events.'))
                              : Column(
                                  children: scheduled.take(5).map((item) {
                                    final isCompleted = (item.status == 'completed') || (item.isChecked == true);
                                    final isOverdue = item.overdue == true;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isOverdue ? Colors.red[50] : null,
                                          border: isOverdue ? Border.all(color: Colors.red, width: 2) : null,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: isCompleted,
                                              onChanged: (val) {
                                                updateTaskStatus(item.taskId, val ?? false);
                                              },
                                            ),
                                            if (isOverdue)
                                              const Icon(Icons.warning, color: Colors.red, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "${item.taskName} (${DateFormat('hh:mm a').format(item.slotStart)} - ${DateFormat('hh:mm a').format(item.slotEnd)})\nImportance: ${item.importance}, Difficulty: ${item.difficulty}${isOverdue ? "\nOverdue!" : ""}",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                  color: isOverdue
                                                      ? Colors.red[900]
                                                      : (isCompleted ? Colors.grey : Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Completed Tasks Card
                  if (completed.isNotEmpty)
                    Card(
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Completed",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: completed.take(5).map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "${item.taskName} (${DateFormat('hh:mm a').format(item.slotStart)} - ${DateFormat('hh:mm a').format(item.slotEnd)})\nImportance: ${item.importance}, Difficulty: ${item.difficulty}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Unscheduled Tasks Card
                  if (unscheduled.isNotEmpty)
                    Card(
                      color: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.warning, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Unscheduled Tasks",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...unscheduled.map((task) {
                              final isOverdue = task['overdue'] == true;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: isOverdue
                                        ? const Icon(Icons.warning, color: Colors.red)
                                        : const Icon(Icons.error, color: Colors.red),
                                    title: Text(
                                      task['task_name'],
                                      style: TextStyle(
                                        color: isOverdue ? Colors.red[900] : null,
                                        fontWeight: isOverdue ? FontWeight.bold : null,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Deadline: ${task['deadline']}\n"
                                          "Importance: ${task['importance']}, Difficulty: ${task['difficulty']}\n"
                                          "${task['reason'] ?? ''}${isOverdue ? "\nOverdue!" : ""}",
                                          style: TextStyle(
                                            color: isOverdue ? Colors.red[900] : null,
                                            fontWeight: isOverdue ? FontWeight.bold : null,
                                          ),
                                        ),
                                        if ((task['reason'] ?? '').toLowerCase().contains('preferred hours'))
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "Tip: Try relaxing your preferred hours or extending your deadline.",
                                              style: TextStyle(color: Colors.orange[800], fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.red),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddTaskPage(
                                              jwtToken: widget.jwtToken,
                                              initialTask: task,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            _futureSchedule = fetchSchedule();
                                            _futureCompleted = fetchCompleted();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text("Reschedule All"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[100],
                                  foregroundColor: Colors.orange[900],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final response = await http.post(
                                    Uri.parse('http://10.0.2.2:5000/schedule/reschedule'),
                                    headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
                                  );
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      _futureSchedule = fetchSchedule();
                                      _futureCompleted = fetchCompleted();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 80), // Spacer for floating button
                ],
              );
            },
          );
        },
      ),
    );
  }
}