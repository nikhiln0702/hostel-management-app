import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudentDashboard(),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE, MMM d, y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // 🔹 Set to match bottom AppBar
        elevation: 0,
        title: Text(
          'Student Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // 🔹 Ensures it's centered
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ), // 🔹 Moved to top-right
            onPressed: () {},
          ),
        ],
        automaticallyImplyLeading: false, // 🔹 Removes the back button
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.white,
                size: 32,
              ), // 🔹 Increased size
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ), // 🔹 Increased size
              onPressed: () {},
            ),
          ],
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello,\nStudent_Name',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      todayDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // 🔹 Adds spacing before the containers
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1, // 🔹 Makes the containers bigger
                children: [
                  DashboardTile(icon: Icons.restaurant, label: "Mess Bill"),
                  DashboardTile(icon: Icons.check_circle, label: "Attendance"),
                  DashboardTile(icon: Icons.warning, label: "Complaints"),
                  DashboardTile(
                    icon: Icons.account_balance_wallet,
                    label: "Transactions",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const DashboardTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
