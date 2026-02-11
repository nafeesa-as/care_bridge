/*
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BubblePopPage extends StatefulWidget {
  @override
  _BubblePopPageState createState() => _BubblePopPageState();
}

class _BubblePopPageState extends State<BubblePopPage> {
  List<Bubble> _bubbles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true; // Toggle sound on/off
  Color _backgroundColor = Colors.black; // Initial background color
  Color? _targetColor; // Color that should be popped
  int _score = 0; // Track correct answers
  int _highScore = 0; // Track high score
  String _message = ''; // Message to display
  bool _showMessage = false; // Control message visibility
  bool _isLoading = true; // Track if scores are being loaded

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  // List of vibrant background colors
  final List<Color> _backgroundColors = [
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.teal,
    Colors.blueGrey,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  // List of colors for the bubbles
  final List<Color> _bubbleColors = [
    Colors.red.withOpacity(0.6),
    Colors.green.withOpacity(0.6),
    Colors.blue.withOpacity(0.6),
    Colors.yellow.withOpacity(0.6),
    Colors.purple.withOpacity(0.6),
    Colors.orange.withOpacity(0.6),
    Colors.pink.withOpacity(0.6),
  ];

  // Map color names to colors
  final Map<Color, String> _colorNames = {
    Colors.red.withOpacity(0.6): 'RED',
    Colors.green.withOpacity(0.6): 'GREEN',
    Colors.blue.withOpacity(0.6): 'BLUE',
    Colors.yellow.withOpacity(0.6): 'YELLOW',
    Colors.purple.withOpacity(0.6): 'PURPLE',
    Colors.orange.withOpacity(0.6): 'ORANGE',
    Colors.pink.withOpacity(0.6): 'PINK',
  };

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserScore();
    _spawnBubbles();
    _setNewTargetColor();
  }

  // Load user's score from Firestore
  Future<void> _loadUserScore() async {
    try {
      if (_currentUser != null) {
        DocumentSnapshot scoreDoc =
            await _firestore
                .collection('user_scores')
                .doc(_currentUser!.uid)
                .get();

        if (scoreDoc.exists) {
          Map<String, dynamic> data = scoreDoc.data() as Map<String, dynamic>;
          setState(() {
            _highScore = data['highScore'] ?? 0;
            _isLoading = false;
          });
        } else {
          // Create a new document if it doesn't exist
          await _firestore.collection('user_scores').doc(_currentUser!.uid).set(
            {'highScore': 0, 'lastPlayed': FieldValue.serverTimestamp()},
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading score: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save user's score to Firestore
  Future<void> _saveUserScore() async {
    try {
      if (_currentUser != null) {
        // Only update if current score is higher than high score
        if (_score > _highScore) {
          await _firestore.collection('user_scores').doc(_currentUser!.uid).set(
            {'highScore': _score, 'lastPlayed': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );

          setState(() {
            _highScore = _score;
          });
        } else {
          // Still update lastPlayed even if high score isn't beaten
          await _firestore.collection('user_scores').doc(_currentUser!.uid).set(
            {'lastPlayed': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
        }
      }
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  // Set a new random target color
  void _setNewTargetColor() {
    final random = Random();
    setState(() {
      _targetColor = _bubbleColors[random.nextInt(_bubbleColors.length)];
      _showMessage = true;
      _message = 'Pop a ${_colorNames[_targetColor]} bubble!';
    });

    // Hide message after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMessage = false;
        });
      }
    });
  }

  void _spawnBubbles() {
    for (int i = 0; i < 10; i++) {
      _addBubble(Size(400, 800)); // Adjust size as needed
    }
  }

  void _addBubble(Size screenSize) {
    final random = Random();
    double size = random.nextDouble() * 80 + 30; // Bubble size range
    Color randomColor = _bubbleColors[random.nextInt(_bubbleColors.length)];

    setState(() {
      _bubbles.add(
        Bubble(
          key: UniqueKey(),
          size: size,
          color: randomColor,
          x: random.nextDouble() * screenSize.width,
          y: random.nextDouble() * screenSize.height,
          onTap: _removeBubble,
        ),
      );
    });
  }

  void _addMultipleBubbles() {
    // Add 5 more bubbles when + button is pressed
    for (int i = 0; i < 5; i++) {
      _addBubble(MediaQuery.of(context).size);
    }
  }

  void _removeBubble(Bubble bubble) async {
    if (_soundEnabled) {
      try {
        if (kIsWeb) {
          await _audioPlayer.setSourceUrl('assets/sounds/pop.mp3');
        } else {
          await _audioPlayer.play(AssetSource('sounds/pop.mp3'));
        }
      } catch (e) {
        print("Error playing sound: $e");
      }
    }

    // Check if popped bubble matches target color
    bool isCorrect = bubble.color == _targetColor;

    if (isCorrect) {
      setState(() {
        _score += 1;
        _showMessage = true;
        _message = 'Correct! +1 point';
      });

      // Save score after each correct answer
      _saveUserScore();

      // Set new target color after successful match
      Future.delayed(Duration(seconds: 1), () {
        _setNewTargetColor();
      });
    } else {
      // Show incorrect message when wrong bubble is popped
      setState(() {
        _showMessage = true;
        _message = 'Not correct! Try a ${_colorNames[_targetColor]} bubble';
      });

      // Hide incorrect message after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showMessage = false;
          });
        }
      });
    }

    setState(() {
      _bubbles.remove(bubble);
    });

    Future.delayed(Duration(milliseconds: 500), () {
      _addBubble(MediaQuery.of(context).size);
    });
  }

  void _changeBackgroundColor() {
    final random = Random();
    setState(() {
      _backgroundColor =
          _backgroundColors[random.nextInt(_backgroundColors.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sensory Game"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Score display in AppBar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Row(
                        children: [
                          Text(
                            'Score: $_score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Best: $_highScore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
      body:
          _currentUser == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please log in to save your scores',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              )
              : GestureDetector(
                onTap: _changeBackgroundColor, // Change background on tap
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500), // Smooth transition
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _backgroundColor,
                        const Color.fromARGB(255, 0, 0, 0),
                      ], // Gradient effect
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ..._bubbles,
                      // Instruction message
                      if (_showMessage)
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color:
                                  _message.contains('Not correct')
                                      ? Colors.red.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _message,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    _message.contains('Not correct')
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      floatingActionButton:
          _currentUser == null
              ? null
              : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Sound toggle button
                  FloatingActionButton(
                    heroTag: 'sound',
                    child: Icon(
                      _soundEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _soundEnabled = !_soundEnabled;
                      });
                    },
                    backgroundColor: Colors.deepPurple,
                  ),
                  SizedBox(width: 16),
                  // Add bubbles button
                  FloatingActionButton(
                    heroTag: 'add',
                    child: Icon(Icons.add),
                    onPressed: _addMultipleBubbles,
                    backgroundColor: Colors.green,
                    tooltip: 'Add more bubbles',
                  ),
                ],
              ),
    );
  }
}

class Bubble extends StatelessWidget {
  final double size;
  final Color color;
  final double x, y;
  final Function(Bubble) onTap;

  Bubble({
    Key? key,
    required this.size,
    required this.color,
    required this.x,
    required this.y,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => onTap(this),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
*/
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BubblePopPage extends StatefulWidget {
  @override
  _BubblePopPageState createState() => _BubblePopPageState();
}

class _BubblePopPageState extends State<BubblePopPage> {
  List<Bubble> _bubbles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true; // Toggle sound on/off
  Color _backgroundColor = Colors.black; // Initial background color
  Color? _targetColor; // Color that should be popped
  int _score = 0; // Track correct answers
  int _highScore = 0; // Track high score
  final int _maxScore = 100; // Maximum score limit
  bool _gameCompleted = false; // Track if the game is completed
  String _message = ''; // Message to display
  bool _showMessage = false; // Control message visibility
  bool _isLoading = true; // Track if scores are being loaded
  bool _scoreNeedsSaving = false; // Track if there are unsaved score changes

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  // List of vibrant background colors
  final List<Color> _backgroundColors = [
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.teal,
    Colors.blueGrey,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  // List of colors for the bubbles
  final List<Color> _bubbleColors = [
    Colors.red.withOpacity(0.6),
    Colors.green.withOpacity(0.6),
    Colors.blue.withOpacity(0.6),
    Colors.yellow.withOpacity(0.6),
    Colors.purple.withOpacity(0.6),
    Colors.orange.withOpacity(0.6),
    Colors.pink.withOpacity(0.6),
  ];

  // Map color names to colors
  final Map<Color, String> _colorNames = {
    Colors.red.withOpacity(0.6): 'RED',
    Colors.green.withOpacity(0.6): 'GREEN',
    Colors.blue.withOpacity(0.6): 'BLUE',
    Colors.yellow.withOpacity(0.6): 'YELLOW',
    Colors.purple.withOpacity(0.6): 'PURPLE',
    Colors.orange.withOpacity(0.6): 'ORANGE',
    Colors.pink.withOpacity(0.6): 'PINK',
  };

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserScore();
    _spawnBubbles();
    _setNewTargetColor();
  }

  // Load user's score from Firestore
  Future<void> _loadUserScore() async {
    try {
      if (_currentUser != null) {
        final loggedInUserId = _currentUser!.uid;

        // Check scores collection first (for latest high score)
        DocumentSnapshot scoreDoc =
            await _firestore.collection('scores').doc(loggedInUserId).get();

        if (scoreDoc.exists) {
          Map<String, dynamic> data = scoreDoc.data() as Map<String, dynamic>;
          setState(() {
            _highScore = data['bubbles_high'] ?? 0;
            _isLoading = false;
          });
        } else {
          // If not found in scores collection, try the older user_scores collection
          DocumentSnapshot oldScoreDoc =
              await _firestore
                  .collection('user_scores')
                  .doc(loggedInUserId)
                  .get();

          if (oldScoreDoc.exists) {
            Map<String, dynamic> data =
                oldScoreDoc.data() as Map<String, dynamic>;
            setState(() {
              _highScore = data['highScore'] ?? 0;
              _isLoading = false;
            });
          } else {
            // No previous scores found, initialize with 0
            setState(() {
              _highScore = 0;
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading score: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save user's score to Firestore
  Future<void> _saveUserScore() async {
    try {
      if (_currentUser != null) {
        final loggedInUserId = _currentUser!.uid;

        // Update high score locally if current score is higher
        int newHighScore = _score > _highScore ? _score : _highScore;
        if (_score > _highScore) {
          setState(() {
            _highScore = _score;
          });
        }

        // Add to history collection with timestamp and high score
        await _firestore
            .collection('users')
            .doc(loggedInUserId)
            .collection('game_history')
            .add({
              'game_type': 'bubbles',
              'score': _score,
              'high_score': newHighScore,
              'timestamp': FieldValue.serverTimestamp(),
            });

        // Also update the latest score in scores collection (for backward compatibility)
        await _firestore.collection('scores').doc(loggedInUserId).set({
          'bubbles': _score,
          'bubbles_high': newHighScore,
        }, SetOptions(merge: true));

        // Mark score as saved
        setState(() {
          _scoreNeedsSaving = false;
          _showMessage = true;
          _message = 'Score saved successfully!';
        });

        // Wait briefly to show the success message before navigating back
        await Future.delayed(Duration(milliseconds: 800));

        // Navigate back to previous screen
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print("Error saving score: $e");
      // Show error message
      setState(() {
        _showMessage = true;
        _message = 'Error saving score. Please try again.';
      });

      // Hide message after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showMessage = false;
          });
        }
      });
    }
  }

  // Set a new random target color
  void _setNewTargetColor() {
    if (_gameCompleted) return; // Don't set new targets if game is completed

    final random = Random();
    setState(() {
      _targetColor = _bubbleColors[random.nextInt(_bubbleColors.length)];
      _showMessage = true;
      _message = 'Pop a ${_colorNames[_targetColor]} bubble!';
    });

    // Hide message after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMessage = false;
        });
      }
    });
  }

  void _spawnBubbles() {
    for (int i = 0; i < 10; i++) {
      _addBubble(Size(400, 800)); // Adjust size as needed
    }
  }

  void _addBubble(Size screenSize) {
    final random = Random();
    double size = random.nextDouble() * 80 + 30; // Bubble size range
    Color randomColor = _bubbleColors[random.nextInt(_bubbleColors.length)];

    setState(() {
      _bubbles.add(
        Bubble(
          key: UniqueKey(),
          size: size,
          color: randomColor,
          x: random.nextDouble() * screenSize.width,
          y: random.nextDouble() * screenSize.height,
          onTap: _removeBubble,
        ),
      );
    });
  }

  void _addMultipleBubbles() {
    // Add 5 more bubbles when + button is pressed
    for (int i = 0; i < 5; i++) {
      _addBubble(MediaQuery.of(context).size);
    }
  }

  void _removeBubble(Bubble bubble) async {
    if (_gameCompleted)
      return; // Don't allow bubble popping if game is completed

    if (_soundEnabled) {
      try {
        if (kIsWeb) {
          await _audioPlayer.setSourceUrl('lib/audio/pop.mp3');
        } else {
          await _audioPlayer.play(AssetSource('sounds/pop.mp3'));
        }
      } catch (e) {
        print("Error playing sound: $e");
      }
    }

    // Check if popped bubble matches target color
    bool isCorrect = bubble.color == _targetColor;

    if (isCorrect) {
      setState(() {
        _score += 10;
        _showMessage = true;
        _scoreNeedsSaving = true; // Mark that there are unsaved changes

        // Check if max score is reached
        if (_score >= _maxScore) {
          _gameCompleted = true;
          _message =
              'Congratulations! You reached the maximum score of $_maxScore!';

          // Optional: Add confetti or other celebration effect here
        } else {
          _message = 'Correct! +10 point';
        }
      });

      // Set new target color after successful match (only if game not completed)
      if (!_gameCompleted) {
        Future.delayed(Duration(seconds: 1), () {
          _setNewTargetColor();
        });
      }
    } else {
      // Show incorrect message when wrong bubble is popped
      setState(() {
        _showMessage = true;
        _message = 'Not correct! Try a ${_colorNames[_targetColor]} bubble';
      });

      // Hide incorrect message after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showMessage = false;
          });
        }
      });
    }

    setState(() {
      _bubbles.remove(bubble);
    });

    // Only add new bubbles if game not completed
    if (!_gameCompleted) {
      Future.delayed(Duration(milliseconds: 500), () {
        _addBubble(MediaQuery.of(context).size);
      });
    }
  }

  void _changeBackgroundColor() {
    final random = Random();
    setState(() {
      _backgroundColor =
          _backgroundColors[random.nextInt(_backgroundColors.length)];
    });
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      _score = 0;
      _gameCompleted = false;
      _bubbles.clear();
      _scoreNeedsSaving = false; // Reset save flag
    });
    _spawnBubbles();
    _setNewTargetColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sensory Game"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Score display in AppBar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Row(
                        children: [
                          Text(
                            'Score: $_score/$_maxScore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Best: $_highScore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
      body:
          _currentUser == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please log in to save your scores',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              )
              : GestureDetector(
                onTap: _changeBackgroundColor, // Change background on tap
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500), // Smooth transition
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _backgroundColor,
                        const Color.fromARGB(255, 0, 0, 0),
                      ], // Gradient effect
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ..._bubbles,
                      // Instruction message
                      if (_showMessage)
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color:
                                  _message.contains('Not correct')
                                      ? Colors.red.withOpacity(0.8)
                                      : _gameCompleted
                                      ? Colors.purple.withOpacity(0.8)
                                      : _message.contains('Score saved')
                                      ? Colors.green.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _message,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    _message.contains('Not correct')
                                        ? Colors.white
                                        : _gameCompleted
                                        ? Colors.white
                                        : _message.contains('Score saved')
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      // Game completion overlay with reset button
                      if (_gameCompleted)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_scoreNeedsSaving)
                                ElevatedButton(
                                  onPressed: _saveUserScore,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    'Save Score',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _resetGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  'Play Again',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Save Score button at the bottom
                      if (_currentUser != null &&
                          !_gameCompleted &&
                          _scoreNeedsSaving)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 80,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _saveUserScore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Save Score',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      floatingActionButton:
          _currentUser == null || _gameCompleted
              ? null // Hide buttons when game is completed or user not logged in
              : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Sound toggle button
                  FloatingActionButton(
                    heroTag: 'sound',
                    child: Icon(
                      _soundEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _soundEnabled = !_soundEnabled;
                      });
                    },
                    backgroundColor: Colors.deepPurple,
                  ),
                  SizedBox(width: 5),
                  // Add bubbles button
                  FloatingActionButton(
                    heroTag: 'add',
                    child: Icon(Icons.add),
                    onPressed: _addMultipleBubbles,
                    backgroundColor: Colors.green,
                    tooltip: 'Add more bubbles',
                  ),
                  SizedBox(width: 1),
                ],
              ),
    );
  }
}

class Bubble extends StatelessWidget {
  final double size;
  final Color color;
  final double x, y;
  final Function(Bubble) onTap;

  Bubble({
    Key? key,
    required this.size,
    required this.color,
    required this.x,
    required this.y,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => onTap(this),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
