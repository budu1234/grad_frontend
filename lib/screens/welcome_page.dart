import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/login_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Image covering the top half of the screen
            Container(
              width: screenWidth, // Full width
              height: screenHeight * 0.57, // Half of the screen height
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/welcome.png'), // Your image
                  fit: BoxFit.cover, // Cover the entire container
                ),
              ),
            ),
            // Text and Button Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Welcome to Kairos',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02), // Spacing

                    // Subtitle
                    Text(
                      'Your smart schedule planner',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Responsive font size
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.04), // Spacing

                    // Description
                    Text(
                      'We will walk you through how to set up the app for your needs.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Responsive font size
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.06), // Spacing

                    // Get Started Button
                    SizedBox(
                      width: screenWidth * 0.6, // Responsive button width
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Login Page
                          Navigator.push(
                            context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          backgroundColor: const Color(0xFF298267),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Let\'s get started',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // Responsive font size
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}