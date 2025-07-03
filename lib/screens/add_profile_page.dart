import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schedule_planner/screens/congratulations_page.dart';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _uploadProfilePicture(File image) async {
    setState(() => _isUploading = true);
    final uri = Uri.parse('http://10.0.2.2:5000/users/upload_profile_picture');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${widget.jwtToken}'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));
    final response = await request.send();
    setState(() => _isUploading = false);
    if (response.statusCode == 200) {
      // Optionally handle response if you want to use the returned URL
    }
  }

  void _goToCongrats() async {
    if (_image != null) {
      await _uploadProfilePicture(_image!);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CongratulationsPage(jwtToken: widget.jwtToken)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Add your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Add your profile picture to complete your account setup and personalize your experience!',
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
            const Spacer(),
            ElevatedButton(
              onPressed: _isUploading ? null : _goToCongrats,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF298267),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add profile"),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _isUploading ? null : _goToCongrats,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF298267)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Add later"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}