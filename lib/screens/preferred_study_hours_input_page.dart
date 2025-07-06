import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreferredStudyHoursInputPage extends StatefulWidget {
  final String jwtToken;
  final List<dynamic>? initialPreferredHours;
  final bool? initialHardConstraint;
  final int? initialGeneralStartHour;
  final int? initialGeneralEndHour;

  const PreferredStudyHoursInputPage({
    super.key,
    required this.jwtToken,
    this.initialPreferredHours,
    this.initialHardConstraint,
    this.initialGeneralStartHour,
    this.initialGeneralEndHour,
  });

  @override
  State<PreferredStudyHoursInputPage> createState() => _PreferredStudyHoursInputPageState();
}

class _PreferredStudyHoursInputPageState extends State<PreferredStudyHoursInputPage> {
  final Color mainColor = const Color(0xFF35746C);

  final List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  List<Map<String, dynamic>> preferredHours = [];
  bool hardConstraint = false;
  bool isLoading = false;

  // General working hours
  int generalStartHour = 8;
  int generalEndHour = 22;

  // Breaks: Map<day_of_week, List<[start_hour, end_hour, id]>>
  Map<int, List<List<int>>> breaks = {};

  List<int> hourOptions = List.generate(24, (i) => i);

  @override
  void initState() {
    super.initState();
    // Build preferredHours as a list of maps for each day
    Map<int, List<int>> initialMap = {};
    if (widget.initialPreferredHours != null) {
      for (var entry in widget.initialPreferredHours!) {
        if (entry is List && entry.length == 3) {
          initialMap[entry[0]] = [entry[1], entry[2]];
        }
      }
    }
    preferredHours = List.generate(7, (i) {
      if (initialMap.containsKey(i)) {
        return {
          "day": i,
          "start": initialMap[i]![0],
          "end": initialMap[i]![1],
          "dayOff": false,
        };
      } else {
        return {
          "day": i,
          "start": generalStartHour,
          "end": generalStartHour + 1,
          "dayOff": true,
        };
      }
    });
    hardConstraint = widget.initialHardConstraint ?? false;
    generalStartHour = widget.initialGeneralStartHour ?? 8;
    generalEndHour = widget.initialGeneralEndHour ?? 22;
    fetchBreaks();
  }

  Future<void> fetchBreaks() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/breaks/'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      final breaksList = jsonDecode(response.body) as List;
      setState(() {
        breaks = {};
        for (var br in breaksList) {
          final day = br['day_of_week'];
          breaks.putIfAbsent(day, () => []);
          breaks[day]!.add([br['start_hour'], br['end_hour'], br['id']]);
        }
      });
    }
  }

  Future<void> savePreferences() async {
    // Validation: general hours must be greater than or equal to all preferred hours
    for (final d in preferredHours) {
      if (d['dayOff'] == true) continue;
      final int start = d['start'] as int;
      final int end = d['end'] as int;
      if (generalStartHour > start || generalEndHour < end) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("General working hours must be greater than or equal to all preferred working hours for all days."),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop submission
      }
    }

    setState(() => isLoading = true);
    // Only include days that are not day off
    final List<List<int>> toSend = preferredHours
        .where((d) => d['dayOff'] == false)
        .map((d) => [
          (d['day'] as int),
          (d['start'] as int),
          (d['end'] as int),
        ])
        .toList();
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:5000/users/preferences'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'preferred_working_hours': toSend,
        'working_hours_constraint': hardConstraint,
        'general_start_hour': generalStartHour,
        'general_end_hour': generalEndHour,
      }),
    );
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save preferences')),
      );
    }
  }

  Future<void> addBreak(int day, int start, int end) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/breaks/'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'day_of_week': day,
        'start_hour': start,
        'end_hour': end,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      fetchBreaks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add break')),
      );
    }
  }

  Future<void> deleteBreak(int breakId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:5000/breaks/$breakId'),
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );
    if (response.statusCode == 200) {
      fetchBreaks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete break')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        // Ensure end hour is always after start hour
                        if (generalEndHour <= generalStartHour) {
                          generalEndHour = generalStartHour + 1 <= 23 ? generalStartHour + 1 : 23;
                        }
                        // Also update preferredHours if needed
                        for (var d in preferredHours) {
                          if ((d['start'] as int) < generalStartHour) d['start'] = generalStartHour;
                          if ((d['end'] as int) <= d['start']) d['end'] = d['start'] + 1 <= generalEndHour ? d['start'] + 1 : generalEndHour;
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
                            // Also update preferredHours if needed
                            for (var d in preferredHours) {
                              if ((d['end'] as int) > generalEndHour) d['end'] = generalEndHour;
                              if ((d['start'] as int) >= generalEndHour) d['start'] = generalEndHour - 1;
                              if ((d['end'] as int) <= d['start']) d['end'] = d['start'] + 1 <= generalEndHour ? d['start'] + 1 : generalEndHour;
                            }
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
                      Checkbox(
                        value: preferredHours[i]['dayOff'] ?? false,
                        onChanged: (val) {
                          setState(() {
                            preferredHours[i]['dayOff'] = val ?? false;
                            if (val == true) {
                              preferredHours[i]['start'] = generalStartHour;
                              preferredHours[i]['end'] = generalStartHour + 1 <= generalEndHour ? generalStartHour + 1 : generalEndHour;
                            }
                          });
                        },
                      ),
                      const Text("Day Off"),
                      const SizedBox(width: 8),
                      if (!(preferredHours[i]['dayOff'] ?? false))
                        ...[
                          Builder(
                            builder: (context) {
                              final startOptions = hourOptions
                                  .where((h) => h >= generalStartHour && h < generalEndHour)
                                  .toList();
                              if (!startOptions.contains(preferredHours[i]['start'])) {
                                preferredHours[i]['start'] = startOptions.isNotEmpty ? startOptions.first : generalStartHour;
                              }
                              return DropdownButton<int>(
                                value: preferredHours[i]['start'],
                                items: startOptions
                                    .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    preferredHours[i]['start'] = val!;
                                    // Adjust end if needed
                                    if (preferredHours[i]['end'] <= preferredHours[i]['start']) {
                                      final endOptions = hourOptions
                                          .where((h) => h > preferredHours[i]['start'] && h <= generalEndHour)
                                          .toList();
                                      preferredHours[i]['end'] = endOptions.isNotEmpty ? endOptions.first : preferredHours[i]['start'] + 1;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final endOptions = hourOptions
                                  .where((h) => h > preferredHours[i]['start'] && h <= generalEndHour)
                                  .toList();
                              if (!endOptions.contains(preferredHours[i]['end'])) {
                                preferredHours[i]['end'] = endOptions.isNotEmpty ? endOptions.first : preferredHours[i]['start'] + 1;
                              }
                              return DropdownButton<int>(
                                value: preferredHours[i]['end'],
                                items: endOptions
                                    .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    preferredHours[i]['end'] = val!;
                                  });
                                },
                              );
                            },
                          ),
                        ]
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text("Breaks", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (int i = 0; i < 7; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(days[i], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF35746C))),
                    ...(breaks[i] ?? []).map((br) => Row(
                          children: [
                            Text("${br[0]}:00 - ${br[1]}:00"),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              onPressed: () => deleteBreak(br[2]),
                            ),
                          ],
                        )),
                    Row(
                      children: [
                        DropdownButton<int>(
                          hint: const Text("Start"),
                          value: null,
                          items: hourOptions
                              .where((h) => h >= generalStartHour && h < generalEndHour)
                              .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                          onChanged: (start) async {
                            int? end = await showDialog<int>(
                              context: context,
                              builder: (context) {
                                int? selectedEnd;
                                return AlertDialog(
                                  title: const Text("Select End Hour"),
                                  content: DropdownButton<int>(
                                    value: selectedEnd,
                                    hint: const Text("End"),
                                    items: hourOptions
                                        .where((h) => start != null && h > start && h <= generalEndHour)
                                        .map((h) => DropdownMenuItem(value: h, child: Text("${h.toString().padLeft(2, '0')}:00"))).toList(),
                                    onChanged: (val) {
                                      selectedEnd = val;
                                      Navigator.pop(context, val);
                                    },
                                  ),
                                );
                              },
                            );
                            if (start != null && end != null) {
                              addBreak(i, start, end);
                            }
                          },
                        ),
                        const Text("to"),
                        const SizedBox(width: 8),
                        const Text("Add Break"),
                      ],
                    ),
                  ],
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
                        side: BorderSide(color: mainColor),
                        foregroundColor: hardConstraint ? Colors.white : mainColor,
                        backgroundColor: hardConstraint ? mainColor : Colors.white,
                      ),
                      child: const Text("Preferred Hours Only"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => hardConstraint = false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: mainColor),
                        foregroundColor: !hardConstraint ? Colors.white : mainColor,
                        backgroundColor: !hardConstraint ? mainColor : Colors.white,
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
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isLoading ? null : savePreferences,
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