import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ViewProfilePage extends StatefulWidget {
  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  String username = "";
  String email = ""; // You can add more fields as required
  String room="";

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user profile from SharedPreferences
  }

  // Load user profile from SharedPreferences
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try{
    final response = await http.get(
      Uri.parse('http://192.168.34.182:7000/api/v1/viewdetails'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Check if the response has the details
      if (data != null && data['data'] != null) {
        setState(() {
          username = data['data']['username'] ?? 'Guest'; // Update username
          email = data['data']['email'] ?? 'Not provided'; // You can add more fields as necessary
          room=data['data']['room'].toString();
        });
      } else {
        // Handle error if data is null
        _showErrorSnackBar('Failed to load profile data.');
      }
    } else {
      _showErrorSnackBar('Failed to fetch details: ${response.statusCode}');
    }
    }
    catch (error) {

    _showErrorSnackBar('Error: $error');
  }
  }
void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture (Placeholder)
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade200,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),

            // Display Username and Email
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Room No: $room',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // // Edit Profile Button (Optional)
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to edit profile page (you can implement it later)
            //     showDialog(
            //       context: context,
            //       builder: (context) => AlertDialog(
            //         title: Text("Edit Profile"),
            //         content: Text("This is a placeholder for the Edit Profile screen."),
            //         actions: [
            //           TextButton(
            //             onPressed: () {
            //               Navigator.of(context).pop(); // Close dialog
            //             },
            //             child: Text("OK"),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            //   child: Text('Edit Profile'),
            //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            // ),
          ],
        ),
      ),
    );
  }
}
