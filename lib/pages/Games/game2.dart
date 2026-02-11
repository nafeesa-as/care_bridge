import 'package:camera/camera.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:async';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(Game2());
}

class Game2 extends StatefulWidget {
  @override
  _Game2 createState() => _Game2();
}

class _Game2 extends State<Game2> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  String targetEmotion = "😊 Happy";
  int score = 0;
  bool isMatching = false;
  bool isProcessingImage = false; // Prevent multiple detections
  late ConfettiController _confettiController;
  final List<String> emotions = [
    "😊 Happy",
    "😢 Sad",
    "😲 Surprised",
    "😡 Angry",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true, enableLandmarks: true),
    );
    _initializeCamera(); // Start the camera once
    _changeEmotion();
  }

  Future<void> _initializeCamera() async {
    await _requestPermissions();

    if (!await Permission.camera.isGranted) {
      print("Camera permission not granted!");
      return;
    }

    try {
      // Find the front camera
      CameraDescription? frontCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        print("No front camera found!");
        return;
      }

      _cameraController = CameraController(
        frontCamera, // Use the front camera
        ResolutionPreset.medium,
        enableAudio: false, // Disable audio to avoid unnecessary permissions
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {}); // Update UI after camera loads
      _startFaceDetection();
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
  }

  void _changeEmotion() {
    setState(() {
      targetEmotion = emotions[Random().nextInt(emotions.length)];
    });
  }

  void _startFaceDetection() {
    _cameraController?.startImageStream((CameraImage image) async {
      if (isProcessingImage) return; // Skip if already processing
      isProcessingImage = true;

      try {
        final inputImage = InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        final List<Face> faces = await _faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          Face face = faces.first;
          bool isCorrect = _checkExpression(face);
          if (isCorrect) {
            _confettiController.play();
            setState(() {
              score++;
              isMatching = true;
            });
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                isMatching = false;
                _changeEmotion();
              });
            });
          }
        }
      } catch (e) {
        print("Face detection error: $e");
      }

      isProcessingImage = false;
    });
  }

  bool _checkExpression(Face face) {
    switch (targetEmotion) {
      case "😊 Happy":
        return face.smilingProbability != null &&
            face.smilingProbability! > 0.6;
      case "😢 Sad":
        return face.smilingProbability != null &&
            face.smilingProbability! < 0.3;
      case "😲 Surprised":
        return face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 10;
      case "😡 Angry":
        return face.smilingProbability != null &&
            face.smilingProbability! < 0.2 &&
            face.headEulerAngleX != null &&
            face.headEulerAngleX!.abs() > 10;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug label
      theme: ThemeData(fontFamily: 'ComicSans'),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "🎭 Emotion Mirror",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue[900],
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  _cameraController != null &&
                          _cameraController!.value.isInitialized
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CameraPreview(_cameraController!),
                      )
                      : Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue.shade700,
                        ),
                      ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Text(
                    "Match This Emotion!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    targetEmotion,
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  isMatching
                      ? Text(
                        "🎉 Great Job! 🎉",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : Text(
                        "Try to match the expression!",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.5,
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.shade100,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Text(
                "⭐ Score: $score ⭐",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
