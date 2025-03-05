import 'package:flutter/material.dart';

class AddComplaintPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Complaint", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Hostel Name Input
            TextField(
              decoration: InputDecoration(
                labelText: "Hostel Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Complaint Input
            TextField(
              decoration: InputDecoration(
                labelText: "Complaint",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Room Number (Optional)
            TextField(
              decoration: InputDecoration(
                labelText: "Room No: (Optional)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
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
