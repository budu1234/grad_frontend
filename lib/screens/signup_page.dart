import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schedule_planner/screens/after_signup_page.dart';
import 'dart:convert';
import 'package:schedule_planner/screens/questionnaire_wizard.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool agreeToTerms = false;
  bool isLoading = false;

  Future<void> registerUser(BuildContext context) async {
    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must agree to the Terms and Conditions.')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('http://10.0.2.2:5000/users/register'); // Replace with your backend URL

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': nameController.text,
        'password': passwordController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      final token = jsonDecode(response.body)['access_token'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionnairePage(jwtToken: token),
        ),
      );
    } else {
      String errorMsg = 'Registration failed';
      try {
        errorMsg = jsonDecode(response.body)['error'] ?? errorMsg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.04),
                Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Create an account to get started',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF298267), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'name@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF298267), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF298267), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Confirm password',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF298267), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: '+20*******',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF298267), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFF298267);
                              }
                              return Colors.grey;
                            },
                          ),
                        ),
                      ),
                      child: Checkbox(
                        value: agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            agreeToTerms = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'I\'ve read and agree with the Terms and Conditions and the Privacy Policy.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            registerUser(context);
                          },
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
                            'Sign Up',
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