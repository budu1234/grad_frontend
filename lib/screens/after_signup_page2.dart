import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/questionnaire_wizard.dart';

class QuestionnairePage2 extends StatefulWidget {
  final String jwtToken;
  final String age;
  final String gender;
  final String major;

  const QuestionnairePage2({
    super.key,
    required this.jwtToken,
    required this.age,
    required this.gender,
    required this.major,
  });

  @override
  _QuestionnairePage2State createState() => _QuestionnairePage2State();
}

class _QuestionnairePage2State extends State<QuestionnairePage2> {
  String? preferredStudyTime;

  final List<String> studyTimeOptions = ['Early morning', 'Afternoon', 'After University'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Some questions to know more about you',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text('Preferred study time', style: TextStyle(fontSize: screenWidth * 0.04)),
              SizedBox(height: screenHeight * 0.01),
              ...studyTimeOptions.map((time) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: preferredStudyTime == time ? const Color(0xFF298267) : Colors.white,
                    foregroundColor: preferredStudyTime == time ? Colors.white : Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => setState(() => preferredStudyTime = time),
                  child: Text(time),
                ),
              )),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (preferredStudyTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select your preferred study time')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionnaireWizard(
                          jwtToken: widget.jwtToken,
                          age: widget.age,
                          gender: widget.gender,
                          major: widget.major,
                          preferredStudyTime: preferredStudyTime!,
                        ),
                      ),
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
                    'Next',
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
    );
  }
}