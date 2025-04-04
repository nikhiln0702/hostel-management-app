import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';  // Import the intl package
import 'admin_viewpendingbills.dart';

class AdminBillOverviewPage extends StatefulWidget {
  @override
  _AdminOverviewPageState createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminBillOverviewPage> {
  bool _isLoading = true;
  Map<String, dynamic> adminOverviewData = {};

  // Fetch admin overview data from the backend
  Future<void> _fetchAdminOverview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      final response = await http.get(
        Uri.parse('http://192.168.34.182:7000/api/v1/getmessbillsummary'),
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
          adminOverviewData = data['data'];  // Adjust based on your backend response
          _isLoading = false;  // Set loading to false once data is fetched
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
          return await _fetchAdminOverview(); // Retry the same complaint submission with new access token
        }
      }
      else {
        throw Exception('Failed to load data');
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
  // Show an error message in a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Method to format amount as currency with rupee symbol and 3 decimal places
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 3);
    return formatter.format(amount);
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
                      'Total Collected',
                      adminOverviewData['totalCollected'],
                      Icons.account_balance_wallet,  // New icon for Total Collected
                    ),
                    SizedBox(height: 20),
                    _buildCard(
                      'Total Pending',
                      adminOverviewData['totalPending'],
                      Icons.pending,
                    ),
                    SizedBox(height: 20),
                    // New card for View Pending Bills
                    _buildPendingBillsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  // New method to build card for "View Pending Bills"
  Widget _buildPendingBillsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Icon(Icons.pending_actions, size: 38, color: Colors.blue),
        title: Text(
          'View Pending Bills',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.blue),  // Arrow icon
        onTap: _viewPendingBills,  // Trigger the function on tap
      ),
    );
  }

  // Method to handle the action when "View Pending Bills" is tapped
  void _viewPendingBills() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redirecting to pending bills...')),
    );
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PendingBillsPage()), // Push the PendingBillsPage
  );
  }

  Widget _buildCard(String title, dynamic amount, IconData icon) {
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
          formatCurrency(amount),  // Format amount using the method
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
