import 'package:flutter/material.dart';
import 'dart:async'; // For the timer

class BreathworkTimerScreen extends StatefulWidget {
  final String patternName;
  final int inhale;
  final int hold;
  final int exhale;
  final int totalRounds; // add totalRounds

  const BreathworkTimerScreen({super.key, 
    required this.patternName,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.totalRounds,
  });

  @override
  _BreathworkTimerScreenState createState() => _BreathworkTimerScreenState();
}

// Manage changes in screen from countdown etc. 
// SingleTickerProviderStateMixin used for animation

class _BreathworkTimerScreenState extends State<BreathworkTimerScreen> with SingleTickerProviderStateMixin {
  String _currentPhase = "Start";
  late Timer _timer;
  int _currentTime = 0;
  int _cycleCount = 0;
  bool _isPaused = false;
  bool _isStarted = false;
  late AnimationController _animationController; // Wave animation
  late Animation<double> _animation;

  // Initializing timer and animation
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 4), // Consistent duration for smooth animation
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Stopping timer and animation
  @override
  void dispose() {
    if (_isStarted) {
      _timer.cancel();
    }
    _animationController.dispose();
    super.dispose();
  }

  // Start breathwork session
  void _startBreathworkCycle() {
    setState(() {
      _isStarted = true;
      _currentPhase = "Inhale";
      _currentTime = widget.inhale;
      _animationController.forward();
    });

    // Handling countdown so that timer runs every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_currentTime > 0) {
            _currentTime--;
          } else {
            if (_currentPhase == "Inhale") {
              if (widget.hold < 1) {
                _currentPhase = "Exhale";
                _currentTime = widget.exhale;
                _animationController.reverse();
              } else {
                _currentPhase = "Hold";
                _currentTime = widget.hold;
                _animationController.stop();
              }
            } else if (_currentPhase == "Hold") {
              _currentPhase = "Exhale";
              _currentTime = widget.exhale;
              _animationController.reverse();
            } else if (_currentPhase == "Exhale") {
              _cycleCount++;

              // Check if total rounds are completed
              if (_cycleCount >= widget.totalRounds) {
                _endSession();
                return;
              }

              _currentPhase = "Inhale";
              _currentTime = widget.inhale;
              _animationController.forward();
            }
          }
        });
      }
    });
  }
  
// Stopping the timer
  void _endSession() {
    _timer.cancel();
    _animationController.reset();

    setState(() {
      _isStarted = false;
      _currentPhase = "Session Complete!";
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismiss
      builder: (context) => AlertDialog(
        title: const Text("Session Complete!"),
        content: const Text("You've completed all rounds."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Home Screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

// Manually pausing and stopping timer
  void _pauseTimer() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _animationController.stop();
      } else {
        if (_currentPhase == "Inhale") {
          _animationController.forward();
        } else if (_currentPhase == "Exhale") {
          _animationController.reverse();
        }
      }
    });
  }

  void _stopTimer() {
    _timer.cancel();
    _animationController.reset();

    setState(() {
      _currentTime = 0;
      _cycleCount = 0;
      _isStarted = false;
      _currentPhase = "Session Stopped";
    });

    Navigator.pop(context); // Return to Home Screen
  }

// UI Layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patternName),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(_animation.value, _currentPhase), // calls wave animation
                child: Container(),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentPhase,
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 20),
                Text(
                  "$_currentTime s",
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                SizedBox(height: 20),
                Text(
                  "Breath Cycles Completed: $_cycleCount",
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 24, color: Colors.deepPurple),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start, Stop and Pause buttons
                    ElevatedButton( 
                      onPressed: _isStarted ? _pauseTimer : _startBreathworkCycle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white70,
                      ),
                      child: Icon(_isPaused || !_isStarted ? Icons.play_arrow : Icons.pause),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _stopTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white70,
                      ),
                      child: Icon(Icons.stop),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Paints the wave animation
class WavePainter extends CustomPainter {
  final double animationValue;
  final String phase;

  WavePainter(this.animationValue, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    double waveHeight;
    if (phase == "Inhale") {
      waveHeight = size.height * (1 - animationValue);
    } else if (phase == "Exhale") {
      waveHeight = size.height * (1 - animationValue);
    } else {
      waveHeight = size.height * (1 - animationValue);
    }

    path.moveTo(0, size.height);
    path.lineTo(0, waveHeight);
    path.quadraticBezierTo(size.width / 4, waveHeight - 30, size.width / 2, waveHeight);
    path.quadraticBezierTo(3 * size.width / 4, waveHeight + 30, size.width, waveHeight);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
