import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionnaireWizard extends StatefulWidget {
  final String jwtToken;
  final String age;
  final String gender;
  final String major;
  final String preferredStudyTime;

  const QuestionnaireWizard({
    super.key,
    required this.jwtToken,
    required this.age,
    required this.gender,
    required this.major,
    required this.preferredStudyTime,
  });

  @override
  State<QuestionnaireWizard> createState() => _QuestionnaireWizardState();
}

class _QuestionnaireWizardState extends State<QuestionnaireWizard> {
  List<List<int>> preferredHours = List.generate(7, (i) => [i, 9, 17]);
  bool hardConstraint = false;
  int generalStartHour = 8;
  int generalEndHour = 22;
  int? breakStart;
  int? breakEnd;
  bool isLoading = false;

  List<int> hourOptions = List.generate(24, (i) => i);

  Future<void> saveAllPreferences() async {
    setState(() => isLoading = true);

    // If break is provided, apply to all days
    List<List<int>> breaks = [];
    if (breakStart != null && breakEnd != null && breakEnd! > breakStart!) {
      for (int i = 0; i < 7; i++) {
        breaks.add([i, breakStart!, breakEnd!]);
      }
    }

    final prefsResponse = await http.patch(
      Uri.parse('http://10.0.2.2:5000/users/preferences'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'preferred_working_hours': preferredHours,
        'working_hours_constraint': hardConstraint,
        'general_start_hour': generalStartHour,
        'general_end_hour': generalEndHour,
        'breaks': breaks,
        'age': widget.age,
        'gender': widget.gender,
        'major': widget.major,
        'preferred_study_time': widget.preferredStudyTime,
      }),
    );
    setState(() => isLoading = false);
    if (prefsResponse.statusCode == 200) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save preferences')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Edit Preferences"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("General Working Hours", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Earliest: "),
                  DropdownButton<int>(
                    value: generalStartHour,
                    items: hourOptions.map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                    onChanged: (val) {
                      setState(() {
                        generalStartHour = val!;
                        if (generalEndHour <= generalStartHour) {
                          generalEndHour = generalStartHour + 1 <= 23 ? generalStartHour + 1 : 23;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text("Latest: "),
                  Builder(
                    builder: (context) {
                      final endHourOptions = hourOptions.where((h) => h > generalStartHour).toList();
                      if (!endHourOptions.contains(generalEndHour)) {
                        generalEndHour = endHourOptions.isNotEmpty ? endHourOptions.first : generalStartHour + 1;
                      }
                      return DropdownButton<int>(
                        value: generalEndHour,
                        items: endHourOptions
                            .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                        onChanged: (val) {
                          setState(() {
                            generalEndHour = val!;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Preferred Study Hours?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (int i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 90, child: Text(days[i])),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          final startOptions = hourOptions.where((h) => h >= generalStartHour && h < generalEndHour).toList();
                          if (!startOptions.contains(preferredHours[i][1])) {
                            preferredHours[i][1] = startOptions.isNotEmpty ? startOptions.first : generalStartHour;
                          }
                          return DropdownButton<int>(
                            value: preferredHours[i][1],
                            items: startOptions
                                .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                            onChanged: (val) {
                              setState(() => preferredHours[i][1] = val!);
                              if (preferredHours[i][2] <= preferredHours[i][1]) {
                                preferredHours[i][2] = preferredHours[i][1] + 1 <= generalEndHour ? preferredHours[i][1] + 1 : generalEndHour;
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          final endOptions = hourOptions.where((h) => h > preferredHours[i][1] && h <= generalEndHour).toList();
                          if (!endOptions.contains(preferredHours[i][2])) {
                            preferredHours[i][2] = endOptions.isNotEmpty ? endOptions.first : preferredHours[i][1] + 1;
                          }
                          return DropdownButton<int>(
                            value: preferredHours[i][2],
                            items: endOptions
                                .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                            onChanged: (val) {
                              setState(() => preferredHours[i][2] = val!);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text("Default Break (optional, applies to all days):", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Start: "),
                  DropdownButton<int>(
                    value: breakStart,
                    hint: const Text("Select"),
                    items: hourOptions.map((h) => DropdownMenuItem(value: h, child: Text("$h:00"))).toList(),
                    onChanged: (val) => setState(() => breakStart = val),
                  ),
                  const SizedBox(width: 16),
                  const Text("End: "),
                  DropdownButton<int>(
                    value: breakEnd,
                    hint: const Text("Select"),
                    items: hourOptions.where((h) => breakStart == null || h > breakStart!).map((h) => DropdownMenuItem(value: h, child: Text("$h:00"))).toList(),
                    onChanged: (val) => setState(() => breakEnd = val),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "You can edit each day's break in the Edit Preferences section in the drawer.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text("What is your preferred scheduling mode?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => hardConstraint = true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF35746C)),
                        foregroundColor: hardConstraint ? Colors.white : const Color(0xFF35746C),
                        backgroundColor: hardConstraint ? const Color(0xFF35746C) : Colors.white,
                      ),
                      child: const Text("Preferred Hours Only"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => hardConstraint = false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF35746C)),
                        foregroundColor: !hardConstraint ? Colors.white : const Color(0xFF35746C),
                        backgroundColor: !hardConstraint ? const Color(0xFF35746C) : Colors.white,
                      ),
                      child: const Text("Flexible Hours"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35746C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isLoading ? null : saveAllPreferences,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}