import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Game1 extends StatefulWidget {
  @override
  _Game1State createState() => _Game1State();
}

class _Game1State extends State<Game1> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _gameActive = false;
  bool _gameOver = false;
  String _recognizedText = '';
  int _score = 0;
  int _lastScore = 0;
  late ConfettiController _confettiController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _colors = [
    {'name': 'red', 'color': Colors.red},
    {'name': 'blue', 'color': Colors.blue},
    {'name': 'green', 'color': Colors.green},
    {'name': 'yellow', 'color': Colors.yellow},
    {'name': 'orange', 'color': Colors.orange},
    {'name': 'purple', 'color': Colors.purple},
  ];

  Map<String, dynamic>? _currentColor;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _requestPermission();
    _fetchLastScore();
  }

  Future<void> _requestPermission() async {
    await Permission.microphone.request();
  }

  void _pickRandomColor() {
    setState(() {
      _currentColor = _colors[Random().nextInt(_colors.length)];
      _recognizedText = '';
    });
  }

  void _startListening() async {
    if (!_gameActive) return;

    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords.toLowerCase();
          });
          _checkAnswer();
        },
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  void _checkAnswer() {
    if (_recognizedText == _currentColor?['name']) {
      setState(() {
        _score++;
        _confettiController.play();
      });

      _stopListening(); // Stop listening before picking a new color

      Future.delayed(Duration(seconds: 1), () {
        if (_gameActive) {
          _pickRandomColor();
          Future.delayed(Duration(milliseconds: 500), () {
            _startListening();
          });
        }
      });
    } else {
      // If the answer is wrong, just restart listening without stopping the game
      Future.delayed(Duration(milliseconds: 500), () {
        if (_gameActive) {
          _startListening();
        }
      });
    }
  }

  Future<void> _fetchLastScore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          _lastScore =
              (snapshot.data() as Map<String, dynamic>?)?['result1'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching last score: $e");
    }
  }

  Future<void> _saveScore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'result1': _score, // Store the score as result1
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge to avoid overwriting other data

      setState(() {
        _lastScore = _score; // Update last score in UI
      });
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  void _toggleGame() {
    setState(() {
      _gameActive = !_gameActive;
      _isListening = _gameActive;
      _gameOver = !_gameActive;
    });

    if (_gameActive) {
      _score = 0;
      _pickRandomColor();
      _startListening();
    } else {
      _speechToText.stop();
      _saveScore();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _saveScore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("🎨 Color Spotter"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: _gameOver ? _buildGameOverScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "🎤 Say the Color Name!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: _currentColor?['color'] ?? Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "You said: ${_recognizedText.isEmpty ? "..." : _recognizedText}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleGame,
            child: Text(
              _gameActive ? "Stop Game" : "Start Game",
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "⭐ Score: $_score ⭐",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "🏆 Last Score: $_lastScore",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Game Over! Your Score: $_score",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            "🏆 Last Score: $_lastScore",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _gameOver = false;
                _toggleGame();
              });
            },
            child: Text("Restart Game"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Exit Game"),
          ),
        ],
      ),
    );
  }
}
