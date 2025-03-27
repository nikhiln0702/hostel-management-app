
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // Sample transaction data (Initially some dummy data)
  List<Map<String, String>> transactions = [
    {
      "ID": "TXN001",
      "Name": "John Doe",
      "Date": "2024-03-12",
      "Amount": "\$200",
      "Status": "Paid",
    },
    {
      "ID": "TXN002",
      "Name": "Jane Smith",
      "Date": "2024-03-10",
      "Amount": "\$150",
      "Status": "Pending",
    },
  ];

  // Function to add a new transaction dynamically
  void _addTransaction() {
    setState(() {
      transactions.add({
        "ID": "TXN00${transactions.length + 1}",
        "Name": "Student ${transactions.length + 1}",
        "Date": "2024-03-15",
        "Amount": "\$${(transactions.length + 1) * 50}",
        "Status": (transactions.length % 2 == 0) ? "Paid" : "Pending",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTransaction, // Adds a new transaction when clicked
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transaction History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Scrollable table for transactions
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    border: TableBorder.all(width: 1, color: Colors.black12),
                    columns: [
                      DataColumn(
                        label: Text(
                          "ID",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Amount",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows:
                        transactions.map((transaction) {
                          return DataRow(
                            cells: [
                              DataCell(Text(transaction["ID"]!)),
                              DataCell(Text(transaction["Name"]!)),
                              DataCell(Text(transaction["Date"]!)),
                              DataCell(Text(transaction["Amount"]!)),
                              DataCell(
                                Text(
                                  transaction["Status"]!,
                                  style: TextStyle(
                                    color:
                                        transaction["Status"] == "Paid"
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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