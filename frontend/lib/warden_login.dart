import 'package:flutter/material.dart';

class WardenLogin extends StatelessWidget {
  const WardenLogin({super.key});

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
                    "Get Started with AMS",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Login ID Input
                  _buildTextField("Login ID"),
                  SizedBox(height: 10),

                  // Password Input
                  _buildTextField("Password", isPassword: true),
                  SizedBox(height: 20),

                  // Sign In Button (Blue)
                  _buildButton(
                    "Sign In",
                    () => Navigator.pushReplacementNamed(context, '/dashboard'),
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

                  SizedBox(height: 10),

                  // Google Sign-In Button (Red)
                  _buildButton(
                    "Sign in with Google",
                    () {},
                    color: Colors.red,
                    icon: Icons.g_mobiledata,
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
  Widget _buildTextField(String label, {bool isPassword = false}) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
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
          backgroundColor: color, // Button color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
