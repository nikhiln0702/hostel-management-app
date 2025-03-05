import 'package:flutter/material.dart';
import 'add_complaint_page.dart'; // Import the complaint page

class StudentDashboard extends StatelessWidget {
  final String studentName;

  // Constructor to accept student name
  StudentDashboard({required this.studentName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, ", style: TextStyle(fontSize: 18)),
            Text("Student_Name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),

            SizedBox(height: 20),

            // Dashboard Cards
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                DashboardCard(title: "Mess Bill"),
                DashboardCard(title: "Attendance"),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddComplaintPage()),
                    );
                  },
                  child: DashboardCard(title: "Complaints"),
                ),
                DashboardCard(title: "Transactions"),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  DashboardCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(child: Text(title, style: TextStyle(fontSize: 16))),
    );
  }
}
