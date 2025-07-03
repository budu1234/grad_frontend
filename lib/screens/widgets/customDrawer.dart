import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/agenda_page.dart';
import 'package:schedule_planner/screens/calender_page.dart';
import 'package:schedule_planner/screens/home_page.dart';
import 'package:schedule_planner/screens/login_page.dart';
import 'package:schedule_planner/screens/search_page.dart';
import 'package:schedule_planner/screens/setting_page.dart';
import 'package:schedule_planner/screens/weekly_report_age.dart';
import 'package:schedule_planner/screens/preferred_study_hours_page.dart';
import 'package:schedule_planner/screens/add_profile_page.dart';
import 'package:schedule_planner/screens/weekly_schedule_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomDrawer extends StatefulWidget {
  final String jwtToken;
  const CustomDrawer({super.key, required this.jwtToken});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    setState(() {
      isLoading = true;
    });
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['username'] ?? "Home",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user?['profile_picture'] != null
                                  ? NetworkImage('http://10.0.2.2:5000/static/profile_pics/${user!['profile_picture']}')
                                  : null,
                              child: user?['profile_picture'] == null
                                  ? Icon(Icons.person, color: Colors.grey[600])
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?['email'] ?? "User@gmail.com",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?['phone_number'] ?? "",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const Divider(),

            // Make the drawer scrollable if it overflows
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDrawerItem(
                      context,
                      Icons.home,
                      "Home",
                      destination: MaterialPageRoute(builder: (context) => HomePage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.check_box,
                      "Agenda",
                      destination: MaterialPageRoute(builder: (context) => AgendaPage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.calendar_today,
                      "Calendar",
                      destination: MaterialPageRoute(builder: (context) => CalenderPage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.bar_chart,
                      "Weekly report",
                      destination: MaterialPageRoute(builder: (context) => WeeklyReportPage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.settings,
                      "Settings",
                      destination: MaterialPageRoute(builder: (context) => SettingsScreen(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.person,
                      "Profile",
                      destination: MaterialPageRoute(builder: (context) => AddProfilePage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.view_week,
                      "Weekly Schedule",
                      destination: MaterialPageRoute(builder: (context) => WeeklySchedulePage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.access_time,
                      "Preferred Study Hours",
                      destination: MaterialPageRoute(builder: (context) => PreferredStudySummaryPage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.notifications,
                      "Reminder",
                      destination: MaterialPageRoute(builder: (context) => const PlaceholderPage(title: "Reminder")),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.search,
                      "Search",
                      destination: MaterialPageRoute(builder: (context) => SearchPage(jwtToken: widget.jwtToken)),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.book,
                      "Subjects",
                      destination: MaterialPageRoute(builder: (context) => const PlaceholderPage(title: "Subjects")),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.help_outline,
                      "Help & Feedback",
                      destination: MaterialPageRoute(builder: (context) => const PlaceholderPage(title: "Help & Feedback")),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section (logout button)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign out"),
                  onPressed: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title, {
        bool isLogout = false,
        Route? destination,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Icon(
          icon,
          color: title == "Home" ? const Color(0xFF35746C) : Colors.grey[600],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (destination != null) {
          Navigator.push(context, destination);
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Signout"),
        content: const Text("Are you sure you want to signout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text("Sign out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title Page")),
    );
  }
}