import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'dart:math';
import 'mood_detail_screen.dart'; // Halaman journaling dan mood tracker
import 'chatbot_screen.dart'; // Halaman chatbot

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _today;
  late Timer _quoteTimer;
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> _quotes = [
    {
      "text": "Healing is not linear, but every step forward is progress.",
      "author": "Andiar Anjayzz Cool Pisan Euy"
    },
    {
      "text":
          "Your present circumstances don't determine where you can go; they merely determine where you start.",
      "author": "Nido Qubein"
    },
    {
      "text":
          "Self-care is not selfish. You cannot serve from an empty vessel.",
      "author": "Eleanor Brown"
    },
    {
      "text": "The only way out is through. The only way through is together.",
      "author": "Robert Frost"
    },
    {
      "text": "Take life day by day and be gentle with yourself.",
      "author": "Ada Deh"
    },
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _focusedDay = _today;
    _selectedDay = _today;

    // Timer untuk mengganti kutipan setiap 10 detik.
    _quoteTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        _currentQuoteIndex = Random().nextInt(_quotes.length);
      });
    });

    // Update tanggal jika hari berubah.
    Future.delayed(const Duration(minutes: 1), () {
      final newDate = DateTime.now();
      if (newDate.day != _today.day) {
        setState(() {
          _today = newDate;
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    super.dispose();
  }

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 30.0, // Padding atas lebih banyak
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6b5b95), Color(0xFF9b8ab5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hi, Jude!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome to ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          TextSpan(
                            text: 'Moodly ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700), // Gold
                            ),
                          ),
                          TextSpan(
                            text: 'application. So how are you today?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF6b5b95),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote,
                  color: Colors.white70,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  _quotes[_currentQuoteIndex]["text"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "- ${_quotes[_currentQuoteIndex]["author"]}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(), // Bagian profile tidak fixed
            Padding(
              padding: const EdgeInsets.all(16.0), // Padding untuk area konten
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Add Your Mood Record for Today",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6b5b95),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Please click on the dates below to add your ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: "mood.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFFD700), // Gold
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 250, 190, 79),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: "Month",
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MoodDetailScreen(date: selectedDay),
                          ),
                        );
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF6b5b95),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF6b5b95).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6b5b95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatBotScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Are You Feeling ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Lonely?",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFD700), // Gold
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "\nTry chatting with Moodly chatbot to feel more connected!",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.smart_toy,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
