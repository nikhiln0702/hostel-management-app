import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'warden_complaint_detail.dart';

class ComplaintsScreen extends StatefulWidget {
  @override
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true; // To handle loading state

  // Function to fetch complaints from the backend
  Future<void> fetchComplaints() async {
    try {
      // Get the stored access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }

      // Make the API request with the Bearer token in the header
      final response = await http.get(
        Uri.parse('http://localhost:7000/api/v1/viewcomplaints'),
        headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> complaintsData = responseBody['data'];

        setState(() {
          complaints = complaintsData.map((complaint) {
            return {
              'student_id': complaint['student_id'] ?? 'Unknown', // Student ID
              'category': complaint['category'] ?? 'Unknown', // Category (Maintenance, Mess, Others)
              'description': complaint['description'] ?? 'No details available', // Description
              'status': complaint['status'] ?? 'Pending', // Status (Pending, In Progress, Resolved)
              'id': complaint['id'] ?? 'Unknown', // Complaint ID
            };
          }).toList();
        });
      } else {
        showErrorDialog(context, "Failed to fetch complaints. Please try again.");
      }
    } catch (error) {
      showErrorDialog(context, "An error occurred. Please check your internet connection and try again.");
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator once data is fetched
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints(); // Fetch complaints when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications, color: Colors.white), onPressed: () {}),
        ],
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
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
            : _buildTable(),
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
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(icon: Icon(Icons.person, color: Colors.white, size: 28), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 1),
      columnWidths: {
        0: FractionColumnWidth(0.2),
        1: FractionColumnWidth(0.3),
        2: FractionColumnWidth(0.3),
        3: FractionColumnWidth(0.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.deepPurple),
          children: [
            _tableHeader("Student ID"),
            _tableHeader("Category"),
            _tableHeader("Description"),
            _tableHeader("Status"),
          ],
        ),
        for (var complaint in complaints) _buildComplaintRow(complaint),
      ],
    );
  }

  TableRow _buildComplaintRow(Map<String, dynamic> complaint) {
    return TableRow(
      children: [
        _tableCell(complaint['student_id'].toString()),
        _tableCell(complaint['category'].toString()),
        GestureDetector(
          onTap: () async {
            final updatedStatus = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComplaintDetailScreen(
                  complaintText: complaint['description']?.toString() ?? 'No details available',
                  initialStatus: complaint['status']?.toString() ?? 'Pending',
                  complaintId: complaint['id'].toString(),
                ),
              ),
            );

            if (updatedStatus != null) {
              setState(() {
                complaint['status'] = updatedStatus; // Update table instantly
              });
            }
          },
          child: _tableCell(complaint['description']?.toString() ?? 'No complaint details', isClickable: true),
        ),
        _tableCell(complaint['status']?.toString() ?? "Pending"),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, {bool isClickable = false}) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: isClickable ? Colors.blue : Colors.black),
      ),
    );
  }

  // Show Error Dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
