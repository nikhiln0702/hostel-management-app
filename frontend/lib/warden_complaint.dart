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
  List<Map<String, dynamic>> allComplaints = []; // Store all complaints
  List<Map<String, dynamic>> filteredComplaints = []; // Store filtered complaints
  bool isLoading = true; // To handle loading state
  String filter = 'All'; // Default filter is 'All'

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
        Uri.parse('http://192.168.34.182:7000/api/v1/viewcomplaints'),
        headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> complaintsData = responseBody['data'];

        setState(() {
          allComplaints = complaintsData.map((complaint) {
            return {
              'student_name': complaint['studentName'] ?? 'Unknown', // Student Name
              'category': complaint['category'] ?? 'Unknown', // Category (Maintenance, Mess, Others)
              'description': complaint['description'] ?? 'No details available', // Description
              'status': complaint['status'] ?? 'Pending', // Status (Pending, In Progress, Resolved)
              'id': complaint['id'] ?? 'Unknown', // Complaint ID
            };
          }).toList();
          // Set the filtered complaints based on the default filter
          filteredComplaints = _filterComplaints(filter);
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

  // Method to filter complaints based on the selected status
  List<Map<String, dynamic>> _filterComplaints(String filter) {
    if (filter == 'All') {
      return allComplaints;
    }
    return allComplaints.where((complaint) {
      return complaint['status'] == filter;
    }).toList();
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
            : Column(
                children: [
                  // Filter buttons at the top
                  _buildFilterButtons(),
                  Expanded(
                    child: _buildComplaintCards(),
                  ),
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
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(icon: Icon(Icons.person, color: Colors.white, size: 28), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  // Method to build filter buttons
  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFilterButton("All"),
        _buildFilterButton("Resolved"),
        _buildFilterButton("Pending"),
      ],
    );
  }

  // Method to build individual filter buttons
  Widget _buildFilterButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filter = label;
          filteredComplaints = _filterComplaints(filter); // Apply the filter
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: filter == label ? Colors.deepPurple : Colors.grey, // Change color when selected
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  // Method to build complaint cards
  Widget _buildComplaintCards() {
    return ListView.builder(
      itemCount: filteredComplaints.length,
      itemBuilder: (context, index) {
        final complaint = filteredComplaints[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student: ${complaint['student_name']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Category: ${complaint['category']}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Description: ${complaint['description']}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  "Status: ${complaint['status']}",
                  style: TextStyle(fontSize: 16, color: complaint['status'] == 'Pending' ? Colors.red : Colors.green),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
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
                  child: Text("Update Status"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
              ],
            ),
          ),
        );
      },
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
