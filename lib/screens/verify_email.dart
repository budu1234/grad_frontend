import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:schedule_planner/screens/questionnaire_wizard.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String jwtToken;

  const VerifyEmailPage({
    super.key,
    required this.email,
    required this.jwtToken,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String errorMsg = '';

  Future<void> verifyCode() async {
    setState(() {
      isLoading = true;
      errorMsg = '';
    });
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users/verify_confirmation_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'code': codeController.text,
      }),
    );
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuestionnaireWizard(jwtToken: widget.jwtToken)),
      );
    } else {
      setState(() {
        errorMsg = 'Invalid code. Please try again.';
      });
    }
  }

  Future<void> resendCode() async {
    setState(() {
      isLoading = true;
      errorMsg = '';
    });
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users/send_confirmation_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent! Please check your email.')),
      );
    } else {
      setState(() {
        errorMsg = 'Failed to resend code.';
      });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please verify your email",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "We’ve sent an email to ${widget.email}, please enter the code below.",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text("Enter Code", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "Enter code",
                border: OutlineInputBorder(),
                counterText: "",
                errorText: errorMsg.isNotEmpty ? errorMsg : null,
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
                onPressed: isLoading ? null : verifyCode,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify"),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : resendCode,
                child: const Text("Didn’t see your email? Resend"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}