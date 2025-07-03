import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTaskPage extends StatefulWidget {
  final String jwtToken;
  final Map<String, dynamic>? initialTask; // Pass this for editing

  const AddTaskPage({super.key, required this.jwtToken, this.initialTask});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  DateTime? _deadlineDate;
  String _importance = 'Medium';
  String _difficulty = 'Medium';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      final t = widget.initialTask!;
      _titleController.text = t['task_name'] ?? t['name'] ?? '';
      _importance = t['importance'] ?? 'Medium';
      _difficulty = t['difficulty'] ?? 'Medium';
      _deadlineDate = t['deadline'] != null
          ? DateTime.tryParse(t['deadline'])
          : null;
      _commentController.text = t['comment'] ?? '';
    }
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _deadlineDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty || _deadlineDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and deadline')),
      );
      return;
    }
    setState(() => isLoading = true);

    final isEditing = widget.initialTask != null;
    final url = isEditing
        ? 'http://10.0.2.2:5000/tasks/${widget.initialTask!['task_id'] ?? widget.initialTask!['id']}'
        : 'http://10.0.2.2:5000/tasks/';
    final body = jsonEncode({
      'name': _titleController.text.trim(),
      'deadline': _deadlineDate!.toIso8601String(),
      'importance': _importance,
      'difficulty': _difficulty,
      'comment': _commentController.text.trim(),
      'status': 'pending',
      'is_checked': false,
    });

    http.Response response;
    if (isEditing) {
      response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    } else {
      response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
        body: body,
      );
    }

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Task updated!' : 'Task added successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      String msg = 'Failed to save task';
      try {
        msg = jsonDecode(response.body)['error'] ?? msg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBgTop = const Color(0xFFE6F2EC);
    final Color mainBgBottom = const Color(0xFFCFE1DA);
    final Color cardBg = const Color(0xFFD8E6DE);
    final Color dividerColor = Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialTask != null ? 'EDIT TASK' : 'ADD TASK',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: mainBgTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _saveTask,
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.initialTask != null ? 'Save' : 'Add',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBgTop, mainBgBottom],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: cardBg,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Task title
                  Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Task title',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: dividerColor, height: 32),

                  // Deadline picker
                  InkWell(
                    onTap: () => _pickDeadline(context),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          _deadlineDate == null
                              ? 'Add Deadline'
                              : '${_deadlineDate!.day}/${_deadlineDate!.month}/${_deadlineDate!.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: dividerColor, height: 32),

                  // Importance
                  const Text(
                    'Choose its importance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildImportanceCircle('Low', Colors.lightGreen),
                      _buildImportanceCircle('Medium', Colors.green),
                      _buildImportanceCircle('High', Colors.teal),
                    ],
                  ),
                  Divider(color: dividerColor, height: 32),

                  // Difficulty dropdown
                  const Text(
                    'Choose its difficulty',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _difficulty,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: ['Low', 'Medium', 'High'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _difficulty = newValue!;
                        });
                      },
                    ),
                  ),
                  Divider(color: dividerColor, height: 32),

                  // Comment
                  const Text(
                    'Add a comment (optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Type here',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImportanceCircle(String label, Color color) {
    final bool isSelected = _importance == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _importance = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
        child: Text(
          label[0], // Show first letter
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}