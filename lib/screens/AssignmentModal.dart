import 'package:flutter/material.dart';

class AssignmentModal extends StatelessWidget {
  const AssignmentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E8E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9E8E5),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Homework",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF298267),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.radio_button_off), title: Text("Add a title")),
          ListTile(leading: Icon(Icons.calendar_today), title: Text("Add date")),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text("Remind at 16:00", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Day before"),
          ),
          ListTile(leading: Icon(Icons.book_outlined), title: Text("Add subject")),
          ListTile(leading: Icon(Icons.attachment_outlined), title: Text("Add attachments")),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Add a note"),
          ),
          Divider(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Subtasks", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.add, color: Color(0xFF298267)),
            title: Text("Add subtask", style: TextStyle(color: Color(0xFF298267), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
