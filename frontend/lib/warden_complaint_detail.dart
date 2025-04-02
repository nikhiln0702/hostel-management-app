import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintText;
  final String initialStatus;
  final String complaintId;

  ComplaintDetailScreen({
    required this.complaintText,
    required this.initialStatus,
    required this.complaintId,
  });

  @override
  _ComplaintDetailScreenState createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  String status = "";

  @override
  void initState() {
    super.initState();
    status = widget.initialStatus;
  }

  // Function to send the updated status to the backend
  Future<void> updateComplaintStatus(String status) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
    
      // Check if the accessToken is null
      if (accessToken == null) {
        print('No access token available');
        return;
      }
    
      // Debugging: Print the access token
      print('Access token: $accessToken');

      final response = await http.post(
        Uri.parse('http://192.168.34.182:7000/api/v1/updatecomplaintstatus'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'id': widget.complaintId, // Send the complaint ID
          'status': status, // Send the updated status
        }),
      );
      print('Complaint ID: ${widget.complaintId}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody.containsKey('message')) {
          print('Complaint status updated: ${responseBody['message']}');
        } else {
          print('Unexpected response format: $responseBody');
        }
      } else {
        print('Failed to update complaint status');
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error occurred while updating complaint status: $error');
    }
  }

  void markInProgress() {
    setState(() {
      status = "In Progress";
    });
    updateComplaintStatus("In Progress"); // Call the backend to update the status
  }

  void markResolved() {
    setState(() {
      status = "Resolved";
    });
    updateComplaintStatus("Resolved"); // Call the backend to update the status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, status), // Return status
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.purple.shade100],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Complaint: ${widget.complaintText}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              "Status: $status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: status == "Resolved"
                    ? Colors.green
                    : status == "In Progress"
                        ? Colors.orange
                        : Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: markInProgress,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text("In Progress", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: markResolved,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Resolve", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
