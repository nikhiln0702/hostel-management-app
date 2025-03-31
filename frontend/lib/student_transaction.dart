import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // A list to hold the transaction data
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;  // To track loading state
  String errorMessage = ''; // To show error messages

  // Function to fetch transactions from the API
  Future<void> _fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    
    setState(() {
      isLoading = true;  // Start loading
      errorMessage = '';  // Clear any previous error message
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5:7000/api/v1/gettransactionhistory'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        print('response ${response.body}');
        setState(() {
          transactions = List<Map<String, dynamic>>.from(data['data'].map((transaction) {
            return {
              'PaymentID': transaction['paymentId'], // Assuming 'PaymentID' is the field name
              'Amount': transaction['amount'],
              'Month': transaction['month'], // Assuming 'Month' is the field name
              'Year': transaction['year'], // Assuming 'Year' is the field name
            };
          }).toList());

          isLoading = false; // Finished loading
        });
      } else {
        // Handle failed response
        setState(() {
          errorMessage = 'Failed to load transactions';
          isLoading = false; // Finished loading with error
        });
      }
    } catch (error) {
      setState(() {
        print(error);
        errorMessage = 'Failed to load transactions. Please try again later.';
        isLoading = false; // Finished loading with error
      });
    }
  }

  // Function to add a new transaction dynamically
  

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); // Fetch the transactions when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
        backgroundColor: Colors.blue,
       
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transaction History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // If still loading, show a loading spinner
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? Center(
                          child: Text(
                            errorMessage.isEmpty
                                ? 'No Transactions Available'
                                : errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              var transaction = transactions[index];
                              return Card(
                                elevation: 8.0,
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(20.0),
                                  title: Text(
                                    'Payment ID: ${transaction["PaymentID"]!}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        "Amount: ${transaction["Amount"]!}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Month: ${transaction["Month"]!}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Year: ${transaction["Year"]!}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
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
      ),
    );
  }
}
