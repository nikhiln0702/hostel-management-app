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
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  List<Map<String, dynamic>> appliedstudents = [];

  String currentDate = '';
  String filter = 'All';
  int presentCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _setCurrentDate();
    _fetchPresentCount();
    _fetchAppliedStudents();
  }

  void _setCurrentDate() {
    final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
    setState(() {
      currentDate = dateFormatter.format(DateTime.now());
    });
    print("Current Date: $currentDate");
  }

  Future<void> _fetchStudents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.34.182:7000/api/v1/viewstudents'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
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
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  Future<void> _fetchPresentCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.34.182:7000/api/v1/getpresentcount'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          presentCount = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAttendance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.34.182:7000/api/v1/attendancefetch'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'date': currentDate}),
      );
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
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  Future<void> _saveAttendance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.34.182:7000/api/v1/attendancesave'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': currentDate,
        }),
      );
      if (response.statusCode == 200) {
        // Show success green bar (SnackBar) here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance saved successfully!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        showErrorDialog(context, "Save failed");
      }
    } catch (e) {
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  Future<void> _fetchAppliedStudents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.34.182:7000/api/v1/gettodaysapplied'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> studentsData = responseBody['data'];

        setState(() {
          appliedstudents = studentsData.map((student) {
            var user = student['User'];
            return {
              'name': user['username'] ?? 'Unknown',
              'roomNo': user['room'] ?? 'Unknown',
              'status': user['status'],
            };
          }).toList();
          _filterStudents();
        });
      } else {
        showErrorDialog(context, "Failed to fetch students. Please try again.");
      }
    } catch (e) {
      showErrorDialog(context, "An error occurred: $e");
    }
  }

  void _filterStudents() {
    if (filter == 'All') {
      filteredStudents = students;
    } else if (filter == 'Applied') {
      filteredStudents = appliedstudents;
    } else {
      filteredStudents = students.where((student) {
        return student['status'] == filter;
      }).toList();
    }
  }

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
            Text(
              'Date: $currentDate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 10),
            Text(
              _isLoading ? "Total Present: Loading..." : "Total Present: $presentCount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterButton("All"),
                  _filterButton("Present"),
                  _filterButton("Absent"),
                  _filterButton("Applied"),
                ],
              ),
            ),
            SizedBox(height: 10),
            _buildCards(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _saveAttendance,
          child: Text("Save Attendance"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

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
            _dropdownCell(student),
            SizedBox(height: 10),
            _statusCell(student['status']),
          ],
        ),
      ),
    );
  }

  Widget _dropdownCell(Map<String, dynamic> student) {
    String currentStatus = student["status"] ?? 'Absent';
    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (newValue) {
        setState(() {
          student["status"] = newValue!;
        });
      },
      items: <String>['Present', 'Absent', 'Leave'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _statusCell(String status) {
    return Text(
      'Status: $status',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: status == 'Present' ? Colors.green : Colors.red),
    );
  }
}
