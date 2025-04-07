import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui'; // Add this line for ImageFilter
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FileComplaintPage extends StatefulWidget {
  @override
  _FileComplaintPageState createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  String selectedCategory = 'Maintenance'; // Default category
  TextEditingController complaintController = TextEditingController();

  // Handle back button press
  Future<bool> _onWillPop() async {
    Navigator.pop(context); // Simply pop to go back
    return Future.value(false);
  }

  // Function to submit the complaint to the backend
  Future<void> _submitComplaint() async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    String complaintText = complaintController.text;

    if (complaintText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your complaint!")),
      );
      return;
    }

    try {
      // API request to file complaint
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      final response = await http.post(
        Uri.parse('$baseUrl/addcomplaint'), // Adjust the API URL as per your backend
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'category': selectedCategory,
          'description': complaintText,
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
          return await _submitComplaint(); // Retry the same complaint submission with new access token
        }
      } else if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Complaint submitted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit complaint!")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred! Please try again.")),
      );
    }

    // Clear the fields after submission
    complaintController.clear();
    setState(() {
      selectedCategory = 'Maintenance';
    });
  }

  // Function to refresh the access token
  Future<bool> refreshAccessToken() async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    final response = await http.post(
      Uri.parse('$baseUrl/refreshtoken'),
      headers: {
        'Authorization': 'Bearer $refreshToken',
      },
    );

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

  // Logout function to clear user session data
  Future<void> logout() async {
    // Here, you should clear stored tokens and navigate to login screen.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    // After clearing, navigate to the login screen
    Navigator.pushReplacementNamed(context, '/'); // Replace with your login route
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text("File a Complaint"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade300],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Glassmorphic Complaint Form
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: 340,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dropdown for Category
                          Text(
                            "Complaint Category",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            dropdownColor: Colors.blue.shade700,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                              });
                            },
                            items: [
                              'Maintenance',
                              'Electricity',
                              'Water Supply',
                              'Food & Mess',
                            ].map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),

                          // Complaint Text Field
                          TextField(
                            controller: complaintController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Enter your complaint...",
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 16),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Submit Complaint",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
