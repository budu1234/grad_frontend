import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:schedule_planner/screens/widgets/customDrawer.dart';
import 'package:schedule_planner/models/scheduled_task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeeklyReportPage extends StatefulWidget {
  final String jwtToken;
  const WeeklyReportPage({super.key, required this.jwtToken});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  late Future<List<ScheduledTask>> _futureAllWeeklyTasks;

  @override
  void initState() {
    super.initState();
    _futureAllWeeklyTasks = fetchAllWeeklyTasks();
  }

  // Fetch both pending and completed scheduled tasks and combine them
  Future<List<ScheduledTask>> fetchAllWeeklyTasks() async {
    final pendingResponse = await http.get(
      Uri.parse('http://10.0.2.2:5000/schedule/'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    final completedResponse = await http.get(
      Uri.parse('http://10.0.2.2:5000/schedule/completed'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );

    final pending = (jsonDecode(pendingResponse.body)['scheduled'] ?? [])
        .map<ScheduledTask>((e) => ScheduledTask.fromJson(e))
        .toList();
    final completed = (jsonDecode(completedResponse.body)['completed'] ?? [])
        .map<ScheduledTask>((e) => ScheduledTask.fromJson(e))
        .toList();

    return [...pending, ...completed];
  }

  // Helper to get start of week (Monday)
  DateTime getStartOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(jwtToken: widget.jwtToken, currentPage: DrawerPage.weeklyReport),
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
          "",
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
      body: SafeArea(
        child: FutureBuilder<List<ScheduledTask>>(
          future: _futureAllWeeklyTasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No scheduled tasks this week.'));
            }

            final now = DateTime.now();
            final startOfWeek = getStartOfWeek(now);
            final endOfWeek = startOfWeek.add(const Duration(days: 7));

            // Filter for current week
            final weekTasks = snapshot.data!.where((task) =>
                task.slotStart.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                task.slotStart.isBefore(endOfWeek)).toList();

            // Separate completed and pending
            final completedTasks = weekTasks.where((t) =>
              (t.status == 'completed') || (t.isChecked == true)
            ).toList();
            final pendingTasks = weekTasks.where((t) =>
              !(t.status == 'completed' || t.isChecked == true)
            ).toList();

            final int completed = completedTasks.length;
            final int pending = pendingTasks.length;
            final int total = weekTasks.length;

            final double completedPercent = total == 0 ? 0 : (completed / total) * 100;
            final double pendingPercent = total == 0 ? 0 : (pending / total) * 100;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Weekly Report',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 60,
                              sectionsSpace: 2,
                              sections: [
                                PieChartSectionData(
                                  value: completedPercent,
                                  color: Colors.green,
                                  radius: 60,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: pendingPercent,
                                  color: Colors.red,
                                  radius: 60,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              total == 0
                                  ? '0%'
                                  : '${completedPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Completed',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegend(Colors.green, "Completed"),
                        const SizedBox(width: 16),
                        _buildLegend(Colors.red, "Pending"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Total tasks this week: $total",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // Pending Tasks List
                    if (pendingTasks.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pending Tasks",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pendingTasks.map((task) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.pending_actions, color: Colors.red),
                              title: Text(task.taskName),
                              subtitle: Text(
                                "${task.slotStart != null ? "${task.slotStart.hour.toString().padLeft(2, '0')}:${task.slotStart.minute.toString().padLeft(2, '0')}" : ""} - "
                                "${task.slotEnd != null ? "${task.slotEnd.hour.toString().padLeft(2, '0')}:${task.slotEnd.minute.toString().padLeft(2, '0')}" : ""}",
                              ),
                            ),
                          )),
                      const SizedBox(height: 20),
                    ],
                    // Completed Tasks List
                    if (completedTasks.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Completed Tasks",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...completedTasks.map((task) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text(
                                task.taskName,
                                style: const TextStyle(decoration: TextDecoration.lineThrough),
                              ),
                              subtitle: Text(
                                "${task.slotStart != null ? "${task.slotStart.hour.toString().padLeft(2, '0')}:${task.slotStart.minute.toString().padLeft(2, '0')}" : ""} - "
                                "${task.slotEnd != null ? "${task.slotEnd.hour.toString().padLeft(2, '0')}:${task.slotEnd.minute.toString().padLeft(2, '0')}" : ""}",
                              ),
                            ),
                          )),
                    ],
                    if (pendingTasks.isEmpty && completedTasks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: Text('No tasks this week.'),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}