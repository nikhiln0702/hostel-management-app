import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue], // Background Gradient
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoginButton(text: "Warden Login", onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                );
              }),
              SizedBox(height: 20),
              LoginButton(text: "Student Login", onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  LoginButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 20, color: Colors.black),
              children: [
                TextSpan(
                  text: text.split(" ")[0], // First word bold
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: " " + text.split(" ")[1]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
