import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // Country Code List
  String selectedCountryCode = '+66'; // Default to Thailand
  String selectedCountry = 'Thailand';

  final List<Map<String, String>> countryCodes = [
    {"name": "Thailand", "code": "+66"},
    {"name": "United States", "code": "+1"},
    {"name": "United Kingdom", "code": "+44"},
    {"name": "China", "code": "+86"},
    {"name": "India", "code": "+91"},
    {"name": "Japan", "code": "+81"},
    {"name": "South Korea", "code": "+82"},
    {"name": "France", "code": "+33"},
    {"name": "Germany", "code": "+49"},
    {"name": "Canada", "code": "+1"},
    {"name": "Australia", "code": "+61"},
    {"name": "Italy", "code": "+39"},
    {"name": "Brazil", "code": "+55"},
    {"name": "Mexico", "code": "+52"},
    {"name": "Russia", "code": "+7"},
    {"name": "South Africa", "code": "+27"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Makes the whole screen scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80), // Adjust top padding

              // Forgot Password Title
              Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 32),

              // Country Selector & Phone Input
              Row(
                children: [
                  // Country Code Dropdown
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFD4E157),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true, // Makes it stretch full width
                          value: selectedCountryCode,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCountryCode = newValue!;
                              selectedCountry = countryCodes.firstWhere(
                                    (element) => element["code"] == newValue,
                              )["name"]!;
                            });
                          },
                          items: countryCodes.map((Map<String, String> country) {
                            return DropdownMenuItem<String>(
                              value: country["code"],
                              child: Text('${country["name"]} (${country["code"]})'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // Phone Number Input
                  Expanded(
                    flex: 5,
                    child: _buildTextField(phoneController, 'Phone'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Get Code Button
              _buildButton('Get Code', () {
                // TODO: Implement logic to send verification code
              }),
              SizedBox(height: 16),

              // Enter Code Field
              _buildTextField(codeController, 'Enter Code'),
              SizedBox(height: 16),

              // Resend Code Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement Resend Code logic
                  },
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Continue Button
              _buildButton('Continue', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                );
              }),
              SizedBox(height: 50), // Adds space at the bottom for scrolling
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField with Rounded Design
  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFFD4E157), // Light Green Background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Custom Button
  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD4E157), // Light Green
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}
