import 'package:flutter/material.dart';
import 'package:schedule_planner/screens/after_signup_page2.dart';

class QuestionnairePage extends StatefulWidget {
  final String jwtToken;
  const QuestionnairePage({super.key, required this.jwtToken});

  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  String? selectedGender;
  String? selectedMajor;
  String? age;

  final List<String> majors = ['Engineering', 'Medicine', 'Business', 'IT', 'Other'];

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
                  'Some questions to know more about you',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Text('Your age', style: TextStyle(fontSize: screenWidth * 0.04)),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => age = val,
                  decoration: InputDecoration(
                    hintText: 'Insert your age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text('Your gender', style: TextStyle(fontSize: screenWidth * 0.04)),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  children: [
                    Radio(
                      value: 'Male',
                      groupValue: selectedGender,
                      onChanged: (value) => setState(() => selectedGender = value as String),
                      activeColor: const Color(0xFF298267),
                    ),
                    const Text('Male'),
                    SizedBox(width: screenWidth * 0.1),
                    Radio(
                      value: 'Female',
                      groupValue: selectedGender,
                      onChanged: (value) => setState(() => selectedGender = value as String),
                      activeColor: const Color(0xFF298267),
                    ),
                    const Text('Female'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text('Your major', style: TextStyle(fontSize: screenWidth * 0.04)),
                SizedBox(height: screenHeight * 0.01),
                DropdownButtonFormField<String>(
                  value: selectedMajor,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: majors.map((String major) {
                    return DropdownMenuItem<String>(
                      value: major,
                      child: Text(major),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedMajor = value),
                  hint: const Text('Select your major'),
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (age == null || selectedGender == null || selectedMajor == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionnairePage2(
                            jwtToken: widget.jwtToken,
                            age: age!,
                            gender: selectedGender!,
                            major: selectedMajor!,
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
      ),
    );
  }
}