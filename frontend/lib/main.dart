import 'package:flutter/material.dart';
import 'package:hostel_management_system/frontpage.dart';
import 'warden_dashboard.dart';
import 'login_screen.dart';
import 'student_dashboard.dart';
import 'warden_login.dart';
import 'admin_login.dart';
import 'admin_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FrontPage(),
        '/login_screen': (context) => LoginScreen(),
        '/student_dashboard': (context) => StudentDashboard(),
        '/wardenLogin': (context) => WardenLogin(),
        '/wardendashboard':(context)=> HomeScreen(),
        '/adminlogin':(context)=> AdminLogin(),
        '/admindashboard':(context)=>AdminDashboard()
      },
    );
  }
}
