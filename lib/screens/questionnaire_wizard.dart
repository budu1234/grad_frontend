import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schedule_planner/screens/congratulations_page.dart';

class QuestionnaireWizard extends StatefulWidget {
  final String jwtToken;
  const QuestionnaireWizard({super.key, required this.jwtToken});

  @override
  State<QuestionnaireWizard> createState() => _QuestionnaireWizardState();
}

class _QuestionnaireWizardState extends State<QuestionnaireWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? age;
  String? gender;
  String? major;

  List<Map<String, dynamic>> preferredStudyHours = List.generate(7, (index) => {
    "day": [
      "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ][index],
    "start": null,
    "end": null,
    "dayOff": false,
  });

  String? breakStart;
  String? breakEnd;
  String? generalStartHour;
  String? generalEndHour;

  // Scheduling mode: "flexible" or "preferred"
  String? schedulingMode; // "flexible" or "preferred"

  final List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  final List<String> timeSlots = [
    for (int h = 6; h <= 23; h++)
      "${h % 12 == 0 ? 12 : h % 12}:00 ${h < 12 ? 'AM' : 'PM'}"
  ];
  final List<String> ageOptions = [
    "Between 12–18",
    "Between 18–22",
    "Between 22–26",
    "Between 26–28"
  ];
  final List<String> genderOptions = ["Male", "Female"];
  final List<String> majorOptions = [
    "Engineering", "Information Technology", "Business", "Medicine", "Dentistry",
    "Political Science", "Pharmacy", "Architecture", "Fine Arts", "School Student", "Other"
  ];

  int timeStringToHour(String time, {bool isEnd = false}) {
    final parts = time.split(' ');
    int hour = int.parse(parts[0].split(':')[0]);
    final isPM = parts[1] == 'PM';
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    // If this is the end hour and it's 0 (midnight), treat as 24
    if (isEnd && hour == 0) hour = 24;
    return hour;
  }

  List<String> buildGeneralStartOptions() {
    int? earliest;
    for (final day in preferredStudyHours) {
      if ((day["dayOff"] ?? false) || day["start"] == null) continue;
      int hour = timeStringToHour(day["start"]);
      if (earliest == null || hour < earliest) earliest = hour;
    }
    if (earliest == null) earliest = 9;
    return [for (int h = 6; h <= earliest; h++) "${h % 12 == 0 ? 12 : h % 12}:00 ${h < 12 ? 'AM' : 'PM'}"];
  }

  List<String> buildGeneralEndOptions() {
    int? latest;
    for (final day in preferredStudyHours) {
      if ((day["dayOff"] ?? false) || day["end"] == null) continue;
      int hour = timeStringToHour(day["end"]);
      if (latest == null || hour > latest) latest = hour;
    }
    if (latest == null) latest = 17;
    return [for (int h = latest; h <= 23; h++) "${h == 24 ? 12 : h % 12 == 0 ? 12 : h % 12}:00 ${h < 12 || h == 24 ? 'AM' : 'PM'}"];
  }

  void nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget buildProgressBar() {
    return LinearProgressIndicator(
      value: (_currentPage + 1) / 7,
      backgroundColor: Colors.grey.shade300,
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27876A)),
      minHeight: 6,
    );
  }

  Widget buildDecoratedBackground({required Widget child}) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset("assets/img/wireframe001.png", width: 100),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset("assets/img/wireframe002.png", width: 100),
        ),
        child,
      ],
    );
  }

  Widget buildDropdown(String? value, List<String> items, Function(String?) onChanged, {String? hint, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF27876A), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint ?? 'Select'),
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: enabled ? onChanged : null,
        disabledHint: value != null ? Text(value) : Text(hint ?? 'Select'),
      ),
    );
  }

  Widget buildAgePage() {
    return buildDecoratedBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Some questions to know\nmore about you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text("Your age?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...ageOptions.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: age,
              activeColor: const Color(0xFF27876A),
              onChanged: (val) => setState(() => age = val),
            )),
          ],
        ),
      ),
    );
  }

  Widget buildGenderPage() {
    return buildDecoratedBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Some questions to know\nmore about you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text("Your Gender?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...genderOptions.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gender == option ? const Color(0xFF27876A) : Colors.white,
                    foregroundColor: gender == option ? Colors.white : Colors.black,
                    side: BorderSide(color: const Color(0xFF27876A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => setState(() => gender = option),
                  child: Text(option),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget buildMajorPage() {
    return buildDecoratedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Some questions to know\nmore about you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text("Your major?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...majorOptions.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: major,
              activeColor: const Color(0xFF27876A),
              onChanged: (val) => setState(() => major = val),
            )),
          ],
        ),
      ),
    );
  }

  Widget buildPreferredStudyHoursPage() {
    return buildDecoratedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Some questions to know\nmore about you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text("Preferred Study Hours for Each Day", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: preferredStudyHours.asMap().entries.map((entry) {
                int i = entry.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(days[i], style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        flex: 3,
                        child: buildDropdown(
                          preferredStudyHours[i]["start"],
                          timeSlots,
                          (val) => setState(() => preferredStudyHours[i]["start"] = val),
                          hint: "Start",
                          enabled: !(preferredStudyHours[i]["dayOff"] ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: buildDropdown(
                          preferredStudyHours[i]["end"],
                          timeSlots,
                          (val) => setState(() => preferredStudyHours[i]["end"] = val),
                          hint: "End",
                          enabled: !(preferredStudyHours[i]["dayOff"] ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text("Day Off", style: TextStyle(fontSize: 12)),
                          Checkbox(
                            value: preferredStudyHours[i]["dayOff"] ?? false,
                            onChanged: (val) {
                              setState(() {
                                preferredStudyHours[i]["dayOff"] = val ?? false;
                                if (val == true) {
                                  preferredStudyHours[i]["start"] = null;
                                  preferredStudyHours[i]["end"] = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGeneralHoursPage() {
    final generalStartOptions = buildGeneralStartOptions();
    final generalEndOptions = buildGeneralEndOptions();

    return buildDecoratedBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Some questions to know\nmore about you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text("General Available Hours", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: buildDropdown(
                    generalStartHour,
                    generalStartOptions,
                    (val) => setState(() => generalStartHour = val),
                    hint: "Earliest Start",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildDropdown(
                    generalEndHour,
                    generalEndOptions,
                    (val) => setState(() => generalEndHour = val),
                    hint: "Latest End",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "These hours define the earliest and latest times you are available for scheduling.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSchedulingModePage() {
    return buildDecoratedBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Choose Your Scheduling Mode",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            RadioListTile<String>(
              title: const Text("Flexible"),
              value: "flexible",
              groupValue: schedulingMode,
              activeColor: Color(0xFF27876A),
              onChanged: (val) => setState(() => schedulingMode = val),
              subtitle: const Text(
                "The scheduler can use any time between your general available hours. "
                "This gives the AI more freedom to optimize your schedule.",
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text("Preferred Working Hours"),
              value: "preferred",
              groupValue: schedulingMode,
              activeColor: Color(0xFF27876A),
              onChanged: (val) => setState(() => schedulingMode = val),
              subtitle: const Text(
                "The scheduler will only use the hours you set for each day. "
                "No tasks will be scheduled outside your preferred working hours.",
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBreaksPage() {
    return buildDecoratedBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProgressBar(),
            const SizedBox(height: 24),
            const Text(
              "Some questions to know\nmore about you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const Text("Default Break Hours (optional)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: buildDropdown(breakStart, timeSlots, (val) => setState(() => breakStart = val), hint: "Start time")),
                const SizedBox(width: 8),
                Expanded(child: buildDropdown(breakEnd, timeSlots, (val) => setState(() => breakEnd = val), hint: "End time")),
              ],
            ),
            if (breakStart != null && breakEnd != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "This break will be used as the default for all days. You can edit each day's break time in the Edit Preferences menu.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> submitQuestionnaire() async {
    // Convert general hours to int
    final int? generalStart = generalStartHour != null ? timeStringToHour(generalStartHour!) : null;
    final int? generalEnd = generalEndHour != null ? timeStringToHour(generalEndHour!) : null;

    // Validate: general hours must be greater than or equal to all preferred hours
    for (final entry in preferredStudyHours) {
      if ((entry["dayOff"] ?? false) || entry["start"] == null || entry["end"] == null) continue;
      final int start = timeStringToHour(entry["start"]);
      final int end = timeStringToHour(entry["end"]);
      if (generalStart == null || generalEnd == null || generalStart > start || generalEnd < end) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("General hours must be greater than or equal to all preferred working hours for all days."),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop submission
      }
    }

    // --- Convert to backend format ---
    final preferredStudyHoursList = preferredStudyHours
        .asMap()
        .entries
        .where((entry) =>
            !(entry.value["dayOff"] ?? false) &&
            entry.value["start"] != null &&
            entry.value["end"] != null)
        .map((entry) => [
              entry.key, // day index: 0=Sunday, 6=Saturday
              timeStringToHour(entry.value["start"]),
              timeStringToHour(entry.value["end"]),
            ])
        .toList();

    final data = {
      "age": age,
      "gender": gender,
      "major": major,
      "preferred_working_hours": preferredStudyHoursList,
      "working_hours_constraint": schedulingMode == "preferred", // true for preferred, false for flexible
      "break_start": breakStart,
      "break_end": breakEnd,
      "general_start_hour": generalStart,
      "general_end_hour": generalEnd,
    };
    // --- END ---

    final url = Uri.parse('http://10.0.2.2:5000/users/preferences');
    await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CongratulationsPage(jwtToken: widget.jwtToken),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoNext = () {
      switch (_currentPage) {
        case 0:
          return age != null;
        case 1:
          return gender != null;
        case 2:
          return major != null;
        case 3:
          return true;
        case 4:
          return generalStartHour != null && generalEndHour != null;
        case 5:
          return schedulingMode != null;
        default:
          return true;
      }
    }();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire", style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    buildAgePage(),
                    buildGenderPage(),
                    buildMajorPage(),
                    buildPreferredStudyHoursPage(),
                    buildGeneralHoursPage(),
                    buildSchedulingModePage(),
                    buildBreaksPage(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: previousPage,
                        child: const Text("Previous"),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27876A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: canGoNext
                          ? () {
                              if (_currentPage == 6) {
                                submitQuestionnaire();
                              } else {
                                nextPage();
                              }
                            }
                          : null,
                      child: Text(_currentPage == 6 ? "Finish" : "Next", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}