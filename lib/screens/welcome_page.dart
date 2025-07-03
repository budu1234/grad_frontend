import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
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
              // Title
              Text(
                'Welcome to your school',
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing

              // Subtitle
              Text(
                'schedule planner',
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Responsive font size
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04), // Responsive spacing

              // Description
              Text(
                'We will walk you through how to configure the app for the',
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // Responsive font size
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.06), // Responsive spacing

              // Get Started Button
              SizedBox(
                width: screenWidth * 0.6, // Responsive button width
                child: ElevatedButton(
                  onPressed: () {
                    // Add navigation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    backgroundColor: Colors.blue,
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
    );
  }
}