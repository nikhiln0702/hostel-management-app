import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessBillScreen extends StatefulWidget {
  @override
  _MessBillScreenState createState() => _MessBillScreenState();
}

class _MessBillScreenState extends State<MessBillScreen> {
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  List<Map<String, dynamic>> students = [
    {"name": "John Doe", "roomNo": 101, "dueAmount": 500},
    {"name": "Alice Smith", "roomNo": 102, "dueAmount": 0},
    {"name": "Bob Johnson", "roomNo": 103, "dueAmount": 300},
    {"name": "Emma Brown", "roomNo": 104, "dueAmount": 700},
  ];

  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    filteredStudents = List.from(students); // Initialize with all students
  }

  void applyFilter() {
    setState(() {
      filteredStudents = students.where((student) {
        return true; // Modify if needed to filter by date
      }).toList();
    });
  }

  void sendNotifications() {
    List<String> dueStudents = filteredStudents
        .where((student) => student["dueAmount"] > 0)
        .map((student) => student["name"].toString()) // Ensure String type
        .toList();

    if (dueStudents.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Notification sent to: ${dueStudents.join(', ')}"),
          backgroundColor: Colors.deepPurple,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No students with dues."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          selectedFromDate = pickedDate;
          fromDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        } else {
          selectedToDate = pickedDate;
          toDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mess Bill", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: sendNotifications,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.purple.shade100], // Matches Complaints Screen
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "From Date",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: toDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "To Date",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400, width: 1),
      columnWidths: {
        0: FractionColumnWidth(0.3), // Name
        1: FractionColumnWidth(0.2), // Room No
        2: FractionColumnWidth(0.3), // Due Amount
        3: FractionColumnWidth(0.2), // Status
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.deepPurple),
          children: [
            _tableHeader("Name"),
            _tableHeader("Room No"),
            _tableHeader("Due Amount"),
            _tableHeader("Status"),
          ],
        ),
        ...filteredStudents.map((student) => _buildRow(student)).toList(),
      ],
    );
  }

  TableRow _buildRow(Map<String, dynamic> student) {
    return TableRow(
      children: [
        _tableCell(student["name"]),
        _tableCell(student["roomNo"].toString()),
        _tableCell("₹${student["dueAmount"]}", color: student["dueAmount"] > 0 ? Colors.red : Colors.green),
        _tableCell(student["dueAmount"] > 0 ? "Due" : "Paid", color: student["dueAmount"] > 0 ? Colors.red : Colors.green),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
    );
  }

  Widget _tableCell(String text, {Color? color}) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: color ?? Colors.black),
      ),
    );
  }
}
