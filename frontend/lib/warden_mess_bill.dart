import 'package:flutter/material.dart';
import 'student_dashboard.dart';

class MessBillPage extends StatefulWidget {
  const MessBillPage({super.key});

  @override
  State<MessBillPage> createState() => _MessBillPageState();
}

class _MessBillPageState extends State<MessBillPage> {
  String selectedYear = "2025";
  String selectedMonth = "January";
  int? daysPresent;
  double? totalAmount;

  final Map<String, Map<String, Map<String, dynamic>>> billData = {
    "2025": {
      "January": {"daysPresent": 25, "totalAmount": 1250.0},
      "February": {"daysPresent": 20, "totalAmount": 1000.0},
      "March": {"daysPresent": 23, "totalAmount": 1150.0},
      "April": {"daysPresent": 27, "totalAmount": 1350.0},
    },
    "2024": {
      "January": {"daysPresent": 22, "totalAmount": 1100.0},
      "February": {"daysPresent": 19, "totalAmount": 950.0},
      "March": {"daysPresent": 21, "totalAmount": 1050.0},
      "April": {"daysPresent": 26, "totalAmount": 1300.0},
    },
  };

  void updateBillDetails(String year, String month) {
    setState(() {
      selectedYear = year;
      selectedMonth = month;
      daysPresent = billData[year]?[month]?["daysPresent"];
      totalAmount = billData[year]?[month]?["totalAmount"];
    });
  }

  @override
  void initState() {
    super.initState();
    updateBillDetails(selectedYear, selectedMonth);
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentDashboard()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year & Month Selection Row
            Row(
              children: [
                // Year Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: DropdownButton<String>(
                      value: selectedYear,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedYear = newValue;
                            selectedMonth = billData[selectedYear]!.keys.first;
                            updateBillDetails(selectedYear, selectedMonth);
                          });
                        }
                      },
                      items: billData.keys.map<DropdownMenuItem<String>>(
                        (String year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 10), // Space between dropdowns
                
                // Month Selection
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: billData[selectedYear]!.keys.map<Widget>((String month) {
                        return GestureDetector(
                          onTap: () {
                            updateBillDetails(selectedYear, month);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedMonth == month ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Center(
                              child: Text(
                                month,
                                style: TextStyle(
                                  color: selectedMonth == month ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bill Details
            if (daysPresent != null && totalAmount != null)
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
    );
  }
}
