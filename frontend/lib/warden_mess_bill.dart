import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessBillPage extends StatefulWidget {
  const MessBillPage({super.key});

  @override
  State<MessBillPage> createState() => _MessBillPageState();
}

class _MessBillPageState extends State<MessBillPage> {
  String selectedYear = "2025";
  String selectedMonth = "January";
  List<dynamic> allBills = []; // Store all bills
  List<dynamic> filteredBills = []; // Store filtered bills
  bool isLoading = true;
  bool isError = false;

  // List of months and years
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  List<int> years = [2024, 2025]; // List of years for the dropdown

  String paymentStatusFilter = 'All'; // Default filter is 'All'

  // Function to fetch bills from the backend
  Future<void> fetchBills(String year, String month) async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    final url = Uri.parse('$baseUrl/viewbills'); // Replace with your backend API URL

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'month': month, 'year': year}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          allBills = responseBody['data'];  // Update bills with fetched data
          filteredBills = _filterBills(paymentStatusFilter);  // Apply the current filter
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print('Error occurred: $error');
    }
  }

  // Method to filter bills based on payment status
  List<dynamic> _filterBills(String status) {
    if (status == 'All') {
      return allBills;  // Show all bills
    } else {
      return allBills.where((bill) => bill['paymentStatus'] == status).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBills(selectedYear, selectedMonth);  // Initial fetch on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Mess Bill', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading) const Center(child: CircularProgressIndicator()),

            if (isError)
              Center(
                child: Text(
                  'Failed to load data. Please try again.',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            if (!isLoading && !isError)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Year Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Year:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: DropdownButton<int>(
                            value: int.parse(selectedYear),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            underline: const SizedBox(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedYear = newValue.toString();
                                  fetchBills(selectedYear, selectedMonth); // Fetch bills for selected year
                                });
                              }
                            },
                            items: years.map<DropdownMenuItem<int>>((int year) {
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
                  const SizedBox(width: 16),
                  // Month Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Month:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedMonth = newValue;
                                  fetchBills(selectedYear, selectedMonth); // Fetch bills for selected month
                                });
                              }
                            },
                            items: months.map<DropdownMenuItem<String>>((String month) {
                              return DropdownMenuItem<String>(
                                value: month,
                                child: Text(month),
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

            // Payment Status Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton("All", Colors.blue),
                _buildFilterButton("Paid", Colors.green),
                _buildFilterButton("Pending", Colors.red),
              ],
            ),

            const SizedBox(height: 20),

            // Display Bills
            if (filteredBills.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    var bill = filteredBills[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(bill['studentName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Amount: ₹${bill['totalAmount'].toStringAsFixed(2)}"),
                            Text("Payment Status: ${bill['paymentStatus']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build Filter Button Widget
  Widget _buildFilterButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          paymentStatusFilter = label;
          filteredBills = _filterBills(paymentStatusFilter); // Apply the filter
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: paymentStatusFilter == label ? color : Colors.grey, // Change color when selected
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
