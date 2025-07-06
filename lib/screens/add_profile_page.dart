import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schedule_planner/screens/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProfilePage extends StatefulWidget {
  final String jwtToken;
  const AddProfilePage({Key? key, required this.jwtToken}) : super(key: key);

  @override
  _AddProfilePageState createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  File? _image;
  bool _isUploading = false;
  final TextEditingController _nameController = TextEditingController();
  String? _profilePicUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isUploading = true);

    try {
      // Update name
      if (_nameController.text.isNotEmpty) {
        final response = await http.put(
          Uri.parse('http://10.0.2.2:5000/users/update_name'),
          headers: {
            'Authorization': 'Bearer ${widget.jwtToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'name': _nameController.text}),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to update name');
        }
      }

      // Update profile picture
      if (_image != null) {
        final uri = Uri.parse('http://10.0.2.2:5000/users/upload_profile_picture');
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer ${widget.jwtToken}'
          ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
        final response = await request.send();
        if (response.statusCode != 200) {
          throw Exception('Failed to upload profile picture');
        }
      }

      setState(() => _isUploading = false);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(jwtToken: widget.jwtToken),
        ),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Edit your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Update your name and profile picture to personalize your experience!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isUploading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF298267),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}