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
  String currentDate = ''; // Variable to hold the formatted current date

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
        Uri.parse('http://localhost:7000/api/v1/viewstudents'),  // Replace with actual endpoint
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
        });
      } else {
        showErrorDialog(context, "Failed to fetch students. Please try again.");
      }
    } catch (e) {
      showErrorDialog(context, "An error occurred: $e");
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
            // Display the current date above the table
            Text(
              'Date: $currentDate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 10), // Space between date and table
            _buildTable(), // Display the students table
          ],
        ),
      ),
    );
  }

  // ✅ Build Table
  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 1),
      columnWidths: {
        0: FractionColumnWidth(0.3),
        1: FractionColumnWidth(0.2),
        2: FractionColumnWidth(0.2),
        3: FractionColumnWidth(0.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.deepPurple),
          children: [
            _tableHeader("Name"),
            _tableHeader("Room No"),
            _tableHeader("P/A"),
            _tableHeader("Status"),
          ],
        ),
        ...students.map((student) => _buildAttendanceRow(student)).toList(),
      ],
    );
  }

  TableRow _buildAttendanceRow(Map<String, dynamic> student) {
    return TableRow(
      children: [
        _tableCell(student["name"] ?? "Unknown"),
        _tableCell(student["roomNo"] ?? "Unknown"),
        _dropdownCell(student),
        _statusCell(student["status"]),
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

  Widget _tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  // ✅ Dropdown for Present/Absent
  Widget _dropdownCell(Map<String, dynamic> student) {
    // Ensure that status is either 'Present' or 'Absent' before assigning to the dropdown value
    String currentStatus = student["status"] ?? '';  // Default to an empty string if null

    // Ensure we only assign 'Present' or 'Absent' as a valid status value
    if (currentStatus.isEmpty || (currentStatus != 'Present' && currentStatus != 'Absent')) {
      currentStatus = 'Absent';  // Default to 'Absent' if it's invalid or empty
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: DropdownButton<String>(
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
          });
        },
      ),
    );
  }

  // ✅ Status Cell (Green for Present, Red for Absent)
  Widget _statusCell(String? status) {
    bool isPresent = status == "Present";

    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        status?.isEmpty ?? true ? "" : (isPresent ? "Present" : "Absent"),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: status?.isEmpty ?? true ? Colors.black : (isPresent ? Colors.green : Colors.red),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
