import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResolvedComplaintsPage extends StatefulWidget {
  @override
  _ResolvedComplaintsPageState createState() => _ResolvedComplaintsPageState();
}

class _ResolvedComplaintsPageState extends State<ResolvedComplaintsPage> {
  bool _isLoading = true;
  List<dynamic> resolvedComplaints = [];

  // Fetch resolved complaints data from the backend
  Future<void> _fetchResolvedComplaints() async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getcomplaintsoverview'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          resolvedComplaints = data['data']['resolvedComplaints']; // Set the resolved complaints data
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load resolved complaints');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
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
    _fetchResolvedComplaints(); // Fetch resolved complaints when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resolved Complaints'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...resolvedComplaints.map((complaint) {
                      return _buildComplaintCard(complaint);  // Create card for each complaint
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  // Method to build a card for each complaint
  Widget _buildComplaintCard(dynamic complaint) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Icon(
          Icons.check_circle,
          size: 38,
          color: Colors.green,
        ),
        title: Text(
          complaint['category'] ?? 'No title',  // Displaying complaint title
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          complaint['description'] ?? 'No description',  // Displaying complaint description
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.blue),
        onTap: () {
          // Handle the tap event, you can navigate to a detailed page or show details
          _showErrorSnackBar('Tapped on complaint: ${complaint['title']}');
        },
      ),
    );
  }
}
