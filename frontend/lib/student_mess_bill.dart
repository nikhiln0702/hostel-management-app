import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessBillPage extends StatefulWidget {
  const MessBillPage({super.key});

  @override
  State<MessBillPage> createState() => _MessBillPageState();
}

class _MessBillPageState extends State<MessBillPage> {
  Razorpay _razorpay = Razorpay();
  int selectedYear = 2025; // Default year
  String selectedMonth = "January"; // Default month
  int? daysPresent;
  double? totalAmount;
  String paymentStatus = "Pending";

  double? mpdRate;
  double? kswCharges;
  double? electricityCharges;
  double? rent;
  double? estCharges;

  bool isLoading = true;
  bool isError = false;
  List<dynamic> billData = [];

  @override
  void initState() {
    super.initState();
    fetchMessBills();

    // Initialize Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<void> fetchMessBills() async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) {
        showErrorDialog(
          context,
          "Access token is missing. Please log in again.",
        );
        return;
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/viewmessbill',
        ), // Replace with your API URL
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 401) {
        // Token expired, attempt to refresh
        bool tokenRefreshed = await refreshAccessToken();

        if (!tokenRefreshed) {
          // If refresh fails, logout the user
          await logout();
        } else {
          // Retry the request with the new token
          return await fetchMessBills(); // Retry the same complaint submission with new access token
        }
      }
      else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['statuscode'] == 200) {
          setState(() {
            billData = data['data']; // Set the fetched data
            isLoading = false;
            updateBillDetails(selectedYear, selectedMonth);
          });
        } else {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        print(e);
        isLoading = false;
        isError = true;
      });
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
  void updateBillDetails(int year, String month) async {
    final selectedBill = billData.firstWhere(
      (bill) => bill['year'] == year && bill['month'] == month,
      orElse: () => null,
      
    );

    if (selectedBill != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('billId', selectedBill['id']);
      
      setState(() {
        selectedYear = year;
        selectedMonth = month;
        daysPresent = selectedBill['days_present'];
        totalAmount = selectedBill['total_amount'].toDouble();
        paymentStatus = selectedBill['status'];
        mpdRate = (selectedBill['mpd_rate'] is int)
          ? (selectedBill['mpd_rate'] as int).toDouble()
          : selectedBill['mpd_rate']?.toDouble();

      kswCharges = (selectedBill['ksw_charges'] is int)
          ? (selectedBill['ksw_charges'] as int).toDouble()
          : selectedBill['ksw_charges']?.toDouble();

      electricityCharges = (selectedBill['electricity_charges'] is int)
          ? (selectedBill['electricity_charges'] as int).toDouble()
          : selectedBill['electricity_charges']?.toDouble();

      rent = (selectedBill['rent'] is int)
          ? (selectedBill['rent'] as int).toDouble()
          : selectedBill['rent']?.toDouble();

      estCharges = (selectedBill['est_charges'] is int)
          ? (selectedBill['est_charges'] as int).toDouble()
          : selectedBill['est_charges']?.toDouble();
      
      });
    } else {
      setState(() {
        daysPresent = null;
        totalAmount = null;
        paymentStatus = "No bill available for this month";
      });
    }
  }

  Future<void> createRazorpayOrder() async {
    setState(() {
      isLoading = true;  // Start loading indicator
    });
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (totalAmount == null || totalAmount == 0) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    String? billId = prefs.getString('billId');
    print("Response Status: $billId");

    final response = await http.post(
      Uri.parse('$baseUrl/createOrder'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'billId': billId}),
    );
    print("Response Body: ${response.body}");

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['statuscode'] == 201) {
        var order = data['data'];

        var options = {
          'key': 'rzp_test_XbdZLXXcfjn6mc',
          'amount': order['amount'],
          'name': 'Mess Bill Payment',
          'order_id': order['id'],
          'description': 'Payment for mess bill',
          'prefill': {'contact': '9876543210', 'email': 'test@example.com'},
          'theme': {'color': '#F37254'},
        };
        setState(() {
          isLoading = false;  // Stop loading on error
        });
        _razorpay.open(options);
      }
    } else {
      setState(() {
          isLoading = false;  // Stop loading on error
        });
      showErrorDialog(
        context,
        "Failed to create payment order. Please try again.",
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    verifyPayment(response.paymentId!, response.orderId!, response.signature!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showErrorDialog(context, "Payment failed. Please try again.");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showErrorDialog(context, "Payment failed. Please try again.");
  }

  Future<void> verifyPayment(
    String paymentId,
    String orderId,
    String signature,
  ) async {
    await dotenv.load(fileName: "assets/.env");
    final baseUrl = dotenv.env['API_BASE_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    String? billId = prefs.getString('billId');
    final response = await http.post(
      Uri.parse('$baseUrl/verifyPayment'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'billId': billId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        paymentStatus = 'Paid';
      });
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Completed Successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),),);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('billId'); // or any other relevant key

    } else {
      showErrorDialog(
        context,
        "Payment verification failed. Please try again.",
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    // List of months and years
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    List<int> years = [2024, 2025]; // List of years for the dropdown

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Mess Bill',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 32),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 32),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body:isLoading
    ? Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black26,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Loading...", style: TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ),
      )
      : Container(
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
              if (isLoading) Center(child: CircularProgressIndicator()),
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
                                  });
                                  updateBillDetails(selectedYear, newValue);
                                }
                              },
                              items:
                                  months.map<DropdownMenuItem<String>>((month) {
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
                    const SizedBox(width: 16),
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
                              value: selectedYear,
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
                                    selectedYear = newValue;
                                  });
                                  updateBillDetails(newValue, selectedMonth);
                                }
                              },
                              items:
                                  years.map<DropdownMenuItem<int>>((year) {
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
              if (!isLoading && !isError && daysPresent == null) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "No bill available for the selected month and year.",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ],
              if (!isLoading &&
                  !isError &&
                  daysPresent != null &&
                  totalAmount != null) ...[
                const SizedBox(height: 20),
                // Attractive Card for Payment Details
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Days Present: $daysPresent", style: TextStyle(fontSize: 22, // Increased font size
              fontWeight: FontWeight.bold, // Bold font weight
              )),
                        const SizedBox(height: 10),
                        Text("Total Amount: ₹${totalAmount?.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, // Increased font size
              fontWeight: FontWeight.bold, // Bold font weight
            )),
                        const SizedBox(height: 10),
                        Text("MPD Rate: ₹${mpdRate?.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("KSW Charges: ₹${kswCharges?.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("Electricity Charges: ₹${electricityCharges?.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("Rent: ₹${rent?.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("Estimated Charges: ₹${estCharges?.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 20),
                        const SizedBox(height: 10),
                        Text(
                          "Payment Status: $paymentStatus",
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                paymentStatus == "Pending"
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (paymentStatus == "Pending")
                          ElevatedButton(
                            onPressed: createRazorpayOrder,
                            child: const Text(
                              "Pay",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                      if (paymentStatus == "Paid")
            ElevatedButton(
              onPressed: () {
                // Logic to show the fee receipt, either by opening a PDF or navigating to a new screen
                // showFeeReceipt();
              },
              child: const Text("Paid", style: TextStyle(fontSize: 18)),
            ),
                      ],

                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
