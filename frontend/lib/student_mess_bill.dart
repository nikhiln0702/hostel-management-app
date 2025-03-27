import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'student_dashboard.dart'; // ✅ Import StudentDashboard for navigation

class MessBillPage extends StatefulWidget {
  const MessBillPage({super.key});

  @override
  State<MessBillPage> createState() => _MessBillPageState();
}

class _MessBillPageState extends State<MessBillPage> {
  int selectedYear = 2025; // Default year
  String selectedMonth = "January"; // Default month
  int? daysPresent;
  double? totalAmount;
  String paymentStatus = "Pending";

  bool isLoading = true; // For loading state
  bool isError = false;  // For error state
  List<dynamic> billData = []; // This will hold the fetched data

  // Fetch Mess Bills from API
  Future<void> fetchMessBills() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        showErrorDialog(context, "Access token is missing. Please log in again.");
        return;
      }
      final response = await http.get(
        Uri.parse('http://localhost:7000/api/v1/viewmessbill'), // Replace with your API URL
       headers: {
          'Authorization': 'Bearer $accessToken', // Include Bearer token in header
          'Content-Type': 'application/json',
        }, // If you use token authentication
      );

      if (response.statusCode == 200) {
        // If the API call is successful, parse the data
        final data = json.decode(response.body);
        if (data['statuscode'] == 200) {
          setState(() {
            billData = data['data']; // Set the fetched data
            isLoading = false;
            updateBillDetails(selectedYear, selectedMonth);
          });
        } else {
          setState(() {
            print("Error: ${response.statusCode} - ${response.body}");
            isLoading = false;
            isError = true;
          });
        }
      } else {
        // Handle server errors
        setState(() {
          print("Error: ${response.statusCode} - ${response.body}");
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      // Handle errors like no internet connection, etc.
      setState(() {
            print("Error: $e"); // Print the exception

        isLoading = false;
        isError = true;
      });
    }
  }

  // Show error dialog
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Update Bill Details based on the selected year and month
  void updateBillDetails(int year, String month) {
    final selectedBill = billData.firstWhere(
      (bill) => bill['year'] == year && bill['month'] == month,
      orElse: () => null,
    );

    if (selectedBill != null) {
      setState(() {
        selectedYear = year;
        selectedMonth = month;
        daysPresent = selectedBill['days_present'];
        totalAmount = selectedBill['total_amount'];
        paymentStatus = selectedBill['status'];
      });
    } else {
      // If no data is found for the selected year and month
      setState(() {
        daysPresent = null;
        totalAmount = null;
        paymentStatus = "Pending";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessBills(); // Fetch data when the page is first loaded
  }

  @override
  Widget build(BuildContext context) {
    // Extract unique years from the bill data
    List<int> uniqueYears = billData
        .map((bill) => bill['year'] as int)
        .toSet()
        .toList(); // Convert to Set and then back to List to remove duplicates

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Mess Bill',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentDashboard()),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home, color: Colors.white, size: 32), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person, color: Colors.white, size: 32), onPressed: () {}),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading state
              if (isLoading)
                Center(child: CircularProgressIndicator()),
              // Error state
              if (isError)
                Center(child: Text('Failed to load data. Please try again.', style: TextStyle(color: Colors.red))),
              
              // Month and Year Selection
              if (!isLoading && !isError && billData.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Month Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Month:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: DropdownButton<String>(
                              value: selectedMonth,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              underline: const SizedBox(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  updateBillDetails(selectedYear, newValue);
                                }
                              },
                              items: billData.map<DropdownMenuItem<String>>((bill) {
                                return DropdownMenuItem<String>(
                                  value: bill['month'],
                                  child: Text(bill['month']),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16), // Spacing between Month and Year

                    // Year Dropdown (Ensure unique years)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Year:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: DropdownButton<int>(
                              value: selectedYear,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              underline: const SizedBox(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedYear = newValue;
                                    updateBillDetails(selectedYear, selectedMonth);
                                  });
                                }
                              },
                              items: uniqueYears.map<DropdownMenuItem<int>>((year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // No Bills available message below the dropdowns if no data is found
              if (!isLoading && !isError && daysPresent == null && totalAmount == null)
                Center(child: Text('No Bills available for this year and month.')),
              
              // Bill Details (Display the selected month/year)
              if (!isLoading && !isError && daysPresent != null && totalAmount != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Days Present: $daysPresent", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text("Total Payable Amount: ₹$totalAmount", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Payment of ₹$totalAmount initiated!")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          ),
                          child: const Text("Pay", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
