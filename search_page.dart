import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/widgets/customDrawer.dart';

class SearchPage extends StatelessWidget {
  final String jwtToken;
  const SearchPage({super.key, required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(jwtToken: widget.jwtToken, currentPage: DrawerPage.checklist),      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_sharp, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Search",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // handle notification tap
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5F2),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF298267)),
                  hintText: "Search for a subject, date, homework or exam title",
                  hintStyle: TextStyle(color: Color(0xFF298267)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            _searchOptionTile("My subjects"),
            const SizedBox(height: 12),
            _searchOptionTile("Homework"),
            const SizedBox(height: 32),

            // Optional Message
            const Text(
              "We have 2 options\neither a simple\nmessage or but the\noptions under the\nsearch bar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),

            // Bottom message
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  "Here, you can effortlessly\nsearch for tasks attachments,\nnotes, subtasks, subjects, and\nmore. Let’s get started and find\nwhat you need",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchOptionTile(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
