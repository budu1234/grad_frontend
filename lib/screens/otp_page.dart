import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:schedule_planner/screens/home_page.dart';

class ConfirmationCodePage extends StatefulWidget {
  final String jwtToken;
  final String email;
  ConfirmationCodePage({required this.email, required this.jwtToken}); // <-- Add jwtToken here


  @override
  _ConfirmationCodePageState createState() => _ConfirmationCodePageState();
}

class _ConfirmationCodePageState extends State<ConfirmationCodePage> {
  String code = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sendCode();
  }

  Future<void> sendCode() async {
    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users/send_confirmation_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmation code sent to ${widget.email}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code')),
      );
    }
  }

  Future<void> verifyCode() async {
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a 4-digit code')),
      );
      return;
    }
    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/users/verify_confirmation_code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'code': code}),
    );
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(jwtToken: widget.jwtToken)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid code')),
      );
    }
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'backspace') {
        if (code.isNotEmpty) {
          code = code.substring(0, code.length - 1);
        }
      } else if (code.length < 4) {
        code += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.04),
                Text(
                  'Enter confirmation code',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'A 4-digit code was sent to\n${widget.email}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.15,
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          index < code.length ? code[index] : '',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: screenHeight * 0.04),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    '1','2','3','4','5','6','7','8','9','','0','backspace',
                  ].map((value) {
                    return GestureDetector(
                      onTap: () => _onKeyPressed(value),
                      child: Center(
                        child: value == 'backspace'
                            ? Icon(Icons.backspace, size: screenWidth * 0.06)
                            : Text(
                                value,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: isLoading ? null : sendCode,
                  child: Text(
                    isLoading ? 'Sending...' : 'Resend code',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : verifyCode,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      backgroundColor: const Color(0xFF298267),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}