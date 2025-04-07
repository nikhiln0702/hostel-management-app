import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PendingBillsPage extends StatefulWidget {
  @override
  _PendingBillsPageState createState() => _PendingBillsPageState();
}

class _PendingBillsPageState extends State<PendingBillsPage> {
  bool _isLoading = true;
  List<dynamic> pendingBills = [];

  // Fetch pending bills from the backend
  Future<void> _fetchPendingBills() async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getpendingbills'),
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
          pendingBills = data['data'];  // Adjust based on your backend response
          _isLoading = false;  // Set loading to false once data is fetched
        });
      } else if (response.statusCode == 401) {
        // Token expired, attempt to refresh
        bool tokenRefreshed = await refreshAccessToken();

        if (!tokenRefreshed) {
          // If refresh fails, logout the user
          await logout();
        } else {
          // Retry the request with the new token
          return await _fetchPendingBills(); // Retry the same request
        }
      } else {
        throw Exception('Failed to load pending bills');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;  // Set loading to false even if there's an error
      });
      _showErrorSnackBar(error.toString());
    }
  }

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

  @override
  void initState() {
    super.initState();
    _fetchPendingBills();  // Fetch pending bills when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Bills'),
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
                    ...pendingBills.map((bill) {
                      return _buildBillCard(bill);  // Build card for each bill
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  // New method to build card for each Pending Bill
 Widget _buildBillCard(dynamic bill) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(20),
      leading: Icon(Icons.pending_actions, size: 38, color: Colors.blue),
      title: Text(
        bill['username'] ?? 'No username',  // Directly accessing username
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '₹${bill['total_amount'].toStringAsFixed(3)}',  // Directly accessing total_amount
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            '${bill['month']} ${bill['year']}',  // Displaying month and year
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      onTap: () {
        // Handle the tap event, maybe show more details
        _showErrorSnackBar('Tapped on bill: ${bill['username'] ?? 'No username'}');
      },
    ),
  );
}
}
