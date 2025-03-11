import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'breathwork_card.dart';
import 'breathwork_timer_screen.dart';
import 'custom_patterns_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "User";
  List<Map<String, dynamic>> customPatterns = [];
  
// Load user and their saved patterns 
  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadCustomPatterns(); // Fetch custom patterns
  }

  // Fetch username 
  void _loadUsername() async {
    final user = await DatabaseHelper.instance.getUserById(widget.userId);
    if (user != null && user['username'] != null) {
      setState(() {
        username = user['username'];
      });
    }
  }
  
// Fetch custom patterns
  void _loadCustomPatterns() async {
    print("Loading custom patterns for user ${widget.userId}");
    final patterns = await DatabaseHelper.instance.getBreathworkPatternsByUser(widget.userId);

    setState(() {
      customPatterns = patterns;
    });

    print("Loaded ${patterns.length} custom patterns");
  }

  // Delete pattern on long press
  void _confirmDeletePattern(int patternId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pattern"),
        content: const Text("Are you sure you want to delete this breathwork pattern?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deletePattern(patternId); // Delete pattern
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Deletes pattern in database
  Future<void> _deletePattern(int patternId) async {
    await DatabaseHelper.instance.deleteBreathworkPattern(patternId);
    _loadCustomPatterns(); // Reload patterns after deletion
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Reloads patterns when going back
      onWillPop: () async {
        _loadCustomPatterns();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFE1BEE7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Icon(Icons.waves, size: 80, color: Colors.deepPurple),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome back, $username!",
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Displays breathwork patterns
                  Expanded(
                    child: ListView(
                      children: [
                        ...customPatterns.map((pattern) => GestureDetector(
                          onLongPress: () => _confirmDeletePattern(pattern['id']),
                          child: BreathworkCard(
                            duration: "${(pattern['total_duration'] / 60).floor()} min ${pattern['total_duration'] % 60} sec",
                            title: pattern['name'],
                            description: pattern['description']?.isNotEmpty == true
                                ? "${pattern['description']}\nTotal cycles: ${pattern['total_rounds']} rounds"
                                : "${pattern['inhale_duration']} Inhale-${pattern['hold_after_inhale_duration']} Hold-${pattern['exhale_duration']} Exhale-${pattern['hold_after_exhale_duration']} Hold\nTotal cycles: ${pattern['total_rounds']} rounds",
                            icon: IconData(
                              pattern['iconCode'] ?? Icons.favorite.codePoint, // ✅ Use default icon if missing
                              fontFamily: 'MaterialIcons',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BreathworkTimerScreen(
                                    patternName: pattern['name'],
                                    inhale: pattern['inhale_duration'],
                                    hold: pattern['hold_after_inhale_duration'],
                                    exhale: pattern['exhale_duration'],
                                    totalRounds: pattern['total_rounds'],
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),

        // Bottom nav bar
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Custom Patterns",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: "Logout",
            ),
          ],
          selectedItemColor: Colors.deepPurple,
          onTap: (index) async {
            switch (index) {
              case 0:
                break;
              case 1:
                bool? patternAdded = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomPatternsScreen(userId: widget.userId), // Pass userId
                  ),
                );
                if (patternAdded == true) {
                  _loadCustomPatterns(); // Reload patterns if a new one was added
                }
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
