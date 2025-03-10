import 'package:flutter/material.dart';
import 'database_helper.dart';

class CustomPatternsScreen extends StatefulWidget {
  final int userId; // ✅ Receive userId

  const CustomPatternsScreen({super.key, required this.userId});

  @override
  _CustomPatternsScreenState createState() => _CustomPatternsScreenState();
}


class _CustomPatternsScreenState extends State<CustomPatternsScreen> {
  final TextEditingController _patternNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _inhaleDuration = 4;
  int _holdAfterInhaleDuration = 4;
  int _exhaleDuration = 4;
  int _holdAfterExhaleDuration = 4;
  int _totalRounds = 10;

  // Default selected icon
  IconData _selectedIcon = Icons.favorite;

  // Icon choices
  final List<IconData> _icons = [
    Icons.favorite,
    Icons.star,
    Icons.waves,
    Icons.self_improvement,
    Icons.air,
    Icons.bolt,
    Icons.accessibility_new,
  ];

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "$minutes min ${seconds}s";
  }

  int _calculateTotalDuration() {
    int breathCycleDuration = _inhaleDuration + _holdAfterInhaleDuration + _exhaleDuration + _holdAfterExhaleDuration;
    return breathCycleDuration * _totalRounds;
  }

  void _savePattern() async {
    if (_patternNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a pattern name')),
      );
      return;
    }

    int totalDuration = _calculateTotalDuration();

    int? patternId = await DatabaseHelper.instance.insertBreathworkPattern(
      name: _patternNameController.text.trim(),
      description: _descriptionController.text.trim(),
      inhaleDuration: _inhaleDuration,
      holdAfterInhaleDuration: _holdAfterInhaleDuration,
      exhaleDuration: _exhaleDuration,
      holdAfterExhaleDuration: _holdAfterExhaleDuration,
      totalRounds: _totalRounds,
      totalDuration: totalDuration,
      userId: widget.userId, // ✅ Save pattern for the correct user
      iconCode: _selectedIcon.codePoint,
    );

    if (patternId != null) {
      print("Pattern saved successfully with ID: $patternId for user ${widget.userId}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Breathwork Pattern Saved!')),
      );

      // ✅ Go back to Home Screen and reload patterns
      Navigator.pop(context, true);
    } else {
      print("Pattern save failed!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save pattern.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Pattern'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _patternNameController,
              decoration: const InputDecoration(labelText: 'Pattern Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Optional Description'),
            ),
            const SizedBox(height: 10),
            _buildSlider('Inhale Duration (seconds)', _inhaleDuration, (value) {
              setState(() {
                _inhaleDuration = value;
              });
            }),
            _buildSlider('Hold After Inhale (seconds)', _holdAfterInhaleDuration, (value) {
              setState(() {
                _holdAfterInhaleDuration = value;
              });
            }),
            _buildSlider('Exhale Duration (seconds)', _exhaleDuration, (value) {
              setState(() {
                _exhaleDuration = value;
              });
            }),
            _buildSlider('Hold After Exhale (seconds)', _holdAfterExhaleDuration, (value) {
              setState(() {
                _holdAfterExhaleDuration = value;
              });
            }),
            _buildSlider('Total Rounds', _totalRounds, (value) {
              setState(() {
                _totalRounds = value;
              });
            }),
            const SizedBox(height: 10),
            Text(
              'Total Duration: ${_formatDuration(_calculateTotalDuration())}', // ✅ Format in minutes and seconds
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // **Icon Picker**
            Text("Select an Icon:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<IconData>(
              value: _selectedIcon,
              items: _icons.map((icon) {
                return DropdownMenuItem(
                  value: icon,
                  child: Icon(icon, color: Colors.deepPurple, size: 30),
                );
              }).toList(),
              onChanged: (icon) {
                setState(() {
                  _selectedIcon = icon!;
                });
              },
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _savePattern,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Custom Pattern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 60,
          divisions: 59,
          label: value.toString(),
          onChanged: (double newValue) {
            setState(() {
              onChanged(newValue.round());
            });
          },
        ),
      ],
    );
  }
}
