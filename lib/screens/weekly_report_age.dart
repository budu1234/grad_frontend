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

  // Helper to get start of week (Monday)
  DateTime getStartOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  @override
  Widget build(BuildContext context) {
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
          future: _futureSchedule,
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

            // Count completed and pending
            final int completed = weekTasks.where((t) =>
              (t.status == 'completed') || (t.isChecked == true)
            ).length;
            final int pending = weekTasks.length - completed;
            final int total = weekTasks.length;

            final double completedPercent = total == 0 ? 0 : (completed / total) * 100;
            final double pendingPercent = total == 0 ? 0 : (pending / total) * 100;

            return Center(
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