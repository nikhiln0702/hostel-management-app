import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(ComplaintsApp());
}

class ComplaintsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ComplaintsPage(),
    );
  }
}

// Complaints Page
class ComplaintsPage extends StatefulWidget {
  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade300], // Set gradient to white and blue
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "File a Complaint" Box
              GestureDetector(
                onTap: () {
                  // Navigate to the "File a Complaint" form
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FileComplaintPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_copy,
                          color: Colors.blue.shade800,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "File a Complaint",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // "View Complaints" Box
              GestureDetector(
                onTap: () {
                  // Navigate to the "View Complaints" page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewComplaintsPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.view_list,
                          color: Colors.blue.shade800,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "View Complaints",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// File a Complaint Page with Glassmorphic Form
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

  void _submitComplaint() {
    String complaintText = complaintController.text;

    if (complaintText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter your complaint!")));
      return;
    }

    // Process complaint submission (e.g., send to database)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Complaint submitted successfully!")),
    );

    // Clear fields after submission
    complaintController.clear();
    setState(() {
      selectedCategory = 'Maintenance';
    });
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

// View Complaints Page
class ViewComplaintsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Complaints"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 5, // Placeholder count for demo
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text("Complaint #${index + 1}"),
                subtitle: Text("This is a description of the complaint."),
              ),
            );
          },
        ),
      ),
    );
  }
}
