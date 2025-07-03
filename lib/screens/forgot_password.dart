import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool codeSent = false;
  bool isLoading = false;

  Future<void> sendCode() async {
    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users/send_confirmation_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text}),
    );
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      setState(() => codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code sent to ${emailController.text}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code')),
      );
    }
  }

  Future<void> resetPassword() async {
    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'code': codeController.text,
        'new_password': newPasswordController.text,
      }),
    );
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset successful! Please log in.')),
      );
      Navigator.pop(context); // Go back to login
    } else {
      String msg = 'Failed to reset password';
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: codeSent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter the code sent to ${emailController.text} and your new password.",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  const Text("Code", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      hintText: "4-digit code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("New Password", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter new password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35746C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: isLoading ? null : resetPassword,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text("Reset Password"),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Enter the email address registered with your account. We’ll send you a code to reset your password.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "your@email.com",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF35746C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: isLoading ? null : sendCode,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text("Send Code"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}