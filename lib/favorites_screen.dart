import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, dynamic>> _favoritePatterns = [
    // Example favorite patterns
    {'name': 'Relaxing Breath', 'inhale': 4, 'hold': 4, 'exhale': 4},
    {'name': 'Calm Mind', 'inhale': 6, 'hold': 2, 'exhale': 6},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _favoritePatterns.isEmpty
          ? Center(
        child: Text(
          "No favorite patterns added.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _favoritePatterns.length,
        itemBuilder: (context, index) {
          final pattern = _favoritePatterns[index];
          return Card(
            color: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                pattern['name'],
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                "Inhale: ${pattern['inhale']}s, Hold: ${pattern['hold']}s, Exhale: ${pattern['exhale']}s",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.deepPurpleAccent),
                onPressed: () {
                  setState(() {
                    _favoritePatterns.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
