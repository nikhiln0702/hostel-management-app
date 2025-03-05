import 'package:flutter/material.dart';

class LeaveRegisterScreen extends StatefulWidget {
  @override
  _LeaveRegisterScreenState createState() => _LeaveRegisterScreenState();
}

class _LeaveRegisterScreenState extends State<LeaveRegisterScreen> {
  TextEditingController dateFromController = TextEditingController();
  TextEditingController dateToController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Register"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date From:"),
            TextField(
              controller: dateFromController,
              decoration: InputDecoration(
                hintText: "Select start date",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text("To Date:"),
            TextField(
              controller: dateToController,
              decoration: InputDecoration(
                hintText: "Select end date",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text("Remarks:"),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter remarks",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  String dateFrom = dateFromController.text;
                  String dateTo = dateToController.text;
                  String remarks = remarksController.text;

                  print("Leave Request: From $dateFrom to $dateTo, Remarks: $remarks");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Leave request submitted successfully!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text("Apply", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Navigate to home
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                // Navigate to profile or other page
              },
            ),
          ],
        ),
      ),
    );
  }
}
