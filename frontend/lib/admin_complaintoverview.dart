import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsOverviewPage extends StatefulWidget {
  @override
  _ComplaintsOverviewPageState createState() => _ComplaintsOverviewPageState();
}

class _ComplaintsOverviewPageState extends State<ComplaintsOverviewPage> {
  bool _isLoading = true;
  int activeComplaintsCount = 0;
  int resolvedComplaintsCount = 0;

  

  // Fetch active and resolved complaints count from the backend
  Future<void> _fetchComplaintsOverview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.34.182:7000/api/v1/getcomplaintsoverview'),
        headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          activeComplaintsCount = data['data']['activeComplaintsCount']; // Set active complaints count
          resolvedComplaintsCount = data['data']['resolvedComplaintsCount']; // Set resolved complaints count



          _isLoading = false; // Set loading to false once data is fetched
        });
      }
      else if (response.statusCode == 401) {
        // Token expired, attempt to refresh
        bool tokenRefreshed = await refreshAccessToken();

        if (!tokenRefreshed) {
          // If refresh fails, logout the user
          await logout();
        } else {
          // Retry the request with the new token
          return await _fetchComplaintsOverview();
        }
      } else {
        throw Exception('Failed to load complaints overview');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;  // Set loading to false even if there's an error
      });
      _showErrorSnackBar(error.toString());
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
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String accessToken = data['data']['accessToken']; // Assuming the response has a new accessToken
      await prefs.setString('accessToken', accessToken);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    Navigator.pushReplacementNamed(context, '/'); // Navigate to login screen
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _fetchComplaintsOverview(); // Fetch complaints data when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints Overview'),
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
                    _buildComplaintsCard('Active Complaints', activeComplaintsCount, '/active_complaints'),
                    _buildComplaintsCard('Resolved Complaints', resolvedComplaintsCount, '/resolved_complaints'),
                  ],
                ),
              ),
            ),
    );
  }

  // Method to build the cards for active and resolved complaints
  Widget _buildComplaintsCard(String title, int complaintCount, String route) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Icon(
          title == 'Active Complaints' ? Icons.report_problem : Icons.check_circle,
          size: 38,
          color: title == 'Active Complaints' ? Colors.red : Colors.green,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$complaintCount', // Displaying the complaint count
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.blue),
        onTap: () {
          // Navigate to the respective page
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
