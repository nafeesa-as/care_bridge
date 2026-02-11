/*
import 'package:flutter/material.dart';
import 'dart:math';

class ColourGamePage extends StatefulWidget {
  const ColourGamePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ColourGamePageState createState() => _ColourGamePageState();
}

class _ColourGamePageState extends State<ColourGamePage> {
  final Random _random = Random();

  // Define more colors and their names
  final Map<String, Color> _colors = {
    'Red': Colors.red,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Yellow': Colors.yellow,
    'Purple': Colors.purple,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
    'Brown': Colors.brown,
  };

  late String _targetColorName;
  late Color _targetColor;
  String _message = 'Tap the matching color!';

  @override
  void initState() {
    super.initState();
    _setRandomColor();
  }

  void _setRandomColor() {
    final keys = _colors.keys.toList();
    _targetColorName = keys[_random.nextInt(keys.length)];
    _targetColor = _colors[_targetColorName]!;
    setState(() {});
  }

  void _checkAnswer(String selectedColorName) {
    if (selectedColorName == _targetColorName) {
      setState(() {
        _message = 'Correct! 🎉';
      });
      Future.delayed(const Duration(seconds: 1), () {
        _setRandomColor();
        setState(() {
          _message = 'Tap the matching color!';
        });
      });
    } else {
      setState(() {
        _message = 'Try Again! ❌';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colour Game'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: _targetColor,
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: _colors.keys.map((colorName) {
                return ElevatedButton(
                  onPressed: () => _checkAnswer(colorName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colors[colorName],
                    fixedSize: const Size(120, 60),
                  ),
                  child: const SizedBox.shrink(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:carebridge/components/square_tile.dart';
import 'package:carebridge/pages/Games/cognitive/cognitivehome.dart';
import 'package:carebridge/pages/Games/game1.dart';
import 'package:carebridge/pages/Games/game2.dart';
import 'package:carebridge/pages/Games/language/languagehome.dart';
import 'package:carebridge/pages/Games/sensorygame/sensoryhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GameHome extends StatelessWidget {
  const GameHome({super.key});
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Text("CAREBRIDGE", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SquareTile(
                        imagePath: 'lib/images/cognitive.png',
                        text: 'Cognitive Games',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Cognitivehome(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: SquareTile(
                        imagePath: 'lib/images/sensory.png',
                        text: 'Sensory Games',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Sensoryhome(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SquareTile(
                        imagePath: 'lib/images/speech.png',
                        text: 'Language Games',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Languagehome(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
