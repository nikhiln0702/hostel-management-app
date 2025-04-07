import 'dart:ui';
import 'package:flutter/material.dart';
import 'student_file_complaint.dart';
import 'student_view_complaint.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(ComplaintsApp());
}

class ComplaintsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ComplaintsPage(),
    );
  }
}

// Complaints Page
class ComplaintsPage extends StatefulWidget {
  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade300], // Set gradient to white and blue
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "File a Complaint" Box
              GestureDetector(
                onTap: () {
                  // Navigate to the "File a Complaint" form
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FileComplaintPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_copy,
                          color: Colors.blue.shade800,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "File a Complaint",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // "View Complaints" Box
              GestureDetector(
                onTap: () {
                  // Navigate to the "View Complaints" page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewComplaintsPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.view_list,
                          color: Colors.blue.shade800,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "View Complaints",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
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

