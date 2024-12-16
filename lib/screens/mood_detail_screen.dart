import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodDetailScreen extends StatefulWidget {
  final DateTime date;

  const MoodDetailScreen({super.key, required this.date});

  @override
  State<MoodDetailScreen> createState() => _MoodDetailScreenState();
}

class _MoodDetailScreenState extends State<MoodDetailScreen> {
  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  double _moodValue = 50;
  List<Map<String, dynamic>> _goals = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid ?? ''; // Get the userId
    _loadRecord();
  }

  // Load data from Firestore based on userId and date
  Future<void> _loadRecord() async {
    if (_userId.isEmpty) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mood_records')
          .doc(dateStr)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _journalController.text = data['journal'] ?? '';
          _moodValue = data['mood'] ?? 50.0;
          _goals = List<Map<String, dynamic>>.from(data['goals'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading record: $e');
    }
  }

  // Save the record to Firestore
  Future<void> _saveRecord() async {
    if (_userId.isEmpty) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mood_records')
          .doc(dateStr)
          .set({
        'journal': _journalController.text,
        'mood': _moodValue,
        'goals': _goals,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood record saved!')),
      );
    } catch (e) {
      print('Error saving record: $e');
    }
  }

  // Delete the record from Firestore
  Future<void> _deleteRecord() async {
    if (_userId.isEmpty) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mood_records')
          .doc(dateStr)
          .delete();
      setState(() {
        _journalController.clear();
        _moodValue = 50;
        _goals.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood record deleted!')),
      );
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  // Add a new goal to the list
  void _addGoal(String goal) {
    setState(() {
      _goals.add({'goal': goal, 'completed': false});
    });
    _goalController.clear();
    _updateGoals();
  }

  // Update goals in Firestore after changes
  void _updateGoals() async {
    if (_userId.isEmpty) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('mood_records')
          .doc(dateStr)
          .update({
        'goals': _goals,
      });
    } catch (e) {
      print('Error updating goals: $e');
    }
  }

  // Get the emoji based on mood value
  String _getMoodEmoji() {
    if (_moodValue < 20) {
      return "😢";
    } else if (_moodValue < 40) {
      return "😟";
    } else if (_moodValue < 60) {
      return "😐";
    } else if (_moodValue < 80) {
      return "😊";
    } else {
      return "😁";
    }
  }

  // Get the label for mood based on mood value
  String _getMoodLabel() {
    if (_moodValue < 20) {
      return "Sad";
    } else if (_moodValue < 40) {
      return "Worried";
    } else if (_moodValue < 60) {
      return "Neutral";
    } else if (_moodValue < 80) {
      return "Happy";
    } else {
      return "Excited";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood Tracker - ${DateFormat('d MMMM y').format(widget.date)}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6b5b95),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journaling Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 190, 79),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How was Your Day? 😊",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6b5b95),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _journalController,
                        maxLines: 6,
                        decoration: const InputDecoration.collapsed(
                          hintText: "Write about your day...",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mood Tracking Section
              Center(
                child: Column(
                  children: [
                    const Text(
                      "How You're Feeling Right Now? 🤔",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6b5b95),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getMoodEmoji(),
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMoodLabel(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6b5b95),
                      ),
                    ),
                    Slider(
                      value: _moodValue,
                      min: 0,
                      max: 100,
                      divisions: 4,
                      activeColor: const Color(0xFF6b5b95),
                      onChanged: (value) {
                        setState(() {
                          _moodValue = value;
                        });
                        _updateGoals();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Goals Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 190, 79),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What's Your Goal for Today? 🏆",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6b5b95),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create your goals by adding the list below.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(
                            _goals[index]['goal'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          value: _goals[index]['completed'],
                          onChanged: (value) {
                            setState(() {
                              _goals[index]['completed'] = value!;
                            });
                            _updateGoals();
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _goalController,
                            decoration: const InputDecoration(
                              hintText: "Add a new goal...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_goalController.text.isNotEmpty) {
                              _addGoal(_goalController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6b5b95),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save & Delete Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveRecord,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("Save",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6b5b95),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _deleteRecord,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Delete",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
