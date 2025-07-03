import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/preferred_study_hours_input_page.dart';
import 'package:schedule_planner/screens/widgets/customDrawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreferredStudySummaryPage extends StatefulWidget {
  final String jwtToken;
  const PreferredStudySummaryPage({super.key, required this.jwtToken});

  @override
  State<PreferredStudySummaryPage> createState() => _PreferredStudySummaryPageState();
}

class _PreferredStudySummaryPageState extends State<PreferredStudySummaryPage> {
  Map<String, dynamic>? userPrefs;
  List<dynamic> userBreaks = [];
  bool isLoading = true;

  // General working hours
  int generalStartHour = 8;
  int generalEndHour = 22;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([fetchPreferences(), fetchBreaks()]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchPreferences() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/users/me'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userPrefs = data;
        generalStartHour = data['general_start_hour'] ?? 8;
        generalEndHour = data['general_end_hour'] ?? 22;
      });
    } else {
      setState(() {
        userPrefs = null;
      });
    }
  }

  Future<void> fetchBreaks() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/breaks/'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      setState(() {
        userBreaks = jsonDecode(response.body);
      });
    } else {
      setState(() {
        userBreaks = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF35746C);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Parse preferred working hours and constraint
    final List<dynamic> preferredHours = userPrefs?['preferred_working_hours'] != null
        ? jsonDecode(userPrefs!['preferred_working_hours'])
        : List.generate(7, (d) => [d, 9, 17]);
    final dynamic constraintRaw = userPrefs?['working_hours_constraint'];
    final bool hardConstraint = constraintRaw == true || constraintRaw == 1;

    String dayName(int day) {
      const days = [
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
      ];
      return days[day % 7];
    }

    // Group breaks by day for display
    Map<int, List<Map<String, dynamic>>> breaksByDay = {};
    for (var br in userBreaks) {
      final day = br['day_of_week'];
      breaksByDay.putIfAbsent(day, () => []).add(br);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(jwtToken: widget.jwtToken),
      appBar: AppBar(
        title: const Text("Preference"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Preferred Study Hours as you Enter",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Day", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Start time", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF35746C))),
                Text("End time", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF35746C))),
              ],
            ),
            const SizedBox(height: 8),
            for (var entry in preferredHours)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dayName(entry[0])),
                    Text("${entry[1]}:00"),
                    Text("${entry[2]}:00"),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text("Break Hours", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            userBreaks.isEmpty
                ? const Text("No breaks set.", style: TextStyle(color: Colors.grey))
                : Column(
                    children: List.generate(7, (day) {
                      final breaks = breaksByDay[day] ?? [];
                      if (breaks.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName(day),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Color(0xFF35746C)),
                          ),
                          ...breaks.map((br) => Padding(
                                padding: const EdgeInsets.only(left: 12, bottom: 4),
                                child: Text(
                                    "${br['start_hour']}:00 - ${br['end_hour']}:00",
                                    style: const TextStyle(color: Colors.black87)),
                              )),
                        ],
                      );
                    }),
                  ),
            const SizedBox(height: 20),
            const Text("General Available Hours", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text("${generalStartHour.toString().padLeft(2, '0')}:00", style: const TextStyle(color: Color(0xFF35746C))),
                const SizedBox(width: 20),
                Text("${generalEndHour.toString().padLeft(2, '0')}:00", style: const TextStyle(color: Color(0xFF35746C))),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Preferred scheduling mode", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              hardConstraint ? "Preferred Hours Only" : "Flexible hours",
              style: const TextStyle(color: Color(0xFF35746C)),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreferredStudyHoursInputPage(
                            jwtToken: widget.jwtToken,
                            initialPreferredHours: preferredHours,
                            initialHardConstraint: hardConstraint,
                            initialGeneralStartHour: generalStartHour,
                            initialGeneralEndHour: generalEndHour,
                          ),
                        ),
                      );
                      if (result == true) {
                        fetchAllData(); // Refresh after editing
                      }
                    },
                    child: const Text("Edit"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: mainColor),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}