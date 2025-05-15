import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  // Variables for storing selected date, month, and year
  String selectedDate = "";
  String selectedMonth = "";
  String selectedYear = "";
  bool isLoading = false;


  // List of months and years
  List<String> months = List.generate(12, (index) => DateFormat.MMMM().format(DateTime(0, index + 1)));
  List<String> years = List.generate(50, (index) => (2020 + index).toString());

  // List to store the fetched attendance data
  List<Map<String, String>> attendanceData = [];

  // Function to fetch attendance history
  Future<void> fetchAttendanceHistory() async {
    setState(() {
      isLoading = true;  // Start loading indicator
    });

    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
  // Get the stored access token from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  // Validate if all fields are selected
  if (selectedDate.isEmpty || selectedMonth.isEmpty || selectedYear.isEmpty) {
    setState(() {
          isLoading = false;  // Stop loading on error
        });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text("Please select a valid date, month, and year."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
    return;
  }

  // Create the date string in yyyy-mm-dd format
  String dateString =
      "$selectedYear-${months.indexOf(selectedMonth) + 1 < 10 ? "0${months.indexOf(selectedMonth) + 1}" : months.indexOf(selectedMonth) + 1}-$selectedDate";

  // Send the request to the backend
  final response = await http.post(
    Uri.parse('$baseUrl/attendancefetch'), // Replace with your backend URL
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
    body: jsonEncode({'date': dateString}),
  );

  print(response.body);

  if (response.statusCode == 200) {
    setState(() {
          isLoading = false;  // Stop loading on error
        });
    var responseData = jsonDecode(response.body);

    // Assuming the attendance records are in responseData['data'] or the direct response body
    var records = responseData['data'] ?? [];

    // If no records are returned, show a message
    if (records.isEmpty) {
      setState(() {
        attendanceData.clear(); // Clear previous data if no records found
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("No Records Found"),
          content: Text("No attendance records found for the selected date."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        attendanceData = records.map<Map<String, String>>((record) {
          var user = record['User'] ?? {};  // Ensure 'User' is not null
          return {
            'username': user['username']?.toString() ?? 'Unknown',  // Ensure it's a string
            'room': user['room']?.toString() ?? 'Unknown',  // Convert to string explicitly
            'status': record['status']?.toString() ?? 'Unknown',  // Convert to string explicitly
          };
        }).toList();
      });
    }
  } else {
    setState(() {
          isLoading = false;  // Stop loading on error
        });
    // Handle error
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text("Failed to fetch attendance history."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Attendance History"),
      backgroundColor: Colors.deepPurple,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Date, Month, and Year Dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Controls spacing between the dropdowns
            children: [
              // Date Dropdown
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Date"),
                  value: selectedDate.isEmpty ? null : selectedDate,
                  items: List.generate(31, (index) => (index + 1).toString())
                      .map((day) => DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDate = value ?? "";
                    });
                  },
                ),
              ),
              SizedBox(width: 8), // Add space between dropdowns
              // Month Dropdown
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Month"),
                  value: selectedMonth.isEmpty ? null : selectedMonth,
                  items: months
                      .map((month) => DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value ?? "";
                    });
                  },
                ),
              ),
              SizedBox(width: 8), // Add space between dropdowns
              // Year Dropdown
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select Year"),
                  value: selectedYear.isEmpty ? null : selectedYear,
                  items: years
                      .map((year) => DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value ?? "";
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20), // Add space between the dropdowns and the button

          // Fetch Button
          ElevatedButton(
            onPressed: fetchAttendanceHistory,
            child: Text("Fetch Attendance History",style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
          ),

          SizedBox(height: 20),

          // Display fetched data in a ListView of Cards
          Expanded(
  child: isLoading
      ? Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black26,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text(
                  "Loading...",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        )
      : ListView.builder(
          itemCount: attendanceData.length,
          itemBuilder: (context, index) {
            var record = attendanceData[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 5,
              child: ListTile(
                title: Text(record['username'] ?? 'Unknown'),
                subtitle: Text(
                    "Room: ${record['room']}\nStatus: ${record['status']}"),
                isThreeLine: true,
                tileColor: Colors.deepPurple[50],
              ),
            );
          },
        ),
),

        ],
      ),
    ),
  );
}
}