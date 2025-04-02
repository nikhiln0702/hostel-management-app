import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Use dynamic type for students
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  String currentDate = ''; // Variable to hold the formatted current date
  String filter = 'All'; // Default filter is 'All'

  @override
  void initState() {
    super.initState();
    _fetchStudents(); // Fetch students when screen is loaded
    _setCurrentDate(); // Set current date when screen is loaded
  }

  // ✅ Set current date
  void _setCurrentDate() {
    final DateFormat dateFormatter = DateFormat('dd-MM-yyyy'); // Set the format you want
    setState(() {
      currentDate = dateFormatter.format(DateTime.now()); // Get and format the current date
    });
    print("Current Date: $currentDate"); // Debug: Print current date to ensure it's set
  }

  // ✅ Fetch students data from the backend
  Future<void> _fetchStudents() async {
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
        Uri.parse('http://192.168.34.182:7000/api/v1/viewstudents'),  // Replace with actual endpoint
        headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> studentsData = responseBody;

        setState(() {
          students = studentsData.map((student) {
            return {
              'name': student['username'] ?? 'Unknown',
              'roomNo': student['email'] ?? 'Unknown',
              'status': student['status'], // Initialize status field
            };
          }).toList();
          _filterStudents(); // Filter students based on current filter
        });
      } else {
        showErrorDialog(context, "Failed to fetch students. Please try again.");
      }
    } catch (e) {
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  // ✅ Filter students based on the selected filter
  void _filterStudents() {
    if (filter == 'All') {
      filteredStudents = students;
    } else {
      filteredStudents = students.where((student) {
        return student['status'] == filter;
      }).toList();
    }
  }

  // Error dialog helper method
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
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
          children: [
            // Display the current date above the filter buttons
            Text(
              'Date: $currentDate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 10), // Space between date and filter buttons

            // Filter buttons for All, Present, Absent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("All"),
                _filterButton("Present"),
                _filterButton("Absent"),
              ],
            ),
            SizedBox(height: 10), // Space between filter buttons and cards

            _buildCards(), // Display the student cards based on filtered list
          ],
        ),
      ),
    );
  }

  // ✅ Filter button widget
  Widget _filterButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filter = label;
          _filterStudents(); // Filter the students when a button is pressed
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: filter == label ? Colors.deepPurple : Colors.grey.shade300,
      ),
      child: Text(label, style: TextStyle(color: filter == label ? Colors.white : Colors.black)),
    );
  }

  // ✅ Build Cards for each student
  Widget _buildCards() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          var student = filteredStudents[index];
          return _buildStudentCard(student);
        },
      ),
    );
  }

  // ✅ Build individual student card
  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name
            Text(
              'Name: ${student['name']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            // Room No
            Text(
              'Room No: ${student['roomNo']}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            // Present/Absent Dropdown
            _dropdownCell(student),
            SizedBox(height: 10),
            // Status (Green for Present, Red for Absent)
            _statusCell(student['status']),
          ],
        ),
      ),
    );
  }

  // ✅ Dropdown for Present/Absent
  Widget _dropdownCell(Map<String, dynamic> student) {
    String currentStatus = student["status"] ?? 'Absent';  // Default to 'Absent' if null

    return DropdownButton<String>(
      value: currentStatus,  // Set the value from the student['status']
      hint: Text("Present/Absent"),  // Placeholder text
      isExpanded: true,
      items: ["Present", "Absent"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          student["status"] = newValue!;  // Update the student's status on change
          _filterStudents(); // Re-filter the list to update based on the selected status
        });
      },
    );
  }

  // ✅ Status Cell (Green for Present, Red for Absent)
  Widget _statusCell(String? status) {
    bool isPresent = status == "Present";

    return Text(
      status?.isEmpty ?? true ? "" : (isPresent ? "Present" : "Absent"),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: status?.isEmpty ?? true ? Colors.black : (isPresent ? Colors.green : Colors.red),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
