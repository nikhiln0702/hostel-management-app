import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WardenNotesScreen extends StatefulWidget {
  @override
  _WardenNotesScreenState createState() => _WardenNotesScreenState();
}

class _WardenNotesScreenState extends State<WardenNotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // ✅ Load saved notes
  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList('warden_notes') ?? [];
    });
  }

  // ✅ Save notes instantly
  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('warden_notes', notes);
  }

  // ✅ Add new note
  void _addNote() {
    String noteText = _noteController.text.trim();
    if (noteText.isNotEmpty) {
      setState(() {
        notes.add(noteText);
        _noteController.clear();
      });
      _saveNotes();
      _sendNotification(noteText); // ✅ Send notification on note submission
    }
  }

  // ✅ Send notification (Placeholder)
  void _sendNotification(String message) {
    print("🔔 Notification Sent: $message"); 
    // TODO: Implement actual notification sending logic (Firebase or API)
  }

  // ✅ Delete selected notes
  void _deleteNotes(List<int> selectedIndexes) {
    setState(() {
      selectedIndexes.sort((a, b) => b.compareTo(a));
      for (var index in selectedIndexes) {
        notes.removeAt(index);
      }
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Warden Notes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // ✅ Input Field & Submit Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "Enter note...",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addNote,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),

            // ✅ Display Existing Notes
            Expanded(
              child: notes.isEmpty
                  ? Center(child: Text("No notes yet!", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(notes[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNotes([index]),
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
}
