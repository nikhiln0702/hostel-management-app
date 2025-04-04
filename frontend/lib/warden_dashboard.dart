import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'warden_mess_bill.dart';
import 'warden_attendance.dart';
import 'warden_complaint.dart';
import 'warden_notes.dart';
import 'user_profile.dart';
import 'warden_attendance_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = ""; // Variable to store the logged-in user's name

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load the username when the screen is loaded
  }

  // Function to retrieve the user's name from SharedPreferences
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Admin"; // Default to "Admin" if not found
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Warden Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 119, 84, 180),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
        automaticallyImplyLeading: false
      ),
      body: Container(
        // Gradient added here
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color.fromARGB(255, 187, 113, 233)],
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back,",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
                    'Hello,\n$username', // Display the username here
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 20),

            // The individual option containers (instead of GridView)
            _buildOptionCard(context, "Mess Bill Details", Icons.receipt, MessBillPage()),
            _buildOptionCard(context, "Attendance", Icons.check_circle, AttendanceScreen()),
            _buildOptionCard(context, "Attendance History", Icons.history, AttendanceHistoryScreen()), // New History Card
            _buildOptionCard(context, "Complaints", Icons.report_problem, ComplaintsScreen()),
            // _buildOptionCard(context, "Warden Notes", Icons.note, WardenNotesScreen()),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: 28),
              onPressed: () {},
            ),
            SizedBox(width: 40), // Space for Floating Action Button
            IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()), // Navigate to Fees Screen
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // A widget to build individual option cards
  Widget _buildOptionCard(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 40),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
