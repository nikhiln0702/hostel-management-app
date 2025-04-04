import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WardenFeesScreen extends StatefulWidget {
  @override
  _WardenFeesScreenState createState() => _WardenFeesScreenState();
}

class _WardenFeesScreenState extends State<WardenFeesScreen> {
  final TextEditingController mpdController = TextEditingController();
  final TextEditingController kswController = TextEditingController();
  final TextEditingController estController = TextEditingController();
  final TextEditingController elecController = TextEditingController();

  String? selectedMonth;
  String? selectedYear;
  double? mpd, ksw, est, elec, totalAmount;

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  final List<String> years = List.generate(11, (index) => (2020 + index).toString());

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    mpdController.addListener(() => _updateValue(mpdController, "mpd"));
    kswController.addListener(() => _updateValue(kswController, "ksw"));
    estController.addListener(() => _updateValue(estController, "est"));
    elecController.addListener(() => _updateValue(elecController, "elec"));
  }

  void _updateValue(TextEditingController controller, String field) {
    setState(() {
      double? value = controller.text.isNotEmpty ? double.tryParse(controller.text) : null;
      switch (field) {
        case "mpd":
          mpd = value;
          break;
        case "ksw":
          ksw = value;
          break;
        case "est":
          est = value;
          break;
        case "elec":
          elec = value;
          break;
      }
      totalAmount = (ksw ?? 0) + (est ?? 0) + (elec ?? 0);
    });
  }

  Future<void> saveChanges() async {
    if (selectedMonth == null || selectedYear == null || mpd == null || ksw == null || elec == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Construct the request body for the API
    final requestBody = {
      'month': selectedMonth,
      'year': selectedYear,
      'mpd_rate': mpd ?? 0.0,
      'ksw_charges': ksw ?? 0.0,
      'electricity_charges': elec ?? 0.0,
      'est': est ?? 0.0,
      'month_number': months.indexOf(selectedMonth!) + 1,  // Month number (1 for January, 2 for February, etc.)
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No access token found! Please log in again."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Send data to backend API
   try{ final response = await http.post(
      Uri.parse('http://192.168.34.182:7000/api/v1/publishmessbill'),  // Replace with your API endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(requestBody),
    );

    // Debugging: Print the response status code and body
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data saved successfully for $selectedMonth $selectedYear!"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving data! Please try again."),
        backgroundColor: Colors.red,
      ));
    }}
    catch(e){
      print(e);
    }
  }

  Future<void> loadPreviousData() async {
    if (selectedMonth == null || selectedYear == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String keyPrefix = "${selectedMonth}_$selectedYear";

    setState(() {
      mpd = prefs.getDouble("${keyPrefix}_mpd");
      ksw = prefs.getDouble("${keyPrefix}_ksw");
      est = prefs.getDouble("${keyPrefix}_est");
      elec = prefs.getDouble("${keyPrefix}_elec");

      mpdController.text = mpd != null ? mpd.toString() : "";
      kswController.text = ksw != null ? ksw.toString() : "";
      estController.text = est != null ? est.toString() : "";
      elecController.text = elec != null ? elec.toString() : "";

      totalAmount = (ksw ?? 0) + (est ?? 0) + (elec ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Monthly Fees"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child:Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade300, Colors.deepPurple.shade700],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month & Year Selection
            Row(
              children: [
                Expanded(child: _buildDropdown("Select Month", months, selectedMonth, (value) {
                  setState(() {
                    selectedMonth = value;
                    loadPreviousData();
                  });
                })),
                SizedBox(width: 10),
                Expanded(child: _buildDropdown("Select Year", years, selectedYear, (value) {
                  setState(() {
                    selectedYear = value;
                    loadPreviousData();
                  });
                })),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField("MPD Rate", mpdController),
            _buildTextField("KSW Charges", kswController),
            _buildTextField("Estimation Charges", estController),
            _buildTextField("Electricity Charges", elecController),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, double? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value != null ? "₹${value.toStringAsFixed(2)}" : "--", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}