import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminOverviewPage extends StatefulWidget {
  @override
  _AdminOverviewPageState createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  bool _isLoading = true;
  Map<String, dynamic> adminOverviewData = {};

  final String apiUrl = 'http://<YOUR_BACKEND_API_URL>/admin-overview';  // Replace with your actual API URL

  // Fetch admin overview data from the backend
  Future<void> _fetchAdminOverview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      final response = await http.get(Uri.parse('http://192.168.34.182:7000/api/v1/getadminoverviewusers'),headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        },);
        print(response.body);
      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          adminOverviewData = data['data'];  // Adjust based on your backend response
          _isLoading = false;  // Set loading to false once data is fetched
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;  // Set loading to false even if there's an error
      });
      _showErrorSnackBar(error.toString());
    }
  }

  // Show an error message in a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _fetchAdminOverview();  // Fetch data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Overview'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // Show loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCard(
                    'Total Users',
                    adminOverviewData['totalUsers'],
                    Icons.group,
                    'totalUsers',
                  ),
                  SizedBox(height: 20),
                  _buildCard(
                    'Active Users',
                    adminOverviewData['activeUsers'],
                    Icons.check_circle,
                    'activeUsers',
                  ),
                  SizedBox(height: 20),
                  _buildCard(
                    'Students',
                    adminOverviewData['students'],
                    Icons.school,
                    'students',
                  ),
                  SizedBox(height: 20),
                  _buildCard(
                    'Staff',
                    adminOverviewData['staff'],
                    Icons.work,
                    'staff',
                  ),
                  SizedBox(height: 20),
                  _buildCard(
                    'Warden',
                    adminOverviewData['warden'],
                    Icons.security,
                    'warden',
                  ),
                ],
              ),
              ),
            ),
    );
  }

  Widget _buildCard(String title, dynamic count, IconData icon, String category) {
  // Check if the category is 'totalUsers', only then show the "View Details" button
  bool showButton = category == 'totalUsers';

  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(20),
      leading: Icon(icon, size: 38, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '$count users',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: showButton
          ? ElevatedButton(
              onPressed: () => _viewDetails(category),
              child: Text('View Details'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            )
          : null,  // Don't show the button if it's not 'totalUsers'
    ),
  );
}


  void _viewDetails(String category) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('View Details for $category'),
    ));
  }
}
