import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'frontpage.dart';
import 'package:http/http.dart' as http;
import 'view_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

void main() {
  
  runApp(MaterialApp(
    routes: {
      '/': (context) => FrontPage(),  // Define the frontPage route here
    },
    home: UserProfilePage(),
  ));
}

class _UserProfilePageState extends State<UserProfilePage> {
  String username = ""; // Store the user's name
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load username from SharedPreferences
  }

  // Function to retrieve the user's name from SharedPreferences
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Guest"; // Default to "Guest" if not found
    });
  }

  // Function to handle logout
  Future<void> _logout() async {
    setState(() {
      isLoading = true;  // Start loading indicator
    });
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      await prefs.remove('username');
      await prefs.remove('accessToken'); // Assuming you store the accessToken as well.
      setState(() {
          isLoading = false;  // Stop loading on error
        });
      Navigator.pushReplacementNamed(context, '/'); // Navigate back to the login page
    }
  }

  // Placeholder function for changing password
  void _changePassword() {
    // This can navigate to a password change screen or show an alert
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Password"),
        content: Text("This is a placeholder for the Change Password screen."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Placeholder function for viewing profile
  void _viewProfile() {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ViewProfilePage()),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'User Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:isLoading
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
              Text("Loading...", style: TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ),
      )
      : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Profile Avatar & Name Section
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade200,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Hello, $username', // Display the logged-in user's name
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),

            // "My Profile" Button
            GestureDetector(
              onTap: _viewProfile,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue, size: 40),
                    SizedBox(width: 10),
                    Text(
                      'My Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // "Change Password" Button
            GestureDetector(
              onTap: _changePassword,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 40),
                    SizedBox(width: 10),
                    Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // "Logout" Button
            GestureDetector(
              onTap: _logout,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 40),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
