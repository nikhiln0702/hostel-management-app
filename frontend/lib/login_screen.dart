import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  // Function to send login request to Node.js backend
  Future<void> login(String email, String password) async {
    final url = Uri.parse(
      'http://10.0.2.2:3000/login',
    ); // Use for Android Emulator

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'rememberMe': false,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        String accessToken = responseBody['data']['accessToken'];

        // Navigate to student dashboard if login is successful
        Navigator.pushReplacementNamed(context, '/student_dashboard');
      } else {
        final errorMessage = json.decode(response.body)['message'];
        showErrorDialog(context, errorMessage);
      }
    } catch (error) {
      showErrorDialog(context, "An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/hostel.jpg.webp", fit: BoxFit.cover),
          ),

          // Centered Login Form
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Get Started with Hostel Management",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Login ID Input
                  _buildTextField("Email ID", controller: emailController),
                  SizedBox(height: 10),

                  // Password Input
                  _buildTextField(
                    "Password",
                    isPassword: true,
                    controller: passwordController,
                  ),
                  SizedBox(height: 20),

                  // Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text("Remember Me"),
                    ],
                  ),

                  // Sign In Button (Blue)
                  _buildButton(
                    "Sign In",
                    () => login(emailController.text, passwordController.text),
                    color: Colors.blue,
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Text Field
  Widget _buildTextField(
    String label, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Reusable Button with Custom Colors
  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    Color color = Colors.blue,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50, // Same height for all buttons
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon:
            icon != null ? Icon(icon, color: Colors.white) : SizedBox.shrink(),
        label: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Show Error Dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Login Failed"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }
}
