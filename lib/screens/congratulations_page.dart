import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/home_page.dart';

class CongratulationsPage extends StatelessWidget {
  final String jwtToken;
  const CongratulationsPage({Key? key, required this.jwtToken}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Confetti background (optional)
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/img/confetti.png',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Time display at the top
                  // const Align(
                  //   alignment: Alignment.topRight,
                  //   child: Text(
                  //     '9:41',
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 40),
                  // Congratulations image
                  Image.asset(
                    'assets/img/confetti.png', // Make sure to add this image to your assets
                    height: 400,
                  ),
                  const SizedBox(height: 30),
                  // Congratulations text
                  // const Text(
                  //   'Congratulations!',
                  //   style: TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  // Description text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Your account is all set! Get ready to take control of your time and boost your productivity. Start adding tasks, creating your perfect schedule, and achieving your goals. Let\'s make every moment count!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Get started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage(jwtToken: jwtToken)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF298267),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Let's get started!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}