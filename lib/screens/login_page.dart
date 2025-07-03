import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:schedule_planner/screens/otp_page.dart';
import 'package:schedule_planner/screens/signup_page.dart';
import 'package:schedule_planner/screens/forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('http://10.0.2.2:5000/users/login'); // Change as needed

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': emailController.text, // backend expects 'username'
        'password': passwordController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['access_token'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationCodePage(
            email: emailController.text,
            jwtToken: token,
          ),
        ),
      );
    } else {
      String errorMsg = 'Login failed';
      try {
        errorMsg = jsonDecode(response.body)['error'] ?? errorMsg;
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    setState(() => isLoading = true);
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/users/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['access_token'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationCodePage(
              email: emailController.text,
              jwtToken: token,
            ),
          ),
        );
      } else {
        String errorMsg = 'Google login failed';
        try {
          errorMsg = jsonDecode(response.body)['error'] ?? errorMsg;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    }
  }

  Future<void> loginWithFacebook(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;

        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/users/login/facebook'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'access_token': accessToken}),
        );

        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          final token = jsonDecode(response.body)['access_token'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Facebook login successful!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationCodePage(
                email: emailController.text,
                jwtToken: token,
              ),
            ),
          );
        }else {
          String errorMsg = 'Facebook login failed';
          try {
            errorMsg = jsonDecode(response.body)['error'] ?? errorMsg;
          } catch (_) {}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook login cancelled or failed.')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-in error: $e')),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          loginUser(context);
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
                          'Login',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member? ',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Or continue with',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.facebook, size: screenWidth * 0.08),
                    onPressed: isLoading
                        ? null
                        : () {
                            loginWithFacebook(context);
                          },
                  ),
                  IconButton(
                    icon: Icon(Icons.g_mobiledata, size: screenWidth * 0.08),
                    onPressed: isLoading
                        ? null
                        : () {
                            loginWithGoogle(context);
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}