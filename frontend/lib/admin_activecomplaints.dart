import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActiveComplaintsPage extends StatefulWidget {
  @override
  _ActiveComplaintsPageState createState() => _ActiveComplaintsPageState();
}

class _ActiveComplaintsPageState extends State<ActiveComplaintsPage> {
  bool _isLoading = true;
  List<dynamic> activeComplaints = [];

  // Fetch active complaints data from the backend
  Future<void> _fetchActiveComplaints() async {
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
          activeComplaints = data['data']['activeComplaints']; // Set the active complaints data
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load active complaints');
      }
    } catch (error) {
      setState(() {
        print(error);
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
    _fetchActiveComplaints(); // Fetch active complaints when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Complaints'),
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
                    ...activeComplaints.map((complaint) {
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
          Icons.report_problem,
          size: 38,
          color: Colors.red,
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
