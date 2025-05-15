import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  String currentDate = ''; 
  String filter = 'All'; 

  int presentCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents(); // Fetch students when screen is loaded
    _setCurrentDate(); // Set current date when screen is loaded
    _fetchPresentCount(); // Fetch present count at the start
  }

  // ✅ Set current date
  void _setCurrentDate() {
    final DateFormat dateFormatter = DateFormat('dd-MM-yyyy'); 
    setState(() {
      currentDate = dateFormatter.format(DateTime.now()); 
    });
  }

  // ✅ Fetch students data from the backend
  Future<void> _fetchStudents() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      final baseUrl = dotenv.env['API_BASE_URL'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/viewstudents'),  
        headers: {
          'Authorization': 'Bearer $accessToken', 
          'Content-Type': 'application/json',
        },
      );
            print(response.statusCode);

      print(response.body);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> studentsData = responseBody['data'];

        setState(() {
          students = studentsData.map((student) {
            return {
              'name': student['username'] ?? 'Unknown',
              'roomNo': student['room'] ?? 'Unknown',
              'status': student['status'],
            };
          }).toList();
          _filterStudents(); 
        });
      } else {
        showErrorDialog(context, "Failed to fetch students. Please try again.");
      }
    } catch (e) {
      print(e);
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  // ✅ Fetch Present Count from the backend
  Future<void> _fetchPresentCount() async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getpresentcount'), 
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          presentCount = data['data']; // Extract count from response
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $error");
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

  // ✅ Filter button widget
  Widget _filterButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          filter = label;
          _filterStudents(); 
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: filter == label ? Colors.deepPurple : Colors.grey.shade300,
      ),
      child: Text(label, style: TextStyle(color: filter == label ? Colors.white : Colors.black)),
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
            Text('Name: ${student['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Room No: ${student['roomNo']}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            _statusCell(student['status']),
          ],
        ),
      ),
    );
  }

  // ✅ Dropdown for Present/Absent
  Widget _dropdownCell(Map<String, dynamic> student) {
    String currentStatus = student["status"] ?? 'Absent'; 

    return DropdownButton<String>(
      value: currentStatus,
      hint: Text("Present/Absent"),
      isExpanded: true,
      items: ["Present", "Absent"].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          student["status"] = newValue!; 
          _filterStudents(); 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Present Count as Text (Not Card)
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Text(
                    'Present Count: $presentCount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
            SizedBox(height: 20),

            // Display the current date above the filter buttons
            Text(
              'Date: $currentDate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 10),

            // Filter buttons for All, Present, Absent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("All"),
                _filterButton("Present"),
                _filterButton("Absent"),
              ],
            ),
            SizedBox(height: 10),

            // Use ListView.builder to display the filtered student cards
            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  var student = filteredStudents[index];
                  return _buildStudentCard(student);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AttendanceScreen(),
  ));
}
