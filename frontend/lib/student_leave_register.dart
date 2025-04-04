import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For encoding the data
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaveRegister(),
    );
  }
}

class LeaveRegister extends StatefulWidget {
  const LeaveRegister({super.key});

  @override
  State<LeaveRegister> createState() => _LeaveRegisterState();
}

class _LeaveRegisterState extends State<LeaveRegister> {
  bool isApplied = false; // ✅ Tracks if "Apply" was clicked
  TextEditingController dateController = TextEditingController(); // Controller for the Date field
  String? selectedRemark = 'Entry'; // Default selected remark
  List<String> remarksOptions = ['Entry', 'Exit']; // Options for remarks

  Future<void> submitLeaveRequest(String date, String remarks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      showErrorDialog(context, "Access token is missing. Please log in again.");
      return;
    }
    // Replace with your backend URL
    try {
      final response = await http.post(
        Uri.parse('http://192.168.34.182:7000/api/v1/leaveregister'),
        headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': date,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 401) {
        // Token expired, attempt to refresh
        bool tokenRefreshed = await refreshAccessToken();

        if (!tokenRefreshed) {
          // If refresh fails, logout the user
          await logout();
        } else {
          // Retry the request with the new token
          return await submitLeaveRequest(date, remarks); // Retry the same complaint submission with new access token
        }
      }

      else if (response.statusCode == 200) {
        // Handle the success response
        setState(() {
          isApplied = true; // Show the "Applied" banner
        });

        // Hide the "Applied" banner after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            isApplied = false; // Hide the "Applied" banner
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Leave application successful!")));
      } 
      else if(response.statusCode==404){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error : No Exit Record Found")));
      }
      else {
        // Handle the error response
        print('response :${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (error) {
      print('error :${error}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit request: $error")));
    }
  }
  Future<bool> refreshAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    final response = await http.post(
      Uri.parse('http://192.168.34.182:7000/api/v1/refreshtoken'),
      headers: {
        'Authorization': 'Bearer $refreshToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      // Parse the new access token
      final data = json.decode(response.body);
      String accessToken = data['data']['accessToken']; // Assuming the response has a new accessToken
      await prefs.setString('accessToken', accessToken);
      return true;
    } else {
      // If refresh fails, return false
      return false;
    }
  }
  Future<void> logout() async {
    // Here, you should clear stored tokens and navigate to the login screen.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    // After clearing, navigate to the login screen
    Navigator.pushReplacementNamed(context, '/');
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Leave Register',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: 32),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: 32),
              onPressed: () {},
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ "Applied" banner appears when Apply button is clicked
              if (isApplied)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.green,
                  child: Text(
                    'Applied',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              SizedBox(height: 30),

              // Leave Application Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDateField(),
                      SizedBox(height: 12),
                      buildRemarksDropdown(),
                      SizedBox(height: 20),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            if (dateController.text.isNotEmpty && selectedRemark != null) {
                              submitLeaveRequest(dateController.text, selectedRemark!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
                            }
                          },
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Date Input Field with Date Picker
  Widget buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        TextField(
          controller: dateController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: 'Select a date',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true, // To make it read-only
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(), // Restrict to today and future dates
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              // Format the selected date in yyyy-MM-dd format
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              setState(() {
                dateController.text = formattedDate; // Set the formatted date in the controller
              });
            }
          },
        ),
      ],
    );
  }

  // Custom Remarks Dropdown for Entry and Exit
  Widget buildRemarksDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedRemark,
          onChanged: (String? newValue) {
            setState(() {
              selectedRemark = newValue;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          items: remarksOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
